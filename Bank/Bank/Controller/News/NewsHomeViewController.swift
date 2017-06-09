//
//  NewsViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/17/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import PullToRefresh
import MBProgressHUD

class NewsHomeViewController: BaseViewController {

    @IBOutlet fileprivate weak var scrollerView: UIScrollView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate lazy var lineView: UIView = UIView()
    fileprivate var selectedButton: UIButton?
    fileprivate var banners: [Banner] = []
    lazy fileprivate var pageController: CyclePageViewController = {
        return CyclePageViewController(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
    }()
    fileprivate var currentPage: Int = 1
    fileprivate var newsList: [News] = []
    fileprivate var selectedNews: News?
    fileprivate var isHot: Bool = false
    fileprivate var newsTypes: [NewsTypeObject] = []
    fileprivate var bannerPositions: [BannerPosition] = [.newsHot, .newsLocal, .newsPromos, .newsGeneral, .newsFinance]
    fileprivate let width: CGFloat = UIScreen.main.bounds.width/4.0
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        requestNewsTypeData()
        addPullToRefresh()
    }
    
    deinit {
        if let tableView = tableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            if let tag = self?.selectedButton?.tag {
                self?.requestList(page: (self?.currentPage ?? 1) + 1, type: self?.newsTypes[tag])
            }
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            if let tag = self?.selectedButton?.tag {
                self?.requestList(type: self?.newsTypes[tag])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NewsDetailsViewController {
            vc.newsID = selectedNews?.newsID
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func setTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.newsTableViewCell)
        tableView.configBackgroundView()
    }
    
    fileprivate func setBanner(banners: [Banner]) {
        tableView.tableHeaderView = nil
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for i in 0..<banners.count {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            let addView = UIImageView()
            addView.setImage(with: banners[i].imageURL, placeholderImage: R.image.image_default_large())
            addViews.append(addView)
        }
        pageController.configDataSource(viewControllers: viewControllers, addViews: addViews)
        tableView.tableHeaderView = pageController.view
        //轮播的点击事件
        pageController.tapHandler = { index in
            if let url = banners[index].url {
                Navigator.openInnerURL(url)
            }
        }
        
    }
    
    /// 设置头部的ScrollerView
    fileprivate func setTitleScrollerView() {
        
        for i in 0..<newsTypes.count {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: 40)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.tag = i
            if i == 0 {
                selectedButton = button
                selectedButton?.isSelected = true
                isHot = true
                requestBanner(tag: i)
                requestList(type: newsTypes[i])
            }
            button.setTitle(newsTypes[i].name, for: .normal)
            button.setTitleColor(UIColor(hex: 0x00a8fe), for: .selected)
            button.setTitleColor(UIColor(hex: 0x555555), for: .normal)
            button.addTarget(self, action: #selector(self.buttonAction(sender:)), for: .touchUpInside)
            scrollerView.addSubview(button)
        }
        lineView.frame = CGRect(x: 0, y: 40, width: width, height: 2)
        lineView.backgroundColor = UIColor(hex: 0x00a8fe)
        scrollerView.addSubview(lineView)
        scrollerView.showsVerticalScrollIndicator = false
        scrollerView.showsHorizontalScrollIndicator = false
        scrollerView.contentSize = CGSize(width: width * CGFloat(newsTypes.count), height: scrollerView.frame.height)
    }
    
    @objc fileprivate func buttonAction(sender: UIButton) {
        if sender.tag != selectedButton?.tag {
            selectedButton?.isSelected = false
            selectedButton = sender
            selectedButton?.isSelected = true
            isHot = sender.tag == 0 ? true : false
            requestBanner(tag: sender.tag)
            requestList(type: newsTypes[sender.tag])
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.lineView.frame = CGRect(x: sender.frame.origin.x, y: self.lineView.frame.origin.y, width: self.width, height: 2)
            })
        }
    }

}

// MARK: - Request
extension NewsHomeViewController {
    /// 请求资讯的类型
    fileprivate func requestNewsTypeData() {
        let param = NewsParameter()
        param.parentKey = NewsType.pointMallHeadline.rawValue
        let req: Promise<NewsTypeListData> = handleRequest(Router.endpoint( NewsPath.types, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let types = value.data?.typeList {
                    self.newsTypes = types
                    let hot = NewsTypeObject()
                    hot.key = NewsType.pointMallHeadline.rawValue
                    hot.typeID = ""
                    hot.name = "热门"
                    self.newsTypes.insert(hot, at: 0)
                    self.setTitleScrollerView()
                    self.setTableView()
                }
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 请求资讯列表
    fileprivate func requestList(page: Int = 1, type: NewsTypeObject?) {
        MBProgressHUD.loading(view: view)
        let param = NewsParameter()
        param.type = type?.key
        param.isTopOnly = false
        param.isHotOnly = isHot
        param.page = page
        param.perPage = 10
        let req: Promise<NewsListData> = handleRequest(Router.endpoint( NewsPath.list, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let news = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.newsList = news
                    } else {
                        self.newsList.append(contentsOf: news)
                    }
                    self.tableView.reloadData()
                }
            }
            if self.newsList.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.always {
                self.tableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
            }
    }
    
    /// 请求banner
    fileprivate func requestBanner(tag: Int) {
        let param = HomeBasicParameter()
        param.bannerPosition = bannerPositions[tag]
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        req.then { value -> Void in
            if value.isValid {
                if let banners = value.data?.banners {
                    self.banners = banners
                    self.setBanner(banners: banners)
                    self.addChildViewController(self.pageController)
                    self.tableView.reloadData()
                }
            }
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

// MARK: - UITableViewDataSource
extension NewsHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: NewsTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.newsTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.cellDataConfig(newsList[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewsHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNews = newsList[indexPath.row]
        self.performSegue(withIdentifier: R.segue.newsHomeViewController.newsMenuSegueID, sender: nil)
    }
    
}

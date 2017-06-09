//
//  AdvertViewController.swift
//  Bank
//
//  Created by yang on 16/1/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class AdvertViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var headerView: UIView!
    
    fileprivate var banners: [Banner] = []
    fileprivate var datas: [Advert] = []
    fileprivate var lastDatas: [Advert] = []
    fileprivate var selectedAdvert: Advert?
    lazy fileprivate var pageController: CyclePageViewController = {
        return CyclePageViewController(frame: self.headerView.bounds)
    }()
    fileprivate var currentPage: Int = 1
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setupTableView()
        requestBanner()
        addPullToRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isReload = currentPage == 1 ? false : true
        requestList(currentPage, isReload: isReload)
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
            self?.requestList((self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestList()
        }
    }
    
    fileprivate func setupTableView() {
        tableView.configBackgroundView()
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 128
        tableView.register(R.nib.advertTableViewCell)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AdvertDetailViewController {
            vc.advertID = self.selectedAdvert?.advertID
        }
    }
    
    @IBAction func unwindFromAnswerSuccess(_ segue: UIStoryboardSegue) {
        
    }
    
    fileprivate func reloadBanners(_ models: [Banner]) {
        let urlArray = models.flatMap {
            return $0.imageURL
        }
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for i in 0..<urlArray.count {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            let addView = UIImageView()
            addView.contentMode = .scaleAspectFill
            addView.setImage(with: urlArray[i], placeholderImage: R.image.image_default_large())
            addView.clipsToBounds = true
            addViews.append(addView)
        }
        pageController.configDataSource(viewControllers: viewControllers, addViews: addViews)
        pageController.tapHandler = { index in
            if index < self.banners.count {
                let banner = self.banners[index]
                if let URL = banner.url {
                    Navigator.openInnerURL(URL)
                }
            }
        }
        headerView.addSubview(pageController.view)
    }
    
    fileprivate func requestBanner() {
        self.tableView.tableHeaderView = nil
        let param = HomeBasicParameter()
        param.bannerPosition = BannerPosition.adBanner
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        req.then { [weak self] (value) -> Void in
            if let arr = value.data?.banners {
                self?.tableView.tableHeaderView = self?.headerView
                self?.banners = arr
                self?.reloadBanners(arr)
                if let pageVC = self?.pageController {
                    self?.addChildViewController(pageVC)
                }
            }
            }.always {

            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func requestList(_ page: Int = 1, isReload: Bool = false) {
        let param = AdvertiseParameter()
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<AdvertListData> = handleRequest(Router.endpoint( AdvertisePath.list, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.datas = items
                } else {
                    if isReload == false {
                        self.lastDatas = self.datas
                    } else {
                        self.datas = self.lastDatas
                    }
                    self.datas.append(contentsOf: items)
                }
                self.tableView.reloadData()
            }
            if self.datas.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.endRefreshing(at: .top)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

// MARK: - UITableViewDataSource
extension AdvertViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.advertTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(datas[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AdvertViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAdvert = datas[indexPath.row]
        performSegue(withIdentifier: R.segue.advertViewController.showAdvertDetailVC, sender: nil)
    }
    
}

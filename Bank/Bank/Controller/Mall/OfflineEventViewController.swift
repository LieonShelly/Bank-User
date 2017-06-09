//
//  OfflineEventViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/22.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD
import Device

class OfflineEventViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var headerView: UIView!
    
    fileprivate var selectedEvent: OfflineEvent?
    fileprivate var datas: [OfflineEvent] = []
    lazy fileprivate var pageController: CyclePageViewController = {
       return CyclePageViewController(frame: self.headerView.bounds)
    }()
    fileprivate var listView: ListView!
    fileprivate var banners: [Banner] = []
    fileprivate var theSort: String = "0"
    fileprivate var currentPage: Int = 1
    fileprivate var lastEventList: [OfflineEvent] = []
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setupTableView()
        setListView()
        requestBanner()
        addPullToRefresh()
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
    
    func reloadBanners(_ models: [Banner]) {
        let urlArray = models.flatMap {
            return $0.imageURL
        }
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for i in 0..<urlArray.count {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            let addView = UIImageView()
            addView.setImage(with: urlArray[i], placeholderImage: R.image.image_default_large())
            addView.clipsToBounds = true
            addView.contentMode = .scaleAspectFill
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
        if let view = pageController.view {
            headerView.addSubview(view)
        }
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
        if Device.size() > .screen4Inch {
            tableView.register(R.nib.offlineEventTableViewCell)
        } else {
            tableView.register(R.nib.offlineEventTableViewCell_SE)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setListView() {
        let listTitleArray = [R.string.localizable.string_title_default()]
        let sortArray = GoodsSort.setOfflineEventSort()
        listView = ListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), titleArray: listTitleArray)
        
        listView.createDataSource([], secondDatas: [], thirdDatas: sortArray, firstIsCat: false)
        view.addSubview(listView)
        listView.selectedSortHandleBlock = { [weak self] sort in
            if let sortID = sort.sortID {
                self?.theSort = sortID
            }
            self?.datas.removeAll()
            self?.lastEventList.removeAll()
            self?.requestList()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OfflineEventDetailViewController {
            vc.eventID = self.selectedEvent?.eventID
        }
        
    }
    
    fileprivate func showAlertView(_ message: String, event: OfflineEvent, cell: OfflineEventTableViewCell) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.requestSign(false, event: event, cell: cell)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: Request
extension OfflineEventViewController {
    
    // 请求banner
    func requestBanner() {
        tableView.tableHeaderView = nil
        let param = HomeBasicParameter()
        param.bannerPosition = BannerPosition.offineEventsBanner
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
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
                }
            }.catch { _ in }
    }
    
    /**
     请求活动列表
     */
    fileprivate func requestList(_ page: Int = 1, isReload: Bool = false) {
        let param = OfflineEventParameter()
        param.page = page
        param.perPage = 20
        param.sort = theSort
        MBProgressHUD.loading(view: view)
        let req: Promise<OfflineEventListData> = handleRequest(Router.endpoint( OfflineEventPath.list, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.datas = items
                } else {
                    if isReload == false {
                        self.lastEventList = self.datas
                    } else {
                        self.datas = self.lastEventList
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
                self.tableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // 立即报名或取消报名
    fileprivate func requestSign(_ sign: Bool, event: OfflineEvent, cell: OfflineEventTableViewCell) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        if AppConfig.shared.isLoginFlag {
            MBProgressHUD.loading(view: view)
            let param = OfflineEventParameter()
            param.eventID = event.eventID
            var router = OfflineEventPath.signIn
            if !sign {
                router = OfflineEventPath.signOut
            }
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( router, param: param))
            req.then { (value) -> Void in
                if sign == true {
                    Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_sign_success())
                    event.status = .signedUp
                    event.signedNumber += 1
                    //                cell.joinNumberLabel.amountWithUnit(Float(event.signedNumber), color: UIColor(hex: 0xa0a0a0), amountFontSize: 15, unitFontSize: 15, unit: R.string.localizable.alertTitle_sign())
                    cell.button.setTitle(event.status?.title, for: .normal)
                } else {
                    Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_cancel_success())
                    event.status = .enrolling
                    event.signedNumber -= 1
                    //                cell.joinNumberLabel.amountWithUnit(Float(event.signedNumber), color: UIColor(hex: 0xa0a0a0), amountFontSize: 15, unitFontSize: 15, unit: R.string.localizable.alertTitle_sign())
                    cell.button.setTitle(event.status?.title, for: .normal)
                }
                }.always {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }.catch { (error) in
                    if let err = error as? AppError {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
            }
        } else {
            showSessionVC()
        }
    }
}

// MARK: UITableViewDataSource
extension OfflineEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: OfflineEventTableViewCell?
        if Device.size() > .screen4Inch {
            cell = tableView.dequeueReusableCell(withIdentifier: R.nib.offlineEventTableViewCell, for: indexPath)
            cell?.isHideStatus = true
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: R.nib.offlineEventTableViewCell_SE, for: indexPath)
            cell?.isHideStatus = true
        }
        if let cell = cell {
            cell.configData(datas[indexPath.row])
            cell.buttonHandleBlock = { event in
                guard let status = event.status else {
                    return
                }
                if case .signedUp = status {
                    // 取消报名
                    self.showAlertView(R.string.localizable.alertTitle_is_cancel_sign(), event: event, cell: cell)
                }
                if case .enrolling = status {
                    // 报名
                    self.requestSign(true, event: event, cell: cell)
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: UITableViewDelegate
extension OfflineEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Device.size() > .screen4Inch {
            return 127
        } else {
            return 101
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = datas[indexPath.row]
        performSegue(withIdentifier: R.segue.offlineEventViewController.showEventDetailVC, sender: nil)
    }
}

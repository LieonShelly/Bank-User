//
//  NotificationViewController.swift
//  Bank
//
//  Created by 王虹翔 on 16/5/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable empty_count

import UIKit
import PromiseKit
import ObjectMapper
import Alamofire
import URLNavigator
import PullToRefresh
import MBProgressHUD

class NotificationViewController: BaseViewController {
    
    @IBOutlet weak fileprivate var menuScrollView: UIScrollView!
    @IBOutlet weak fileprivate var tableView: UITableView!
    fileprivate var customHorizontalIndicator: UIImageView?
    fileprivate let titleArray: [NoticeCategory] = [.all, .system, .pointChange, .localLife]
    fileprivate var menus: [LabelWithReddot] = []
    fileprivate var data: NotificationList?
    fileprivate var selectedNotice: Notification?
    fileprivate var currentPage: Int = 1
    fileprivate var datas: [Notification] = []
    fileprivate var lastDatas: [Notification] = []
    fileprivate var totalPags: Int = 1
    fileprivate var selectedTab: Int? = 0
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .notifiction)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        tableView?.tableFooterView = UIView()
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.register(R.nib.notificationTableViewCell)
        tableView?.configBackgroundView()
        setupMenu()
        addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isReload = currentPage == 1 ? false : true
        requestList(currentPage, isReload: isReload, tab: self.selectedTab)
    }

    deinit {
        if let tableView = tableView {
            if let refresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(refresh)
            }
            if let refresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(refresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) {
            let page = self.currentPage + 1
            if page <= self.totalPags {
                self.requestList(page, tab: self.selectedTab)
            }
            self.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestList(tab: self?.selectedTab)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? InviteFromMemberViewController {
//            vc.data = selectedNotice
//            vc.title = "消息详情"
//        }

    }
    override func leftAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func requestList(_ page: Int = 1, isReload: Bool = false, tab: Int? = 0) {
        MBProgressHUD.loading(view: view)
        let param = UserParameter()
        param.page = page
        param.perPage = 20
        if let tempTab = tab, let cat = NoticeCategory(rawValue: "\(tempTab)") {
            param.noticeCategory = cat
        }
        let req: Promise<NotificationListData> = handleRequest(Router.endpoint(UserPath.notificationList, param: param))
        req.then { (value) -> Void in
            if let totalPag = value.data?.totalPage {
                self.totalPags = totalPag
            }
            if let data = value.data?.newMessageCount {
                self.showReddot(data)
            }
            if let items = value.data?.items, !items.isEmpty {
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
            } else {
                self.datas.removeAll()
            }
            if self.datas.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            self.tableView.reloadData()
            }.always {
                self.tableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    // 删除消息
    fileprivate func deleteNotifiction(_ items: [Notification]) {
        let deleteParam = UserParameter()
        deleteParam.messageIDs = items.map { $0.messageID }
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.deleteNotificationList, param: deleteParam))
        req.then {(value) -> Void in
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // 设置滚动菜单标题
    fileprivate func setupMenu() {
        let viewWidth = screenWidth / CGFloat(titleArray.count)
        for i in 0 ..< titleArray.count {
            let view = LabelWithReddot(frame: CGRect(x: CGFloat(i) * viewWidth, y: 0, width: viewWidth, height: 42))
            view.label.text = titleArray[i].name
            view.index = i
            view.noticeCategory = titleArray[i]
            view.tapHandle = { [weak self] view in
                self?.menuScrollView.scrollRectToVisible(view.frame, animated: true)
                self?.customHorizontalIndicator?.frame = CGRect(x: view.frame.minX, y: 42, width: viewWidth, height: 2)
                self?.requestList(tab: view.noticeCategory?.tab)
                self?.selectedTab = view.noticeCategory?.tab
                if let menus = self?.menus {
                    for menu in menus where menu.index != view.index {
                        menu.setSelected(false)
                    }
                }
            }
            if i == 0 {
                view.setSelected(true)
                selectedTab = view.noticeCategory?.tab
            }
            menus.append(view)
            menuScrollView.addSubview(view)
        }
        menuScrollView.contentSize = CGSize(width: CGFloat(titleArray.count) * viewWidth, height: 44)
        menuScrollView.showsHorizontalScrollIndicator = false
        customHorizontalIndicator = UIImageView(frame:CGRect(x: 0, y: 42, width: viewWidth, height: 2))
        customHorizontalIndicator?.backgroundColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        if let view = customHorizontalIndicator {
            menuScrollView.addSubview(view)
        }
        
    }
    
    fileprivate func showReddot(_ data: [NewNotificationCount]) {
        _ = data.map { (newMessageCout) -> Void in
            let object = NoticeCategory(rawValue: "\(newMessageCout.tab)")
            if let obj = object {
                _ = menus.filter({ (label) -> Bool in
                    return  label.noticeCategory == obj
                }).map({ (label) -> Void in
                    label.showReddot(newMessageCout.count > 0)
                })
            }
        }
    }
    
    fileprivate func requestToggleRead(_ messageID: String?) {
        let param = UserParameter()
        param.messageID = messageID
        let req: Promise<NullDataResponse> =
            handleRequest(Router.endpoint( UserPath.readNotification, param: param))
        req.then { (value) -> Void in
            AppConfig.shared.unreadCount -= 1
        }.catch { _ in }
    }
}

extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: NotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.notificationTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.cellDataSetup(datas[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = datas.remove(at: indexPath.row)
            deleteNotifiction([item])
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
}

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datas[indexPath.row]
        datas[indexPath.row].readStatus = .read
        self.tableView.reloadData()
        selectedNotice = item
        requestToggleRead(item.messageID)
        if let extraData = item.extra {
            var url = URLComponents()
            url.scheme = Const.URLScheme
            do {
                let data: Data = try JSONSerialization.data(withJSONObject: extraData, options: [])
                guard let str = String(data:data, encoding: .utf8) else { return }
                url.host = str
                if let url = url.url {
                    Navigator.openInnerURL(url)
                }
            } catch {}
        } else {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

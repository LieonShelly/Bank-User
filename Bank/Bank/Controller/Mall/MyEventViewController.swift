//
//  TaskViewController.swift
//  Bank
//
//  Created by yang on 16/2/2.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD
import Device

class MyEventViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet fileprivate weak var indicatorView: UIView!
    @IBOutlet fileprivate weak var button1: UIButton!
    @IBOutlet fileprivate weak var button2: UIButton!
    @IBOutlet fileprivate weak var indicator1: UIView!
    @IBOutlet fileprivate weak var indicator2: UIView!
    
    fileprivate var datas: [OfflineEvent] = [] {
        didSet {
            if datas.isEmpty {
                noneView.buttonHandleBlock = { [weak self] in
                    guard let vc = R.storyboard.point.offlineEventViewController() else {
                        return
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                tableView.addSubview(noneView)
            } else {
                noneView.removeFromSuperview()
            }
        }
    }
    fileprivate var currentPage: Int = 1
    fileprivate var isSigned: Bool = false
    fileprivate var selectedEvent: OfflineEvent!
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .unCompleteEvent) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setupTableView()
        addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestListData()
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
            self?.requestListData((self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestListData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MyEventDetailViewController {
            vc.joinID = self.selectedEvent.joinID
            vc.eventID = self.selectedEvent.eventID
            vc.isClosed = self.selectedEvent.isClosed
            vc.isApproved = self.selectedEvent.isApproved
        }
    }
    
    /// 设置UITableView的相关属性
    fileprivate func setupTableView() {
        tableView.configBackgroundView()
        if Device.size() > .screen4Inch {
            tableView.register(R.nib.offlineEventTableViewCell)
        } else {
            tableView.register(R.nib.offlineEventTableViewCell_SE)
        }
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 请求我的活动数据
    fileprivate func requestListData(_ page: Int = 1) {
        let param = OfflineEventParameter()
        param.isSigned = isSigned
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<OfflineEventListData> = handleRequest(Router.endpoint( OfflineEventPath.signedList, param: param))
        req.then {(value) -> Void in

            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.datas = items
                } else {
                    self.datas.append(contentsOf: items)
                }
                self.tableView.reloadData()
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
    // 取消报名
    fileprivate func requestSign(_ eventID: String, indexPath: IndexPath) {
        MBProgressHUD.loading(view: view)
        let param = OfflineEventParameter()
        param.eventID = eventID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OfflineEventPath.signOut, param: param))
        req.then { (value) -> Void in
                self.datas.remove(at: indexPath.row)
                self.tableView.reloadData()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 未完成/已完成
    @IBAction func buttonHandle(_ sender: UIButton) {
        button1.isSelected = sender.tag == 0
        button2.isSelected = sender.tag != 0
        indicator1.isHidden = !button1.isSelected
        indicator2.isHidden = !button2.isSelected
        if button1.isSelected == true {
            noneView.type = .unCompleteEvent
            isSigned = false
        } else {
            noneView.type = .completeEvent
            isSigned = true
        }
        requestListData()
    }
    
    fileprivate func showAlertView(_ message: String, eventID: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.requestSign(eventID, indexPath: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension MyEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: OfflineEventTableViewCell?
        if Device.size() > .screen4Inch {
            cell = tableView.dequeueReusableCell(withIdentifier: R.nib.offlineEventTableViewCell, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: R.nib.offlineEventTableViewCell_SE, for: indexPath)
        }
        cell?.offlineEventType = .myTask
        cell?.isHideStatus = !isSigned
        cell?.configData(datas[indexPath.row])
        cell?.buttonHandleBlock = { [weak self] event in
            self?.showAlertView(R.string.localizable.alertTitle_is_cancel_sign(), eventID: event.eventID, indexPath: indexPath)
        }
        if let cell = cell {
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension MyEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Device.size() > .screen4Inch {
            return 120
        } else {
            return 101
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if button1.isSelected {
//            selectedEvent = waiting[indexPath.row]
//        } else {
//            selectedEvent = finished[indexPath.row]
//        }
        selectedEvent = datas[indexPath.row]
        performSegue(withIdentifier: R.segue.myEventViewController.showMyEventDetailVC, sender: nil)
    }
}

//
//  MyTaskViewController.swift
//  Bank
//
//  Created by yang on 16/6/27.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import PullToRefresh
import MBProgressHUD
import Device

class MyTaskViewController: BaseViewController {

    @IBOutlet weak fileprivate var tableView: UITableView!
    fileprivate var taskArray: [DailyTask] = [] {
        didSet {
            if taskArray.isEmpty {
                noneTaskView.buttonHandleBlock = { [weak self] in
                    guard let vc = R.storyboard.point.dailyTaskViewController() else {
                        return
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                tableView.addSubview(noneTaskView)
            } else {
                noneTaskView.removeFromSuperview()
            }
        }
    }
    fileprivate var selectedTask: DailyTask!
    fileprivate lazy var noneTaskView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .task) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setTableView()
        addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestList()
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
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestList()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DailyTaskDetailViewController {
            vc.taskID = selectedTask.taskID
            vc.point = selectedTask.point
        }
    }
    
    /// 设置UITableView的祥光属性
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        if Device.size() > .screen4Inch {
            tableView.rowHeight = 120
            tableView.register(R.nib.offlineEventTableViewCell)
        } else {
            tableView.rowHeight = 101
            tableView.register(R.nib.offlineEventTableViewCell_SE)
        }
        tableView.separatorColor = UIColor.clear
        tableView.tableFooterView = UIView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: Request
extension MyTaskViewController {
    
    /// 请求我的任务列表
    func requestList() {
        MBProgressHUD.loading(view: view)
        let req: Promise<DailyTaskListData> = handleRequest(Router.endpoint( MallPath.myTasks, param: nil))
        req.then { (value) -> Void in
            if let data = value.data?.taskList {
                self.taskArray = data
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
    
    /// 领取任务
    fileprivate func requestGetTask(_ taskID: String, indexPath: IndexPath) {
        MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.taskID = taskID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( MallPath.getTask, param: param))
        req.then { (value) -> Void in
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_receive_job_success())
            let data = self.taskArray[indexPath.row]
            data.status = .unfinished
            self.tableView.reloadRows(at: [indexPath], with: .none)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 领取奖励
    fileprivate func requestReward(_ task: DailyTask, indexPath: IndexPath) {
        MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.taskID = task.taskID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( MallPath.newbieTaskReward, param: param))
        req.then { (value) -> Void in
            guard let title = task.title else {
                return
            }
            let message = "恭喜你,完成\(title)任务!+\(task.point)积分"
            Navigator.showAlertWithoutAction(nil, message: message)
            let data = self.taskArray[indexPath.row]
            data.status = .gotAward
            self.tableView.reloadRows(at: [indexPath], with: .none)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

// MARK: UITableViewDataSource
extension MyTaskViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: OfflineEventTableViewCell?
        if Device.size() > .screen4Inch {
            cell = tableView.dequeueReusableCell(withIdentifier: R.nib.offlineEventTableViewCell, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: R.nib.offlineEventTableViewCell_SE, for: indexPath)
        }
        cell?.configInfo(taskArray[indexPath.row])
        cell?.taskButtonHandle = { [weak self] task in
            guard let task = task else { return }
            if task.status == .finished {
                self?.requestReward(task, indexPath: indexPath)
            }
            if task.status == .unGet {
                self?.requestGetTask(task.taskID, indexPath: indexPath)
            }
        }
        if let cell = cell {
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: UITablViewDelegate
extension MyTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = taskArray[indexPath.row]
        performSegue(withIdentifier: R.segue.myTaskViewController.showTaskDetailVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Device.size() > .screen4Inch {
            return 120
        } else {
            return 101
        }
    }
}

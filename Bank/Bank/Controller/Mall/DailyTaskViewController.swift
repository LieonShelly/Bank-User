//
//  DailyTaskViewController.swift
//  Bank
//
//  Created by yang on 16/2/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD
import Device

class DailyTaskViewController: BaseViewController {

    @IBOutlet weak fileprivate var tableView: UITableView!
    
    fileprivate var datas: [DailyTask] = []
    fileprivate var selectedTask: DailyTask!
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    deinit {
        if let tableView = tableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DailyTaskDetailViewController {
            vc.taskID = selectedTask.taskID
            vc.point = selectedTask.point
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        if Device.size() > .screen4Inch {
            tableView.register(R.nib.offlineEventTableViewCell)
        } else {
            tableView.register(R.nib.offlineEventTableViewCell_SE)
        }
    }
    
    /**
     请求日常任务
     */
    fileprivate func requestData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<DailyTaskListData> = handleRequest(Router.endpoint( MallPath.newbieTaskList, param: nil), needToken: .default)
        req.then { (value) -> Void in
            if let data = value.data?.taskList {
                self.datas = data
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
    
    // 领取任务
    fileprivate func requestGetTask(_ taskID: String, indexPath: IndexPath) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.taskID = taskID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( MallPath.getTask, param: param))
        req.then { (value) -> Void in
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_receive_job_success())
            let data = self.datas[indexPath.row]
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
    
    // 领取奖励
    fileprivate func requestReward(_ task: DailyTask, indexPath: IndexPath) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
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
            let data = self.datas[indexPath.row]
            data.status = .gotAward
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
    
    @IBAction func gotoHelpAction(_ sender: UIBarButtonItem) {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {
            return
        }
        vc.tag = HelpCenterTag.dailyTaskDetail
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DailyTaskViewController: UITableViewDataSource {
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
        
        cell?.configInfo(datas[indexPath.row])
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

// MARK: - UITableViewDelegate
extension DailyTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Device.size() > .screen4Inch {
            return 120
        } else {
            return 101
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = datas[indexPath.row]
        performSegue(withIdentifier: R.segue.dailyTaskViewController.showTaskDetailVC, sender: nil)
    }
}

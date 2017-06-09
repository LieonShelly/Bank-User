//
//  DailyTaskDetailViewController.swift
//  Bank
//
//  Created by yang on 16/6/27.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import WebKit
import MBProgressHUD

class DailyTaskDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var button: UIButton!
    fileprivate var webView: WKWebView?
    fileprivate var task: DailyTask?
    var taskID: String?
    var point: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "帮助", style: .done, target: self, action: #selector(self.showHelp))
        requestData()
        
    }
    
    func showHelp() {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {return}
        vc.tag = HelpCenterTag.dailyTaskDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView?.navigationDelegate = self
        if let web = webView {
            view.addSubview(web)
        }
        webView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(button.snp.top).offset(0)
        })
    }
    
    /// 加载网页
    
    fileprivate func loadWebView() {
        if let html = task?.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    /// 请求任务详情
    fileprivate func requestData() {
        MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.taskID = taskID
        let req: Promise<DailyTaskDetailData> = handleRequest(Router.endpoint( MallPath.newbieTaskDetail, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let data = value.data {
                self.task = data
                self.loadWebView()
            }
            }.always {
//                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func setButton() {
        self.button.setTitle(self.task?.status?.text, for: .normal)
        if self.task?.status == .invalid || self.task?.status == .gotAward || self.task?.status == .unfinished {
            self.button.isUserInteractionEnabled = false
            self.button.backgroundColor = UIColor.gray
        } else {
            self.button.isUserInteractionEnabled = true
            self.button.backgroundColor = UIColor.orange
        }
    }
    
    // 领取任务
    fileprivate func requestGetTask(_ taskID: String) {
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
            self.task?.status = .unfinished
            self.setButton()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // 领取奖励
    fileprivate func requestReward(_ taskID: String?) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.taskID = taskID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( MallPath.newbieTaskReward, param: param))
        req.then { (value) -> Void in
            guard let title = self.task?.title else {
                return
            }
            let message = "恭喜你,完成\(title)任务!+\(self.point)积分"
            Navigator.showAlertWithoutAction(nil, message: message)
            self.task?.status = .gotAward
            self.setButton()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        if task == nil {
            return
        }
        if let status = task?.status {
            switch status {
            case .unGet:
                if let taskID = task?.taskID {
                    requestGetTask(taskID)
                }
            case .unfinished:
                break
            case .finished:
                requestReward(task?.taskID)
            case .gotAward:
                break
            case .invalid:
                break
            }
        }
    }
    
}

extension DailyTaskDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setButton()
        MBProgressHUD.hide(for: view, animated: true)
    }
}

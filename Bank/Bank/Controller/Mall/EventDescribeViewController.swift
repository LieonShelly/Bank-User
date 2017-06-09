//
//  EventDescribeViewController.swift
//  Bank
//
//  Created by 杨锐 on 16/8/2.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import WebKit
import MBProgressHUD

class EventDescribeViewController: BaseViewController {
    
    fileprivate var webView: WKWebView?
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    fileprivate var onlineEvent: OnlineEvent?
    var eventID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestDetailData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        if let web = webView {
            view.addSubview(web)
        }
        webView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(65)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        })
    }
    
    // 关闭
    @IBAction func dismissAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadWebView() {
        if let html = onlineEvent?.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func requestDetailData() {
        MBProgressHUD.loading(view: view)
        let param = OnlineEventParameter()
        param.eventID = eventID
        let req: Promise<EventDetailData> = handleRequest(Router.endpoint( OnlineEventPath.introduce, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let event = value.data {
                self.onlineEvent = event
                self.titleLabel.text = event.title
                self.titleLabel.font = UIFont(name: "PingFangSC-Medium", size: 20)
                self.loadWebView()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }

}

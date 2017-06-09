//
//  DetailLinkViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import WebKit

class NoticeDetailViewController: BaseViewController {
    
    fileprivate var webView: WKWebView?
    
    var messageID: String?
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        view = webView
        requestData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.navigationDelegate = self
    }
    
    fileprivate func requestData() {
        MBProgressHUD.showAdded(to: view, animated: true)
        let param = UserParameter()
        param.messageID = messageID
        let req: Promise<NotificationDetailData> = handleRequest(Router.endpoint(endpoint: UserPath.notificationDetail, param: param))
        req.then { (value) -> Void in
            print(value.data?.html)
            if let html = value.data?.html {
                _ = self.webView?.loadHTMLString(html, baseURL: nil)
            }
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { _ in }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension NoticeDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

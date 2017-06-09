//
//  HelpViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import WebKit
import PromiseKit
import MBProgressHUD

public enum WebViewURL: ContentProtocol {
    case about
    case doc
    case `protocol`
    case help
    
    var path: String {
        return "webview"
    }
    
    var endpoint: String {
        switch self {
        case .about:
            return "about_us/user.html"
        case .doc:
            return "doc"
        case .protocol:
            return "protocol"
        case .help:
            return "help"
        }
    }
}

class HelpViewController: BaseViewController {

    fileprivate var webView: WKWebView?
    
    var htmlName: String?
    private let string = WebViewURL.about.URL()
    fileprivate var path: URL?
    fileprivate var htmlString: String?
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView?.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let string = htmlString {
            _ = webView?.loadHTMLString(string, baseURL: nil)
        } else if let URL = path {
            _ = webView?.load(URLRequest(url: URL))
        }
    }
    
    func loadURL(_ URL: Foundation.URL) {
        path = URL
    }
    
    /// 加载系统消息详情
    func loadSystemNotice(messageID: String) {
        let param = UserParameter()
        param.noticeID = messageID
        let req: Promise<SystemNoticeDetailData> = handleRequest(Router.endpoint(SystemMessagePath.detail, param: param))
        req.then { (value) -> Void in
            if let notice = value.data {
                self.htmlString = notice.html
                self.title = notice.title
                if let string = notice.html {
                    _ = self.webView?.loadHTMLString(string, baseURL: nil)
                }
            }
            }.catch { _ in }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HelpViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

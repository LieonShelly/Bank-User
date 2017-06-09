//
//  WebAdvertViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/9/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import WebKit

class WebAdvertViewController: BaseViewController {
    
    var url: URL?
    
    fileprivate var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        title = "广告详情"
        let rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_close(), style: .plain, target: self, action: #selector(closeAction(_:)))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc fileprivate func closeAction(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView?.navigationDelegate = self
        view = webView
        if let url = self.url {
            _ = webView?.load(URLRequest(url: url))
        }
    }
}

extension WebAdvertViewController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        MBProgressHUD.loading(view: view)
//    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        MBProgressHUD.hide(for: view, animated: true)
//    }
}

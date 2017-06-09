//
//  ApplyUserViewController.swift
//  Bank
//
//  Created by 杨锐 on 16/7/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import WebKit
import MBProgressHUD

private enum UserWebViewURL: UserProtocol {
    case phone
    
    var path: String {
        return "webview"
    }
    
    var endpoint: String {
        return "led_phone"
    }
}

class ApplyUserViewController: BaseViewController {
    
    fileprivate var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView?.navigationDelegate = self
        webView?.frame = view.bounds
        //webView?.navigationDelegate = self
        if let web = webView {
            view.addSubview(web)
        }
        let string = UserWebViewURL.phone.URL()
        if let url = URL(string: string) {
            _ = webView?.load(URLRequest(url: url))
        }
        addButton()
    }
    
    /// 添加关闭按钮
    fileprivate func addButton() {
        let button = UIButton(type: .custom)
        button.setImage(R.image.btn_close(), for: .normal)
        button.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
    }
    
    /// 关闭此页面
    ///
    /// - Parameter btn: 按钮参数
    @objc fileprivate func dismissAction(_ btn: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ApplyUserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
}

//
//  HelpCenterHomeViewController.swift
//  Bank
//
//  Created by lieon on 16/8/2.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import WebKit

class HelpCenterHomeViewController: BaseViewController {
    
    private let tagURLStr: String = {
        var str = WebViewURL.help.URL()
        str.append("help_detail?tag=")
        return str
    }()
    
    private let homeURLStr: String = {
        var str = WebViewURL.help.URL()
        str.append("index?platform=1")
        return str
    }()
    
    var tag: HelpCenterTag?
    fileprivate var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        backBtnSet()
        let callItem = UIBarButtonItem(image: R.image.btn_customer_service2(), style: .plain, target: self, action: #selector(self.callHelp))
        navigationItem.rightBarButtonItem = callItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    fileprivate lazy var webView: WKWebView = {
        let wb = WKWebView()
        return wb
    }()
    
    fileprivate lazy var progressView: UIProgressView = {
        let pro = UIProgressView()
        pro.tintColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        pro.trackTintColor = UIColor.white
        return pro
    }()
    
    fileprivate func setupUI() {
        title = R.string.localizable.controller_title_help_center()
        view.addSubview(webView)
        view.insertSubview(progressView, aboveSubview: webView)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
        }
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(webView.snp.top).offset(1)
            make.right.equalTo(0)
            make.height.equalTo(2)
            make.left.equalTo(0)
        }
    }
    
    fileprivate func setupWebView() {
        
        webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        if let tag = tag {
            let urlStr = tagURLStr + tag.rawValue
            url = URL(string: urlStr)
        } else {
            url = URL(string: homeURLStr)
        }
        if let url = url {
            let requst = URLRequest(url: url)
            webView.load(requst)
        }
    }
    
    @objc fileprivate func callHelp() {
        guard let tel = AppConfig.shared.baseData?.serviceHotLine else { return }
        
        let alert = UIAlertController(title: nil, message: "是否拨打客服电话\(tel)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_dials(), style: .default, handler: { (action) in
            if let tel = AppConfig.shared.baseData?.serviceHotLine,
                let url = URL(string: "tel://\(tel)") {
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func backBtnSet() {
    
        let backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -35, bottom: 0, right: 0)
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        backBtn.setImage(R.image.btn_left_arrow(), for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(self.backBtnClick), for: UIControlEvents.touchUpInside)
        backBtn.setTitle(R.string.localizable.button_title_null_back())
        let backItem = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItem = backItem
    }
    
    func backBtnClick() {
        
        if webView.canGoBack {
           webView.goBack()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

extension HelpCenterHomeViewController: WKNavigationDelegate {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if keyPath == "title" {
            title = R.string.localizable.controller_title_help_center()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        let  alter = UIAlertController(title: R.string.localizable.alertTitle_error(), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//        alter.addAction(UIAlertAction(title: R.string.localizable.alertTitle_ok(), style: UIAlertActionStyle.default, handler: nil))
//        present(alter, animated: true, completion: nil)
        progressView.setProgress(0.0, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
}

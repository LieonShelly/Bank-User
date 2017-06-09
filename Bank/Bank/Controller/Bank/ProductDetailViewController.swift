//
//  ProductDetailViewController.swift
//  Bank
//
//  Created by lieon on 16/8/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import WebKit

class ProductDetailViewController: UIViewController {
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
    }
   
    fileprivate lazy var webView: WKWebView = {
        let wb = WKWebView()
        return wb
    }()

    fileprivate lazy var progressView: UIProgressView = {
        let pro = UIProgressView()
        pro.tintColor = UIColor.blue
        pro.trackTintColor = UIColor.white
        return pro
    }()

    fileprivate func setupUI() {
        view.addSubview(webView)
        view.insertSubview(progressView, aboveSubview: webView)
        webView.navigationDelegate = self
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
        guard let url = url else { return }
        let requst = URLRequest(url: url)
        webView.load(requst)
     }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

extension ProductDetailViewController:WKNavigationDelegate {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       if keyPath == "estimatedProgress" {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if keyPath == "title" {
            title = webView.title
       }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let  alter = UIAlertController(title: R.string.localizable.alertTitle_ok(), message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alter.addAction(UIAlertAction(title: R.string.localizable.alertTitle_error(), style: UIAlertActionStyle.default, handler: nil))
        present(alter, animated: true, completion: nil)
        
        progressView.setProgress(0.0, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
}

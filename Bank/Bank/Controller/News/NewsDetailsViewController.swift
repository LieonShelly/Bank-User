//
//  NewsDetailsViewController.swift
//  Bank
//
//  Created by Mac on 15/12/1.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import WebKit
import MBProgressHUD

class NewsDetailsViewController: BaseViewController {

    fileprivate var webView: WKWebView?
    
    var newsID: String?
    fileprivate var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView?.navigationDelegate = self
        view = webView
    }
    
    fileprivate func reloadPage() {
        if let html = news?.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func requestData() {
        MBProgressHUD.loading(view: view)
        let param = NewsParameter()
        param.newsID = newsID
        let req: Promise<NewsDetailData> = handleRequest(Router.endpoint( NewsPath.detail, param: param), needToken: .default)
        req.then { (value) -> Void in
            self.news = value.data
            self.reloadPage()
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        guard let vc = R.storyboard.main.shareViewController() else {return}
        vc.sharePage = .headlineDetail
        vc.shareID = newsID
        vc.completeHandle = { [weak self] result in
            self?.dim(.out)
            self?.dismiss(animated: true, completion: nil)
        }
        dim(.in)
        present(vc, animated: true, completion: nil)
    }

}

extension NewsDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let str = "document.getElementsByClassName('headline')[0].style.fontSize = '21px';"
        _ = webView.evaluateJavaScript(str, completionHandler: nil)
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let URL = navigationAction.request.url else {
            return
        }
        //Navigator.open(URL)
        UIApplication.shared.openURL(URL)
        decisionHandler(.allow)
    }
    
}

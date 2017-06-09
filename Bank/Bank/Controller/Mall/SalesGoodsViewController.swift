//
//  SalesGoodsViewController.swift
//  Bank
//
//  Created by yang on 16/2/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import WebKit
import MBProgressHUD

class SalesGoodsViewController: BaseViewController {

    fileprivate var selectedGoods: Goods!
    fileprivate var onlineEvent: OnlineEvent?
    fileprivate var selectedURL: URL?
    fileprivate var webView: WKWebView?
    var eventID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        requestDetailData()
        webView?.navigationDelegate = self
    }
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        view = webView
    }

    fileprivate func loadWebView() {
        if let html = onlineEvent?.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func requestDetailData() {
        MBProgressHUD.loading(view: view)
        let param = OnlineEventParameter()
        param.eventID = eventID
        let req: Promise<EventDetailData> = handleRequest(Router.endpoint(OnlineEventPath.detail, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let event = value.data {
                self.title = event.title
                self.onlineEvent = event
                self.loadWebView()
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        guard let vc = R.storyboard.main.shareViewController() else {return}
        vc.sharePage = .onlineEventDetail
        vc.shareID = eventID
        vc.completeHandle = { [weak self] result in
            self?.dim(.out)
            self?.dismiss(animated: true, completion: nil)
        }
        dim(.in)
        present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods.goodsID
        }
    }
}

extension SalesGoodsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            Navigator.openInnerURL(url)
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBProgressHUD.hide(for: view, animated: true)
    }

}

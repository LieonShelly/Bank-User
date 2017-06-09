//
//  PrizeDetailViewController.swift
//  Bank
//
//  Created by yang on 16/7/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import WebKit
import MBProgressHUD

class PrizeDetailViewController: BaseViewController {

    @IBOutlet fileprivate weak var buyButton: UIButton!
    @IBOutlet fileprivate weak var buttonHeight: NSLayoutConstraint!
    var giftID: String?
    fileprivate var webView: WKWebView?
    fileprivate var prize: Prize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.prize?.goodsID
        }
        
        if let vc = segue.destination as? BrandDetailViewController {
            vc.merchantID = self.prize?.merchantID
        }
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
            make.bottom.equalTo(buyButton.snp.top).offset(0)
        })
    }
    
    fileprivate func configUI() {
        if prize?.goodsID == "0" {
            buttonHeight.constant = 0
        } else {
            buttonHeight.constant = 60
        }
    }
    
    fileprivate func loadWebView() {
        if let html = prize?.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    fileprivate func requestData() {
        let param = GiftParameter()
        if let giftID = self.giftID {
            param.giftID = Int(giftID)
        }
        MBProgressHUD.loading(view: view)
        let req: Promise<PrizeDetailData> = handleRequest(Router.endpoint(GiftPath.giftDetail, param: param))
        req.then { [weak self] (value) -> Void in
                self?.prize = value.data
                self?.loadWebView()
            }.always {
//                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    //跳转商品详情页
    @IBAction func buyNowAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: R.segue.prizeDetailViewController.showGoodsDetailVC, sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - WKNavigationDelegate
extension PrizeDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            Navigator.openInnerURL(url)
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.configUI()
        MBProgressHUD.hide(for: view, animated: true)
    }
}

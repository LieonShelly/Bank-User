//
//  OfflineEventDetailViewController.swift
//  Bank
//
//  Created by yang on 16/4/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import WebKit
import MBProgressHUD

class OfflineEventDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var button: UIButton!
    @IBOutlet weak fileprivate var shareBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    
    fileprivate var webView: WKWebView?
    fileprivate var height: CGFloat = 0
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.view.bounds, type: .offlineEventDetail)}()
    
    var eventID: String?
    var event: OfflineEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        button.isEnabled = false
        requestData()
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
            make.bottom.equalTo(button.snp.top).offset(0)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 加载网页
    fileprivate func loadWebView() {
        guard let ad = event else {
            return
        }
        if let html = ad.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    /// 设置UI
    fileprivate func configUI() {
        if let status = event?.status {
            button.setTitle(status.title, for: UIControlState())
            button.isEnabled = status.enable
            if button.isEnabled {
                button.backgroundColor = UIColor.orange
            } else {
                button.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    /// 请求活动详情
    fileprivate func requestData() {
        guard let eID = eventID else {
            return
        }
        let hud = MBProgressHUD.loading(view: self.view)
        let param = OfflineEventParameter()
        param.eventID = eID
        let req: Promise<OfflineEventDetailData> = handleRequest(Router.endpoint( OfflineEventPath.detail, param: param), needToken: .default)
        req.then { (value) -> Void in
            self.event = value.data
            self.loadWebView()
            if self.event?.isApproved == true {
                self.shareBarButtonItem.image = R.image.mall_brandZone_btn_more_menu()
                self.height = 60
            } else {
                self.shareBarButtonItem.image = nil
                self.height = 0
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 请求报名/取消报名
    ///
    /// - Parameter sign: true:报名，false:取消报名
    fileprivate func requestSign(_ sign: Bool) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        guard let eID = eventID else { return }
        MBProgressHUD.loading(view: view)
        let param = OfflineEventParameter()
        param.eventID = eID
        var router = OfflineEventPath.signIn
        if !sign {
            router = OfflineEventPath.signOut
        }
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( router, param: param))
        req.then { (value) -> Void in
            if sign == true {
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_sign_success())
                self.event?.status = .signedUp
                self.button.setTitle(R.string.localizable.alertTitle_cancel_sign(), for: .normal)
            } else {
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_cancel_success())
                self.event?.status = .enrolling
                self.button.setTitle(R.string.localizable.alertTitle_now_sign(), for: .normal)
            }
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        guard let offline = event, let status = offline.status else {
            return
        }
        if case .signedUp = status {
            // 取消报名
            showAlertView(R.string.localizable.alertTitle_is_cancel_sign())
        }
        if case .enrolling = status {
            // 报名
            requestSign(true)
        }
    }
    
    fileprivate func showAlertView(_ message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.requestSign(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /// 分享
    ///
    /// - Parameter sender: UIBarButtonItem
    @IBAction func shareAction(sender: UIBarButtonItem) {
        
        let menuView = MenuView(frame: UIScreen.main.bounds)
        navigationController?.view.addSubview(menuView)
        menuView.imagesArray = [R.image.btn_help1(), R.image.mall_brandZone_icon_share_menu()]
        menuView.dataSorceArray = ["帮助", "分享"]
        menuView.menuTableView.frame = CGRect(x: self.view.bounds.width - 105, y: 60, width: 95, height: 80)
        menuView.showTableView()
        menuView.actionBlock = { index in
            switch index {
            case 0:
                //帮助
                guard let vc = R.storyboard.center.helpCenterHomeViewController() else {
                    return
                }
                vc.tag = HelpCenterTag.offlineEventDetail
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                guard let vc = R.storyboard.main.shareViewController() else {return}
                vc.sharePage = .offlineEventDetail
                vc.shareID = self.eventID
                vc.completeHandle = { [weak self] result in
                    self?.dim(.out)
                    self?.dismiss(animated: true, completion: nil)
                }
                self.dim(.in)
                self.present(vc, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
}

extension OfflineEventDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlString = String(describing: url)
            if urlString.contains("tel") {
                let tel = NSString(string: urlString).substring(from: 4)
                setTelAlertViewController(tel)
                decisionHandler(.cancel)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.loading(view: view)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.configUI()
        buttonHeight.constant = height
        MBProgressHUD.hide(for: view, animated: true)
    }
}

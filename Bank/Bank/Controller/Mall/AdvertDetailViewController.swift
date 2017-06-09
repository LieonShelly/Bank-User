//
//  AdvertDetailViewController.swift
//  Bank
//
//  Created by yang on 16/2/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import WebKit
import ObjectMapper
import MBProgressHUD

class AdvertDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var button: UIButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
    
    var advertID: String?
    
    fileprivate var webView: WKWebView?
    fileprivate var advertise: Advert?
    fileprivate var time = 10
    fileprivate var theTimer: Timer!
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.view.bounds, type: .advertDetail)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        requestData()
        button.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 加载webView
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
    
    /// 加载网页
    fileprivate func loadWebView() {
        guard let ad = advertise else {
            return
        }
        
        if let html = ad.html {
            _ = webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    /// 设置UI
    fileprivate func configUI() {
        button.backgroundColor = UIColor(hex: 0xa0a0a0)
        if advertise?.isJoin == true {
            buttonHeight.constant = 60
            titleLabel.text = R.string.localizable.label_title_end_answer()
        } else if advertise?.isPointOut == true {
            buttonHeight.constant = 60
            titleLabel.text = R.string.localizable.label_title_begin_answer()
            button.isEnabled = true
            button.backgroundColor = UIColor(hex: 0xfc8d25)
            titleLabel.textColor = UIColor.white
        } else if advertise?.isClosed == true {
            // 广告无法查看
            self.view.addSubview(noneView)
            moreBarButtonItem.image = nil
        } else {
            buttonHeight.constant = 60
            timerStart()
        }
    }
    
    func timerStart() {
        titleLabel.text = "\(time)秒后开始答题"
        theTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(theTimer, forMode: RunLoopMode.commonModes)
    }
    
    func timerAction() {
        time -= 1
        titleLabel.text = "\(time)秒后开始答题"
        button.isEnabled = false
        if time == 0 {
            timerEnd()
        }
    }
    
    func timerEnd() {
        theTimer.invalidate()
        theTimer = nil
        titleLabel.text = R.string.localizable.label_title_begin_answer()
        button.isEnabled = true
        button.backgroundColor = UIColor(hex: 0xfc8d25)
        titleLabel.textColor = UIColor.white
    }
    
    /// 请求广告详情
    func requestData() {
        guard let adID = advertID else {
            return
        }
        let hud = MBProgressHUD.loading(view: view)
        let param = AdvertiseParameter()
        param.adID = adID
        let req: Promise<AdvertDetailData> = handleRequest(Router.endpoint(AdvertisePath.detail, param: param), needToken: .default)
        req.then { (value) -> Void in
            if self.advertise == nil {
                self.advertise = value.data
                self.loadWebView()
            } else {
                self.advertise = value.data
            }
        }.always {
            hud.hide(animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        if advertise?.isPointOut == true {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_advert_pointout())
        } else {
            performSegue(withIdentifier: R.segue.advertDetailViewController.showQuestionVC, sender: nil)
        }
    
    }
    
    @IBAction func shareAction(sender: UIBarButtonItem) {
        
        let menuView = MenuView(frame: UIScreen.main.bounds)
        navigationController?.view.addSubview(menuView)
        menuView.imagesArray = [R.image.btn_help1(), R.image.mall_brandZone_icon_share_menu(), R.image.ad_icon_shop()]
        menuView.dataSorceArray = ["帮助", "分享", "店铺"]
        menuView.menuTableView.frame = CGRect(x: self.view.bounds.width - 105, y: 60, width: 95, height: 120)
        menuView.showTableView()
        menuView.actionBlock = { index in
            switch index {
            case 0:
                //帮助
                guard let vc = R.storyboard.center.helpCenterHomeViewController() else {
                    return
                }
                vc.tag = HelpCenterTag.adDetail
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                guard let vc = R.storyboard.main.shareViewController() else {return}
                vc.sharePage = .adAnswer
                vc.shareID = self.advertID
                vc.completeHandle = { [weak self] result in
                    
                    self?.dim(.out)
                    self?.dismiss(animated: true, completion: nil)
                }
                self.dim(.in)
                self.present(vc, animated: true, completion: nil)
            case 2:
                guard let vc = R.storyboard.mall.brandDetailViewController() else { return }
                vc.merchantID = self.advertise?.merchantID
                Navigator.push(vc)
            default:
                break
            }
        }

    }
    
    @IBAction func unwindFromAnswer(_ segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AnswerQuestionViewController {
            vc.advertiseID = advertID
            vc.advertise = advertise
        }
    }
    
    fileprivate func showAlertController(title: String, message: String, url: URL) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            Navigator.openInnerURL(url)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - WKNavigationDelegate
extension AdvertDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let URL = navigationAction.request.url else {
            return
        }
        
        if URL.scheme == Const.URLScheme {
            guard let string = URL.host?.removingPercentEncoding else { return }
            guard let baseModel = Mapper<BaseInnerURLData>().map(JSONString: string), let action = baseModel.action else { return }
            switch action {
            case .showPlayVideo:
                guard let status = AppConfig.shared.networkListener?.networkReachabilityStatus else { return }
                switch status {
                case .unknown:
                    break
                case .notReachable:
                    break
                case .reachable(.ethernetOrWiFi):
                    Navigator.openInnerURL(URL)
                case .reachable(.wwan):
                    showAlertController(title: "", message: R.string.localizable.alertTitle_cant_integral_deposit(), url: URL)
                }
                decisionHandler(.cancel)
            case .openURL:
                 Navigator.openInnerURL(URL)
                decisionHandler(.cancel)
            default:
                break
            }
            
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.configUI()
//        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        MBProgressHUD.loading(view: view)
    }
}

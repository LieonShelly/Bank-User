//
//  InputCodeViewController.swift
//  Bank
//
//  Created by kilrae on 2017/4/18.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import MBProgressHUD
import PromiseKit
import URLNavigator

class InputCodeViewController: BaseTableViewController {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    var mobile: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        textView.delegate = self
        guard let tel = AppConfig.shared.baseData?.serviceHotLine else {
             return
        }
        let string: NSString = "拨打\(tel)获取验证码" as NSString
        let attributStr = NSMutableAttributedString(string: String(string))
        let strRange = NSRange(location: 0, length: attributStr.length)
        let phoneRange = string.range(of: tel)
        attributStr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15), range: strRange)
        attributStr.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x666666), range: strRange)
        attributStr.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: phoneRange)
        attributStr.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x00a8fe), range: phoneRange)
        textView.attributedText = attributStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 17
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        view.endEditing(true)
        if codeTextField.text?.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_please_write_code())
        } else {
            requestUpdateNewData()
        }
    }
    
    /// 登记新手机号
    fileprivate func requestUpdateNewData() {
        let hud = MBProgressHUD.loading(view: view)
        let param = UserParameter()
        param.mobile = mobile
        param.smsCode = codeTextField.text
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.updateNew, param: param))
        req.always {
            hud.hide(animated: true)
            }.then { (value) -> Void in
                self.showAlert()
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.localizedDescription)
                }
        }
    }
    
    fileprivate func logout() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.logout, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let delegate = UIApplication.shared.delegate as? AppDelegate, let containerVC = delegate.containerVC {
                    containerVC.logout(isNeedLogin: true)
                }
                // 用户登出，将指纹是否开启标志置为false
                UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            }
            }.always {
                // 手动退出
                AppConfig.shared.rememberAccountStatus = RememberAccountType.manualQuitAccount
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func showAlert() {
        let alert = UIAlertController(title: "", message: "登录手机号已成功更改为\(mobile)，需要重新登录", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.logout()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UITextViewDelegate
extension InputCodeViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let telString = String(describing: URL)
        let tel = telString.deleteWith("tel:")
        setTelAlertViewController(tel)
        return false
    }
    
    @available(iOS 10, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
}

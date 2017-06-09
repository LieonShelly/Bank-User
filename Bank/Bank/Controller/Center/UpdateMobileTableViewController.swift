//
//  UpdateMobileTableViewController.swift
//  Bank
//
//  Created by 杨锐 on 2017/2/13.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import ObjectMapper
import Device

class UpdateMobileTableViewController: BaseTableViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var codeButton: CodeButton!
    @IBOutlet weak var progressImageView: UIImageView!
    
    var oldToken: String?
    
    fileprivate var newToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileTextField.delegate = self
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
        self.codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
        self.codeButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    /// 获取验证码
    @IBAction func getCodeAction(_ sender: UIButton) {
        if mobileTextField.text?.characters.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: "手机号为空")
        } else {
            sendNewCode()
        }
    }

    /// 确定
    @IBAction func confiromAction(_ sender: UIButton) {
        if mobileTextField.text?.characters.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: "手机号为空")
        } else if codeTextField.text?.characters.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: "验证码为空")
        } else {
            updateMobile()
        }
    }
    
    func showAlertController() {
        guard let mobile = mobileTextField.text else {
            return
        }
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: "登录手机号已成功更改为\(mobile)，需要重新登录", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
                self.requestLogout()
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension UpdateMobileTableViewController {
    /// 发送新手机号的验证码
    func sendNewCode() {
        self.codeButton.starTime()
        let param = UserParameter()
        param.mobile = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
        param.token = self.oldToken
        MBProgressHUD.loading(view: view)
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint(UserPath.sendNewCode, param: param))
        req.then { (value) -> Void in
            self.newToken = value.data?.token
            self.codeTextField.text = value.msg
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 修改登录手机号
    func updateMobile() {
        let param = UserParameter()
        param.mobile = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
        param.smsCode = codeTextField.text
        param.token = self.newToken
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.updateNewMobile, param: param))
        req.then { (value) -> Void in
            // Success
            self.showAlertController()
            // 如果当前手机号启用了指纹登录，则清空指纹登录信息
            // 更新存贮在本地的账号信息
            if var sessions = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.sessionsKey) as? [String] {
                
                for (index, sessionString) in zip(sessions.indices, sessions) {
                    if let data = Data(base64Encoded: sessionString, options: [.ignoreUnknownCharacters]), let base64Str = String(data: data, encoding: String.Encoding.utf8) {
                        if let session = Mapper<FingerLoginSession>().map(JSONString: base64Str) {
                            if session.mobile == AppConfig.shared.keychainData.getMobile() {
                                sessions.remove(at: index)
                            }
                        }
                    }
                    
                }
                UserDefaults.standard.set(sessions, forKey: CustomKey.UserDefaultsKey.sessionsKey)
            }
            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 退出
    fileprivate func requestLogout() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.logout, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let delegate = UIApplication.shared.delegate as? AppDelegate, let containerVC = delegate.containerVC {
                    containerVC.logout(isNeedLogin: true)
                }
                // 用户登出，将指纹是否开启标志置为false
                UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: - UITextFieldDelegate
extension UpdateMobileTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isTrue = validatePhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
        if textField.text?.characters.count >= 13 {
            self.codeButton.backgroundColor = UIColor(hex: 0x00A8FE)
            self.codeButton.isEnabled = true
        } else {
            self.codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
            self.codeButton.isEnabled = false
        }
        return isTrue
    }
}

//
//  FingerLoginTableViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/9/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import LocalAuthentication
import PromiseKit
import ObjectMapper
import MBProgressHUD

class FingerLoginTableViewController: BaseTableViewController {

    @IBOutlet fileprivate weak var fingerSwich: UISwitch!
    
    weak var containerController: ContainerViewController?
    fileprivate var loginPass: String?
    fileprivate var fingerPass: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let isOpen = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.isOpenFinger) as? Bool else {
            fingerSwich.isOn = false
            return
        }
        fingerSwich.isOn = isOpen
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    @IBAction func fingerSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            // 输入登录密码
            self.showAlertController()
        } else {
            showAlertWithAction(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_is_close_finger(), cancelHandler: {
                sender.isOn = true
                }, closeHandler: {
                    self.requesetCloseFinger()
            })
        }
    }
    
    fileprivate func showAlertWithAction(title: String, message: String, cancelHandler: (() -> Void)?, closeHandler: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .default, handler: { (action) in
            if let block = cancelHandler {
                block()
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_close(), style: .cancel, handler: { action in
            if let block = closeHandler {
                block()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /// 指纹验证
    fileprivate func configTouchID() {
        let authenticationContext = LAContext()
        authenticationContext.localizedFallbackTitle = ""
        var error: NSError?
        let canUseTouchID = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if canUseTouchID {
                authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: R.string.localizable.titleLabel_title_test_home_id(), reply: { (success, theError) in
                    if success {
                        DispatchQueue.main.async(execute: {
                            
                            // 存储指纹登录信息
                            let session = FingerLoginSession()
                            session.userID = AppConfig.shared.userInfo?.userID
                            session.password = self.fingerPass
                            session.mobile = AppConfig.shared.keychainData.getMobile()
                            session.isOpenFinger = true
                            guard let string = Mapper().toJSONString(session) else { return }
                            AppConfig.shared.keychainData.fingerLogin = string
                            guard let base64Str = string.toBase64() else { return }
                            // 寻找存储在本地的账号信息
                            var sessions = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.sessionsKey) as? [String]
                            if sessions != nil {
                                if let count = sessions?.count {
                                    if count >= 5 {
                                         sessions?.remove(at: 0)
                                    }
                                    sessions?.append(base64Str)
                                }
                            } else {
                                sessions = [base64Str]
                            }
                            UserDefaults.standard.set(sessions, forKey: CustomKey.UserDefaultsKey.sessionsKey)
                            // 开启指纹后不需要再引导开启指纹
                            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isNeedFinger)
                            // 设置是否开启指纹标识
                            UserDefaults.standard.set(true, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
                            
                            self.fingerSwich.isOn = true
                            if self.containerController != nil {
                                self.loginSuccessHandle()
                            } else {
                                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_open_success())
                            }
                        })
                    } else {
                        guard let err = theError as? LAError else {
                              return
                        }
                        switch err.code {
                        /// 授权失效
                        case .authenticationFailed:
                            DispatchQueue.main.async(execute: {
                                self.fingerSwich.isOn = false
                                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_finger_no_match())
                            })
                        /// 多次指纹校验失败, 需要输入手机密码解锁
                        case .touchIDLockout:
                            DispatchQueue.main.async(execute: {
                                authenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: R.string.localizable.titleLabel_title_test_home_id(), reply: { [weak self](success, theError) in
                                    
                                    DispatchQueue.main.async(execute: {
                                        self?.fingerSwich.isOn = false
                                        if success {
                                            self?.configTouchID()
                                        }
                                    })
                                    })
                            
                            })

                        default :
                            DispatchQueue.main.async(execute: {
                                self.fingerSwich.isOn = false
                            })
                        }
                    }
                })
            
        } else {
            guard let err = error as? LAError else {
                return
            }
            switch err.code {
            case .touchIDLockout:
                authenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: R.string.localizable.titleLabel_title_test_home_id(), reply: { [weak self](success, theError) in
                        
                        DispatchQueue.main.async(execute: {
                            self?.fingerSwich.isOn = false
                            if success {
                                self?.configTouchID()
                            }
                            
                        })
                    })
            default:
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_equipment_no_user_touchID())
            }
            fingerSwich.isOn = false
        }

    }
    
    /// 登录处理成功
    func loginSuccessHandle() {
        AppConfig.shared.isLoginFlag = true
        containerController?.successLogin()
    }
    
    /// 登录密码弹框
    fileprivate func showAlertController() {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_please_input_password(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: { (action) in
            self.fingerSwich.isOn = false
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.loginPass = alert.textFields?[0].text
            self.requesetOpenFinger()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /// 随机生成16位指纹登录密码
    ///
    /// - returns: 返回指纹登录密码
    fileprivate func createPass() -> String? {
        var data: [Character] = []
        for _ in 0..<16 {
            var charInt: UInt32 = 0
            let x = arc4random() % 3
            if x == 0 {
                charInt = 65 + arc4random_uniform(26)
            } else if x == 1 {
                charInt = 97 + arc4random_uniform(26)
            } else {
                charInt = 48 + arc4random_uniform(10)
            }
            if let unicode = UnicodeScalar(charInt) {
                data.append(Character(unicode))
            }
        }
        return String(data)

    }
}

// MARK: - Request
extension FingerLoginTableViewController {
    
    /// 开启指纹登录
    func requesetOpenFinger() {
        let deviceUUID = AppConfig.shared.keychainData.deviceUUID
        fingerPass = createPass()
        let param = FingerParameter()
        param.loginPass = loginPass
        param.fingerPass = fingerPass
        param.deviceUUID = deviceUUID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(FingerPath.open, param: param))
        req.then { (value) -> Void in
            self.configTouchID()
            }.catch { (error) in
                self.fingerSwich.isOn = false
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    /// 关闭指纹登录
    func requesetCloseFinger() {
        let deviceUUID = AppConfig.shared.keychainData.deviceUUID
        let param = FingerParameter()
        param.deviceUUID = deviceUUID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(FingerPath.close, param: param))
        req.then { (value) -> Void in
            // 主动关闭指纹后不再引导设置指纹
            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isNeedFinger)
            
            // 删除本地保存的指纹登录信息
            //AppConfig.shared.keychainData.fingerLogin = "0"
            
            // 更新存贮在本地的账号信息
            if var sessions = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.sessionsKey) as? [String] {
                
                for index in 0..<sessions.count {
                    guard let data = Data(base64Encoded: sessions[index], options: [.ignoreUnknownCharacters]), let base64Str = String(data: data, encoding: .utf8), let session = Mapper<FingerLoginSession>().map(JSONString: base64Str) else { continue }
                    if session.mobile == AppConfig.shared.keychainData.getMobile() {
                        sessions.remove(at: index)
                    }
                }
                UserDefaults.standard.set(sessions, forKey: CustomKey.UserDefaultsKey.sessionsKey)
            }
            
            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            self.fingerSwich.isOn = false
            }.catch { (error) in
                self.fingerSwich.isOn = true
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }

}

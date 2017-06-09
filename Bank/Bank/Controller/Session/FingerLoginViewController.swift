//
//  FingerLoginViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/9/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import LocalAuthentication
import URLNavigator
import ObjectMapper
import PromiseKit
import MBProgressHUD

class FingerLoginViewController: BaseViewController {

    @IBOutlet fileprivate weak var phoneLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var footerView: UIView!
    
    weak var containerController: ContainerViewController?
    
    fileprivate var userName: String?
    fileprivate var password: String?
    fileprivate var deviceUUID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        footerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 64)
        tableView.tableFooterView = footerView
        title = R.string.localizable.controller_title_load()
        phoneLabel.text = AppConfig.shared.keychainData.getMobile().replaceWith(range: NSRange(location: 3, length: 4))
        confingTouchID()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func confingTouchID() {
        let authenticationContext = LAContext()
        var error: NSError?
        let canUseTouchID = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if canUseTouchID == true {

            authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: R.string.localizable.titleLabel_title_test_home_id(), reply: { (success, error) in
                if success {
                    DispatchQueue.main.async(execute: {
                        
                        guard let sessions = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.sessionsKey) as? [String] else {
                            return
                        }
                        
                        for session in sessions {
                            if let data = Data(base64Encoded: session, options: [.ignoreUnknownCharacters]), let string = String(data: data, encoding: String.Encoding.utf8) {
                                guard let object = Mapper<FingerLoginSession>().map(JSONString: string) else {
                                    return
                                }
                                if object.mobile == AppConfig.shared.keychainData.getMobile() {
                                    self.userName = object.mobile
                                    self.password = object.password
                                    self.loginAction()
                                }
                            }
                        }
                    })
                } else {
                    guard let err = error as? LAError else {
                        return
                    }
                    switch err.code {
                    /// 授权失效
                    case .authenticationFailed:
                        DispatchQueue.main.async(execute: {
                            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_finger_no_match())
                        })
                    /// 多次指纹校验失败, 需要输入密码解锁
                    case .touchIDLockout:
                        DispatchQueue.main.async(execute: {
                            authenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: R.string.localizable.titleLabel_title_test_home_id(), reply: { [weak self](success, theError) in
                                DispatchQueue.main.async(execute: {
                                    if success {
                                        self?.confingTouchID()
                                    }
                                })
                                })
                            
                        })
                    /// 用户选择输入密码
                    case .userFallback:
                        DispatchQueue.main.async(execute: {
                            self.switchLoginAction(nil)
                        })
                        break
                    default :
                        break
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
                        if success {
                            self?.confingTouchID()
                        }
                    })
                })
            default:
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_equipment_no_user_touchID())
            }
        }
    }
    
    /// 指纹登录
    fileprivate func loginAction() {
        MBProgressHUD.loading(view: view)
        deviceUUID = AppConfig.shared.keychainData.deviceUUID
        let param = FingerParameter()
        param.mobile = userName
        param.fingerPass = password
        param.deviceUUID = deviceUUID
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint(FingerPath.login, param: param), needToken: .false)
        req.then { (value) -> Void in
            // 保存 token
//            AppConfig.shared.userInfo = value.data
            AppConfig.shared.keychainData.sessionToken = value.data?.token
            AppConfig.shared.keychainData.mobile = self.userName
            self.loginSuccessHandle()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: false)
            }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    /// 登录处理成功
    func loginSuccessHandle() {
        AppConfig.shared.isLoginFlag = true
        containerController?.successLogin()
    }
    
    /// 指纹登录
    @IBAction func fingerLoginAction(_ sender: UIButton) {
        confingTouchID()
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        confingTouchID()
    }

    /// 切换登录方式
    @IBAction func switchLoginAction(_ sender: UIButton?) {
        guard let vc = R.storyboard.session.loginViewController() else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
        vc.containerController = containerController
        AppConfig.shared.rememberAccountStatus = .manualQuitAccount
    }
    
    /// 注册
    @IBAction func registerAction(_ sender: UIButton) {
        guard let vc = R.storyboard.session.registerViewController() else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
        vc.containerController = containerController
    }
    
    @IBAction func unwindFromRegister(_ segue: UIStoryboardSegue) {
        
    }

}

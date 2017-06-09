//
//  LoginViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/23.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable empty_count

import UIKit
import Alamofire
import URLNavigator
import PromiseKit
import ObjectMapper
import LocalAuthentication
import MBProgressHUD

class LoginViewController: BaseTableViewController {
    
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var captchaTextField: UITextField!
    @IBOutlet fileprivate weak var captchaImageView: UIImageView!
    
    fileprivate var sectionCount: Int = 2
    fileprivate var session = SessionAccount()
    fileprivate var changedSession: Bool = false
    var dismissHandle: ((Bool) -> Void)?
    
    weak var containerController: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if sectionCount == 3 {
            captcha()
        }
        helpHtmlName = "help"
        mobileTextField.delegate = self
        mobileTextField.tag = 0
        passwordTextField.tag = 1
        captchaTextField.tag = 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sectionCount = 2
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        displayAccount()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 登录
    @IBAction func loginHandle() {
        view.endEditing(true)
        MBProgressHUD.loading(view: tableView)
        validInputs().then { (param) -> Promise<GetUserInfoData> in
            self.session.mobile = param.mobile
            self.session.password = param.password
            return handleRequest(Router.endpoint(UserPath.login, param: param), needToken: .false)
            }.then { (value) -> Void in
                // 如果新登录的账号和之前的账号不同, 关闭指纹登录
//                if self.session.mobile != AppConfig.shared.keychainData.getMobile() {
//                    UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
//                }

                // 保存 token
                AppConfig.shared.userInfo = value.data
                AppConfig.shared.keychainData.sessionToken = value.data?.token
                AppConfig.shared.keychainData.mobile = self.session.mobile

                guard let string = Mapper().toJSONString(self.session) else { return }
                AppConfig.shared.keychainData.loginSession = string
                
                // 如果没有设置支付密码，引导设置支付密码
                if let isSet = value.data?.isSetPayPassword {
                    UserDefaults.standard.set(isSet, forKey: CustomKey.UserDefaultsKey.isPaypassSet)
                } else {
                    UserDefaults.standard.removeObject(forKey: CustomKey.UserDefaultsKey.isPaypassSet)
                }
                if let isSigned = value.data?.isSigned {
                    AppConfig.shared.isUserSigned = isSigned
                } else {
                    UserDefaults.standard.removeObject(forKey: CustomKey.UserDefaultsKey.isSigned)
                }
                
                self.loginSuccessHandle()
            }.always {
                self.passwordTextField.text = ""
                MBProgressHUD.hide(for: self.tableView, animated: false)
            }.catch { (error) in
                if let err = error as? AppError {
                    
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    if let code = err.errorCode as? RequestErrorCode {
                        if code == RequestErrorCode.wrongIDPass || code == RequestErrorCode.imageCaptchaError || code == RequestErrorCode.iamgeCaptchaEmpty {
                        self.sectionCount = 3
                        self.tableView.reloadData()
                        self.captcha()
                        }
                
                    }
                }
        }
    }
    
    @IBAction func leftHandle() {
        if let block = dismissHandle {
            block(false)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshCaptcha() {
        captcha()
    }
    
    @objc fileprivate func textChanged(_ sender: Foundation.Notification) {
        guard let textField = sender.object as? UITextField else { return }
        if textField.tag == 0 || textField.tag == 1 {
            AppConfig.shared.keychainData.sessionToken = nil
        }
    }
    
    fileprivate func captcha() {
        guard let mobile = mobileTextField.text?.stringByRemovingCharactersInSet(CharacterSet.whitespaces), mobile.characters.count == 11 else { return }
        let param = HomeBasicParameter()
        param.mobile = mobile
        let req: Promise<ImageCaptchaData> = handleRequest(Router.endpoint( HomeBasicPath.captcha, param: param), needToken: .false)
        req.then { (value) -> Void in
            guard let string = value.data?.imageData, let imageData = Data(base64Encoded: string, options: [.ignoreUnknownCharacters]), let image = UIImage(data: imageData) else {
                return
            }
            self.captchaImageView.image = image
            self.captchaTextField.text = nil
            }.catch { _ in }
    }
    
    fileprivate func validInputs() -> Promise<UserParameter> {
        return Promise { fulfill, reject in
            if let mobile = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces), mobile.characters.count == 11,
                let password = passwordTextField.text, !password.isEmpty {
                let param = UserParameter()
                param.mobile = mobile
                param.password = password
                if sectionCount == 3 {
                    if let captcha = captchaTextField.text, !captcha.isEmpty {
                        param.captcha = captcha
                    } else {
                        let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                        reject(error)
                    }
                }
                fulfill(param)
            } else {
                let mobileText = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
                if mobileText?.characters.count == 0 {
                    let error = AppError(code: ValidInputsErrorCode.emptyAccount, msg: nil)
                    reject(error)
                } else if passwordTextField.text?.characters.count == 0 {
                    let error = AppError(code: ValidInputsErrorCode.emptyPass, msg: nil)
                    reject(error)
                } else {
                    let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                    reject(error)
                }
            }
        }
    }
    
    /// 登录处理成功
    func loginSuccessHandle() {
        containerController?.successLogin()
        dismiss(animated: true, completion: nil)
        if let block = dismissHandle {
            block(true)
        }
    }
    
    fileprivate func displayAccount() {
       let type =  AppConfig.shared.getRememberAccountType()
        if type != RememberAccountType.normalStatus {
            mobileTextField.text = AppConfig.shared.keychainData.getMobile().toPhoneString()
        }
    }
    
    @IBAction func unwindFromRegister(_ segue: UIStoryboardSegue) {
        
    }
    
    /// 引导开启指纹登录
//    fileprivate func showFingerAlertController() {
//        let alert = UIAlertController(title: R.string.localizable.alertTitle_open_finger_load(), message: R.string.localizable.alertTitle_open_touchID(), preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .default, handler: { (action) in
//            // 拒绝引导设置指纹
//            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isNeedFinger)
//            self.loginSuccessHandle()
//        }))
//        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_set(), style: .default, handler: { (action) in
//            guard let vc = R.storyboard.setting.fingerLoginTableViewController() else { return }
//            vc.containerController = self.containerController
//            self.navigationController?.pushViewController(vc, animated: true)
//        }))
//        present(alert, animated: true, completion: nil)
//    }
    
    /// 设置引导指纹登录
//    fileprivate func setIsNeedFinger() {
//        if var mobiles = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.mobilesKeys) as? [String?] {
//            // 还需要判断当前登录的账号时候已经存储到本地中，如果本地没有记录当前账号，则引导当前账号开启指纹登录
//            if mobiles.contains(where: { (mobile) -> Bool in
//                if mobile == self.session.mobile {
//                    return true
//                }
//                return false
//            }) == false {
//                // 需要引导指纹登录
//                UserDefaults.standard.set(true, forKey: CustomKey.UserDefaultsKey.isNeedFinger)
//                mobiles.append(self.session.mobile)
//                UserDefaults.standard.set(mobiles, forKey: CustomKey.UserDefaultsKey.mobilesKeys)
//            } else {
//                // 不需要引导指纹登录
//                UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isNeedFinger)
//            }
//            
//        } else {
//            UserDefaults.standard.set([self.session.mobile], forKey: CustomKey.UserDefaultsKey.mobilesKeys)
//            UserDefaults.standard.set(true, forKey: CustomKey.UserDefaultsKey.isNeedFinger)
//        }
//    }
    
    /// 设置开启指纹登录
//    fileprivate func setIsOpenFinger() {
//        if let sessions = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.sessionsKey) as? [String] {
//            // 还需要判断当前登录的账号是否开启了指纹登录
//            if sessions.contains(where: { (string) -> Bool in
//                if let data = Data(base64Encoded: string, options: [.ignoreUnknownCharacters]), let base64Str = String(data: data, encoding: String.Encoding.utf8) {
//                    guard let object = Mapper<FingerLoginSession>().map(JSONString: base64Str) else {
//                        return false
//                    }
//                    if object.mobile == self.session.mobile {
//                        return true
//                    }
//                }
//                return false
//            }) == false {
//                // 没有开启指纹登录
//                UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
//            } else {
//                // 开启了指纹登录
//                UserDefaults.standard.set(true, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
//            }
//        } else {
//            // 没有开启指纹登录
//            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == R.segue.loginViewController.showRegisterVC.identifier {
            if let vc = segue.destination as? RegisterViewController {
                vc.containerController = self.containerController
            }
        }
        if let vc = segue.destination as? HelpViewController {
            var string = WebViewURL.doc.URL()
            string.append("?type=101")
            guard let aboutURL = URL(string: string) else { return }
            vc.title = R.string.localizable.controller_title_about_us()
            vc.loadURL(aboutURL)
        }
    }
    
}

extension LoginViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (sectionCount - 1) {
            return 17.0
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 17.0
        } else {
            return 10.0
        }
    }
}

extension LoginViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
}

extension LoginViewController: UITextFieldDelegate {
    // MARK: Text Field Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return validatePhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}

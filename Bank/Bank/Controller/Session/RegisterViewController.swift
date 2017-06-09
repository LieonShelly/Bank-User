//
//  RegisterViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/23.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import ObjectMapper

class RegisterViewController: BaseTableViewController {
    
    @IBOutlet weak var codeButton: CodeButton!
    @IBOutlet fileprivate weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var smsCodeTextField: UITextField!
    @IBOutlet fileprivate weak var checkButton: UIButton!
    @IBOutlet fileprivate weak var registerButton: UIButton!
    
    weak var containerController: ContainerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        mobileTextField.delegate = self
        checkButton.setBackgroundImage(R.image.btn_check1(), for: .normal)
        checkButton.setBackgroundImage(R.image.bank_check(), for: .selected)
        checkButton.isSelected = true
        codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
        codeButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 注册
    @IBAction func registerHandle() {
        let loginParam = UserParameter()
        MBProgressHUD.loading(view: self.view)
        validInputs().then { (param) -> Promise<GetUserInfoData> in
            loginParam.mobile = param.mobile
            loginParam.password = param.password
            loginParam.smsCode = param.smsCode
            return handleRequest(Router.endpoint(UserPath.register, param: loginParam), needToken: .false)
        }.then { (value) -> Void in
            // register success
            // pay pass
            AppConfig.shared.userInfo = value.data
            AppConfig.shared.keychainData.sessionToken = value.data?.token
            AppConfig.shared.keychainData.mobile = loginParam.mobile
//            guard let string = Mapper().toJSONString(self.session) else { return }
//            AppConfig.shared.keychainData.loginSession = string
//            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            self.performSegue(withIdentifier: R.segue.registerViewController.showPayPassVC, sender: nil)
            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isSigned)
        }.always {
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @IBAction func leftHandle() {
        dismiss(animated: true, completion: nil)
    }
    
    // 获取 图片captcha
    // 用手机号和 图片验证码 手机验证码类型 获取sms code
    // 用手机号 sms code password 注册
    
    fileprivate func validInputs() -> Promise<UserParameter> {
        return Promise { fulfill, reject in
            if let mobile = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces), mobile.characters.count == 11, let code = smsCodeTextField.text, !code.isEmpty, let password = passwordTextField.text, !password.isEmpty {
                if password.validatePassword() == false {
                    let error = AppError(code: ValidInputsErrorCode.passwordInputError, msg: nil)
                    reject(error)
                } else {
                    let param = UserParameter()
                    param.mobile = mobile
                    param.password = password
                    param.smsCode = code
                    fulfill(param)
                }
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    @IBAction func refreshCaptcha() {
        guard let mobile = mobileTextField.text?.stringByRemovingCharactersInSet(CharacterSet.whitespaces), mobile.characters.count == 11 else {
            let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
            Navigator.showAlertWithoutAction(nil, message: error.toError().localizedDescription)
            return
        }
        guard let captchaVC = R.storyboard.container.captchaViewController() else { return }
        captchaVC.mobile = mobile
        captchaVC.smsType = .register
        captchaVC.finishHandle = { [weak self] captcha in
            if let cap = captcha, !cap.isEmpty {
                self?.smsCodeTextField.text = cap
                self?.codeButton.starTime()
            }
            self?.dim(.out, coverNavigationBar: true)
            self?.dismiss(animated: true, completion: nil)
        }
        dim(.in, coverNavigationBar: true)
        present(captchaVC, animated: true, completion: nil)
    }
    
    /// 用户注册协议
    @IBAction fileprivate func showTOS() {
        guard let vc = R.storyboard.main.helpViewController() else { return }
        vc.title = "用户注册协议"
        var string = WebViewURL.protocol.URL()
        string.append("?tag=0401")
        if let url = URL(string: string) {
            vc.loadURL(url)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 勾选选中框
    ///
    /// - Parameter sender: 按钮
    @IBAction func checkAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == false {
            registerButton.backgroundColor = UIColor.gray
            registerButton.isEnabled = false
        } else {
            registerButton.backgroundColor = UIColor(hex: 0xFB7908)
            registerButton.isEnabled = true
        }
    }
    
}

extension RegisterViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 9.0
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

extension RegisterViewController: UITextFieldDelegate {
    // MARK: Text Field Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if newText.characters.count >= 13 {
            codeButton.isEnabled = true
            codeButton.backgroundColor = UIColor(hex: 0x00A8FE)
        } else {
            codeButton.isEnabled = false
            codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
        }
        return validatePhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}

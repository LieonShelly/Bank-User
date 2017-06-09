//
//  FindPayPasswordCheckTableViewController.swift
//  Bank
//
//  Created by yang on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD
import Device

class FindPayPasswordCheckTableViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var progressImageView: UIImageView!
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet fileprivate var footerView: UIView!
    @IBOutlet fileprivate weak var phoneTextField: UITextField!
    @IBOutlet fileprivate weak var codeTextField: UITextField!
    @IBOutlet fileprivate weak var loginPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var codeButton: CodeButton!
    
    fileprivate var token: String?
    
    var isBackSetting: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        phoneTextField.text = AppConfig.shared.keychainData.getMobile()
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FindPayPasswordSetTableViewController {
            vc.mobile = phoneTextField.text
            vc.smsCode = codeTextField.text
            vc.password = loginPasswordTextField.text
            vc.isBackSetting = self.isBackSetting
            vc.token = self.token
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeTextField.text = ""
        loginPasswordTextField.text = ""
    }
    // 获取手机验证码
    @IBAction func getCodeAction(_ sender: UIButton) {
        
        guard let mobile = phoneTextField.text?.stringByRemovingCharactersInSet(CharacterSet.whitespaces), mobile.characters.count == 11 else {
            let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
            Navigator.showAlertWithoutAction(nil, message: error.toError().localizedDescription)
            return
        }
        guard let captchaVC = R.storyboard.container.captchaViewController() else { return }
        captchaVC.mobile = mobile
        captchaVC.smsType = .forgotPayPass
        captchaVC.finishHandle = { [weak self] captcha in
            if let cap = captcha, !cap.isEmpty {
                self?.codeTextField.text = cap
                self?.codeButton.starTime()
            }
            self?.dim(.out, coverNavigationBar: true)
            self?.dismiss(animated: true, completion: nil)
        }
        dim(.in, coverNavigationBar: true)
        present(captchaVC, animated: true, completion: nil)
    }
    
    fileprivate func validInputs() -> Promise<UserParameter> {
        return Promise { fulfill, reject in
            if let mobile = phoneTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces), mobile.characters.count == 11, let code = codeTextField.text, !code.isEmpty, let password = loginPasswordTextField.text, !password.isEmpty {
                let param = UserParameter()
                param.mobile = mobile
                param.smsCode = code
                param.password = password
                fulfill(param)
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        view.endEditing(true)
        let verifyParam = UserParameter()
        MBProgressHUD.loading(view: self.view)
        validInputs().then { (param) -> Promise<GetUserInfoData> in
            verifyParam.mobile = param.mobile
            verifyParam.smsCode = param.smsCode
            verifyParam.password = param.password
            verifyParam.payPassword = nil
            verifyParam.step = .checkOldPassword
            return handleRequest(Router.endpoint( UserPath.forgotPayPassword, param: verifyParam))
            }.then { (value) -> Void in
                self.token = value.data?.token
                self.performSegue(withIdentifier: R.segue.findPayPasswordCheckTableViewController.showFindPayPasswordSetVC, sender: nil)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

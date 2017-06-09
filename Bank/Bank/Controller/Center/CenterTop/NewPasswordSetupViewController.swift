//
//  NewPasswordSetupViewController.swift
//  Bank
//
//  Created by Mac on 15/11/30.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import Device

class NewPasswordSetupViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet fileprivate weak var progressImageView: UIImageView!
    @IBOutlet fileprivate weak var newPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var determinPasswordTextField: UITextField!
    @IBOutlet var headerView: UIView!
    
    var oldPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlertView() {
        let alertView = UIAlertController(title: nil, message: R.string.localizable.alertTitle_revise_password_success(), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { (action) in
            self.requestLogoutData()
            if let delegate = UIApplication.shared.delegate as? AppDelegate, let containerVC = delegate.containerVC {
                containerVC.logout(isNeedLogin: true)
            }
            // 用户登出，将指纹是否开启标志置为false
//            UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            // 手动退出
            AppConfig.shared.rememberAccountStatus = RememberAccountType.manualQuitAccount
        }))
        present(alertView, animated: true, completion: nil)
    }

    @IBAction func saveAction(_ sender: UIButton) {
        view.endEditing(true)
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.updateLoginPassword, param: param))
            return req
        }.then { (value) -> Void in
            if value.isValid {
               self.showAlertView()
            }
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    fileprivate func vaildInput() -> Promise<UserParameter> {
        return Promise { fufill, reject in
            guard let newPassword = newPasswordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            guard let determinPassword = determinPasswordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            if newPasswordTextField.text?.validatePassword() == false {
                let error = AppError(code: ValidInputsErrorCode.passwordInputError, msg: nil)
                return reject(error)
            }
            let count = !newPassword.characters.isEmpty && !determinPassword.characters.isEmpty
            switch count {
            case true:
                let match = newPasswordTextField.text == determinPasswordTextField.text
                switch match {
                case true:
                    let param = UserParameter()
                    param.oldPassword = self.oldPassword
                    param.password = newPasswordTextField.text
                    param.step = .updateNewPassword
                    fufill(param)
                case false:
                    let error = AppError(code: ValidInputsErrorCode.unmatched, msg: nil)
                    reject(error)
                }
                
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    // 用户登出
    func requestLogoutData() {
//        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.logout, param: nil))
        req.then { (value) -> Void in
            }.always {
//                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }

}

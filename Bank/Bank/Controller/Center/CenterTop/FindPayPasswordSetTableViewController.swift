//
//  FindPayPasswordSetTableViewController.swift
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

class FindPayPasswordSetTableViewController: BaseTableViewController {

    @IBOutlet fileprivate weak var progressImageView: UIImageView!
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet fileprivate var footerView: UIView!
    @IBOutlet fileprivate weak var newPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var determinePasswordTextField: UITextField!
    var mobile: String!
    var smsCode: String!
    var password: String!
    var isBackSetting: Bool = true
    var token: String?
    internal var numberInput: InputView?
    internal var numberInput2: InputView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = footerView
        tableView.tableHeaderView = headerView
        numberInput = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput2 = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput?.keyInput = newPasswordTextField
        newPasswordTextField.inputView = numberInput
        numberInput2?.keyInput = determinePasswordTextField
        determinePasswordTextField.inputView = numberInput2
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlertView() {
        let alertView = UIAlertController(title: "", message: R.string.localizable.alertTitle_pay_password_set_success(), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { (action) in
            
            if self.isBackSetting {
                self.performSegue(withIdentifier: R.segue.findPayPasswordSetTableViewController.showSettingVC, sender: nil)
            } else {
                // 返回首页
                if let tab = self.tabBarController, let controllers = tab.viewControllers {
                    guard let nav = controllers[0] as? UINavigationController else {
                        return
                    }
                    nav.popToRootViewController(animated: false)
                    self.tabBarController?.selectedViewController = nav
                }
            }
        }))
        present(alertView, animated: true, completion: nil)
    }

    @IBAction func determinAction(_ sender: UIButton) {
        view.endEditing(true)
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.forgotPayPassword, param: param))
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
            guard let determinePassword = determinePasswordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            if newPassword.characters.isEmpty && determinePassword.characters.isEmpty {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            } else if newPassword.characters.count != 6 || determinePassword.characters.count != 6 {
                let error = AppError(code: ValidInputsErrorCode.payPassLengthError, msg: nil)
                reject(error)
            } else if newPasswordTextField.text != determinePasswordTextField.text {
                let error = AppError(code: ValidInputsErrorCode.payPassNotFit, msg: nil)
                reject(error)
            } else {
                let param = UserParameter()
                param.mobile = mobile.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
                param.token = self.token
                param.smsCode = smsCode
                param.password = password
                param.payPassword = newPasswordTextField.text
                param.step = .updateNewPassword
                fufill(param)
            }
        }
    }

}

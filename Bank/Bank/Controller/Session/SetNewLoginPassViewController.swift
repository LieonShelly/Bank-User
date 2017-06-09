//
//  SetNewLoginPassViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class SetNewLoginPassViewController: BaseTableViewController {
    
    var param: UserParameter?
    var token: String?
    
    @IBOutlet fileprivate weak var passTextField: UITextField!
    @IBOutlet fileprivate weak var repeatTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction fileprivate func confirmHandle() {
        MBProgressHUD.loading(view: view)
        validInputs().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.forgotLoginPassword, param: param))
            return req
        }.then { (value) -> Void in
            let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_load_password_set_success(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { (action) in
                self.perform(#selector(self.popSelf), with: nil, afterDelay: 0.2)
            }))
            self.present(alert, animated: true, completion: nil)
        }.always {
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @objc fileprivate func popSelf() {
        if let _ = navigationController?.viewControllers[0] as? LoginViewController {
            _ = self.navigationController?.popToRootViewController(animated: true)
        } else {
            navigationController?.viewControllers.remove(at: 0)
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    fileprivate func validInputs() -> Promise<UserParameter> {
        return Promise { fulfill, reject in
            if let pass = passTextField.text, !pass.isEmpty,
                let repass = repeatTextField.text, !repass.isEmpty {
                if pass != repass {
                    let error = AppError(code: ValidInputsErrorCode.unmatched, msg: nil)
                    reject(error)
                } else if pass.validatePassword() == false {
                    let error = AppError(code: ValidInputsErrorCode.passwordInputError, msg: nil)
                    reject(error)
                } else {
                    let newParam = UserParameter()
                    newParam.token = self.token
                    newParam.password = pass
                    newParam.mobile = self.param?.mobile
                    newParam.smsCode = self.param?.smsCode
                    newParam.payPassword = self.param?.payPassword
                    newParam.findPassword = .setNewPass
                    newParam.userName = self.param?.userName
                    newParam.idCardNo = self.param?.idCardNo
                    fulfill(newParam)
                }
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
}

extension SetNewLoginPassViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
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

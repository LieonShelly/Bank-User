//
//  PasswordSetupViewController.swift
//  Bank
//
//  Created by Mac on 15/11/28.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import Device

class PasswordSetupViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tip1Label: UILabel!
    @IBOutlet fileprivate weak var tip2Label: UILabel!
    @IBOutlet fileprivate weak var progressImageView: UIImageView!
    @IBOutlet fileprivate weak var warningLabel: UILabel!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var leadConstraint: NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        warningLabel.isHidden = true
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NewPasswordSetupViewController {
            vc.oldPassword = passwordTextField.text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        view.endEditing(true)
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.updateLoginPassword, param: param))
            return req
        }.then { (value) -> Void in
            if value.isValid {
                self.warningLabel.isHidden = true
                self.performSegue(withIdentifier: R.segue.passwordSetupViewController.showSetNewPasswordVC, sender: nil)
            }
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                // code = 103014 旧登录密码错误
                debugPrint("登录密码设置的错误信息\(err)")
                if err.errorCode.errorCode() == RequestErrorCode.oldPassError.errorCode() {
                    self.warningLabel.isHidden = false
                    self.warningLabel.text = err.toError().localizedDescription
                } else {
                    self.warningLabel.isHidden = true
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
            }
        }
    }
    
    fileprivate func vaildInput() ->Promise<UserParameter> {
        return Promise { fufill, reject in
            guard let password = passwordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            let count = !password.characters.isEmpty
            switch count {
            case true:
                let param = UserParameter()
                param.oldPassword = passwordTextField.text
                param.step = .checkOldPassword
                fufill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
}

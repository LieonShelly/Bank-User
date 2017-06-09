//
//  VerifyPayPasswordViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class VerifyPayPasswordViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var passTextField: UITextField!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var idTextField: UITextField!
    
    var verifyState: SignedState?
    var token: String?
    var param: UserParameter?
    
    fileprivate var sectionCount: Int {
        if verifyState == .linkedCard {
            return 3
        } else {
            return 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func validInputs() -> Promise<UserParameter> {
        return Promise { fulfill, reject in
            if let pass = passTextField.text, !pass.isEmpty,
            let param = self.param {
                param.payPassword = pass
                param.findPassword = .verifyPayPass
                param.token = self.token
                if .linkedCard == verifyState {
                    if let name = nameTextField.text, !name.isEmpty, let idNo = idTextField.text, !idNo.isEmpty {
                        param.userName = name
                        param.idCardNo = idNo
                    }
                }
                fulfill(param)
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    @IBAction func confirmHandle() {
        if passTextField.text?.characters.count != 6 {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_password_count_error())
            return
        }
        MBProgressHUD.loading(view: self.view)
        validInputs().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.forgotLoginPassword, param: param))
            return req
        }.then { (value) -> Void in
            self.performSegue(withIdentifier: R.segue.verifyPayPasswordViewController.showSetNewLoginPassVC, sender: nil)
        }.always {
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @IBAction fileprivate func forgotHandle() {
        let string = "登录密码和支付密码均忘记，请拨打400******* 联系客服找回。"
        Navigator.showAlertWithoutAction(nil, message: string)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.verifyPayPasswordViewController.showSetNewLoginPassVC.identifier {
            if let vc = segue.destination as? SetNewLoginPassViewController {
                vc.param = param
                vc.token = self.token
            }
        }
    }

}

extension VerifyPayPasswordViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 17.0
        } else {
            return 8.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sectionCount - 1 {
            return 17.0
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
}

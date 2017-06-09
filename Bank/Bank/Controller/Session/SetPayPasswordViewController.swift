//
//  SetPayPasswordViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class SetPayPasswordViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var passTextField: UITextField!
    @IBOutlet fileprivate weak var repeatPassTextField: UITextField!
    internal var numberInput: InputView?
    internal var numberInput2: InputView?
    override func viewDidLoad() {
        super.viewDidLoad()
        passTextField.isSecureTextEntry = true
        repeatPassTextField.isSecureTextEntry = true
        numberInput = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput2 = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput?.keyInput = passTextField
        passTextField.inputView = numberInput
        numberInput2?.keyInput = repeatPassTextField
        repeatPassTextField.inputView = numberInput2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestSetPayPass() {
        MBProgressHUD.loading(view: self.view)
        validInputs().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.setpayPass, param: param))
            return req
        }.then { (value) -> Void in
            UserDefaults.standard.set(true, forKey: CustomKey.UserDefaultsKey.isPaypassSet)
            if let tabVC = self.presentingViewController as? TabBarController, let containerVC = tabVC.containerController {
                containerVC.successRegister()
            }
            if let navVC = self.presentingViewController as? UINavigationController,
                let regVC = navVC.topViewController as? RegisterViewController,
                let containerVC = regVC.containerController {
                regVC.dismiss(animated: false, completion: {
                    containerVC.successRegister()
                })
            }
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }

    fileprivate func validInputs() -> Promise<UserParameter> {
        return Promise { fulfill, reject in
            if let pass = passTextField.text, pass.characters.count == 6, let rePass = repeatPassTextField.text, rePass == pass {
                let param = UserParameter()
                param.payPassword = pass
                fulfill(param)
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
}

extension SetPayPasswordViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8.0
        }
        return 17.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 17.0
        }
        return CGFloat.leastNormalMagnitude
    }
}

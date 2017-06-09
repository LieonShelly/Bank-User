//
//  UpdatePayPasswordSetTableViewController.swift
//  Bank
//
//  Created by yang on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import Device

class UpdatePayPasswordSetTableViewController: BaseTableViewController {

    @IBOutlet fileprivate weak var progressImageView: UIImageView!
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet fileprivate var footerView: UIView!
    @IBOutlet fileprivate weak var newPayPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var determinePasswordTextField: UITextField!
    internal var numberInput: InputView?
    internal var numberInput2: InputView?
    var oldPayPassword: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        numberInput = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput2 = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput?.keyInput = newPayPasswordTextField
        newPayPasswordTextField.inputView = numberInput
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

    @IBAction func determinAction(_ sender: UIButton) {
        view.endEditing(true)
        requestData()
    }
    
    func showAlertView() {
        let alertView = UIAlertController(title: "", message: R.string.localizable.alertTitle_pay_password_set_success(), preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .default, handler: { (action) in
            self.performSegue(withIdentifier: R.segue.updatePayPasswordSetTableViewController.showSettingVC, sender: nil)
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    func requestData() {
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<UpdatePayPasswordData> in
            let req: Promise<UpdatePayPasswordData> = handleRequest(Router.endpoint( UserPath.updatePayPassword, param: param))
            return req
            }.then { (value) -> Void in
                if value.isValid {
                    self.showAlertView()
                }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    //TODO
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    fileprivate func vaildInput() ->Promise<UserParameter> {
        return Promise { fufill, reject in
            
            guard let newPayPassword = newPayPasswordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            guard let determinePassword = determinePasswordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            if (newPayPassword.characters.isEmpty) && (determinePassword.characters.isEmpty) {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            } else if newPayPassword.characters.count != 6 || determinePassword.characters.count != 6 {
                let error = AppError(code: ValidInputsErrorCode.payPassLengthError, msg: nil)
                reject(error)
            } else if newPayPasswordTextField.text != determinePasswordTextField.text {
                let error = AppError(code: ValidInputsErrorCode.payPassNotFit, msg: nil)
                reject(error)
            } else {
                let param = UserParameter()
                param.oldPayPassword = oldPayPassword
                param.payPassword = newPayPasswordTextField.text
                param.step = .updateNewPassword
                fufill(param)

            }

        }
    }
}

extension UpdatePayPasswordSetTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17.0
    }
}

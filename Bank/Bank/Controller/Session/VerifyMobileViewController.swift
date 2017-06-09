//
//  VerifyMobileViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class VerifyMobileViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var mobileTextField: UITextField!
    @IBOutlet fileprivate weak var smsCodeTextField: UITextField!
    @IBOutlet weak var codeButton: CodeButton!
    
    fileprivate var verifyState: SignedState?
    fileprivate var token: String?
    var param: UserParameter = UserParameter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        codeButton.isEnabled = false
        codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mobileTextField.text = ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextStepHandle() {
        MBProgressHUD.loading(view: self.view)
        validInputs().then { (param) -> Promise<GetUserInfoData> in
            self.param.mobile = param.mobile
            self.param.smsCode = param.smsCode
            self.param.findPassword = .verifySMS
            return handleRequest(Router.endpoint( UserPath.forgotLoginPassword, param: self.param))
            }.then { (value) -> Void in
                if let data = value.data {
                    self.verifyState = data.state
                    self.token = data.token
                    guard let state = data.state else { return }
                    switch state {
                    case .linkedCard, .setPayPassNotLinkCard:
                        self.performSegue(withIdentifier: R.segue.verifyMobileViewController.showVerifyPayVC, sender: nil)
                    case .notSetPayPass:
                        self.performSegue(withIdentifier: R.segue.verifyMobileViewController.showSetNewPassVC, sender: nil)
                    default:
                        break
                    }
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
            if let mobile = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces), mobile.characters.count == 11, let code = smsCodeTextField.text, !code.isEmpty {
                let param = UserParameter()
                param.mobile = mobile
                param.smsCode = code
                fulfill(param)
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
        captchaVC.smsType = .forgotLoginPass
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.verifyMobileViewController.showVerifyPayVC.identifier {
            if let vc = segue.destination as? VerifyPayPasswordViewController {
                vc.verifyState = verifyState
                vc.token = self.token
                vc.param = param
            }
        }
        if segue.identifier == R.segue.verifyMobileViewController.showSetNewPassVC.identifier {
            if let vc = segue.destination as? SetNewLoginPassViewController {
                vc.param = param
                vc.token = self.token
            }
        }
    }
}

extension VerifyMobileViewController {
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

extension VerifyMobileViewController: UITextFieldDelegate {
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

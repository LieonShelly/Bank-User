//
//  AssociatedCreditViewController.swift
//  Bank
//
//  Created by 糖otk on 2017/2/14.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit
import URLNavigator
import MBProgressHUD
import PromiseKit

class AssociatedCreditViewController: BaseTableViewController {

    @IBOutlet weak var codeButton: CodeButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var idcardTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestQueryCard()
        setTitle()
        setCheckButtonState()
        NotificationCenter.default.addObserver(self, selector: #selector(phoneTextFiledDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: phoneTextField)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func phoneTextFiledDidChange(noti: Foundation.Notification) {
        if let textField = noti.object as? UITextField {
            let nsstring = textField.text! as NSString
            if textField.text!.characters.count >= 11 {
                textField.text = nsstring.substring(to: 11)
                self.codeButton.backgroundColor = UIColor(hex: 0x00A8FE)
                self.codeButton.isEnabled = true
            } else {
                self.codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
                self.codeButton.isEnabled = false
            }
        }
    }
    
    // 是否同意协议
    @IBAction func checkButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == false {
            confirmButton.backgroundColor = UIColor.gray
            confirmButton.isEnabled = false
        } else {
            confirmButton.backgroundColor = UIColor(hex: 0xFB7908)
            confirmButton.isEnabled = true
        }
    }
    @IBAction func showAgreementAction(_ sender: UIButton) {
        guard let vc = R.storyboard.main.helpViewController() else { return }
        vc.title = "关联信用账户协议"
        var string = WebViewURL.protocol.URL()
        string.append("?tag=0401")
        if let url = URL(string: string) {
            vc.loadURL(url)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 确定
    @IBAction func confirmAction(_ sender: UIButton) {
        view.endEditing(true)
        
        if let name = nameTextField.text, name.characters.isEmpty {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_name())
            return
        }
       
        guard Util.isTrueName(nameTextField.text!) else {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_name_invalid_format())
            return
        }
        if let idCard = idcardTextField.text, idCard.characters.isEmpty {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_idcard())
            return
        }
        guard Util.isValidateIDNumber(idcardTextField.text!) else {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_correct_idcard())
            return
        }
        if let phoneNumb = phoneTextField.text, phoneNumb.characters.count != 11 {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_mobile())
            return
        }
        if let code = codeTextField.text, code.characters.isEmpty {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_code())
            return
        }
        
        MBProgressHUD.loading(view: view)
        let param = UserParameter()
        param.mobile = phoneTextField.text!
        param.identifier = idcardTextField.text!
        param.verifyCode = codeTextField.text!
        param.userName = nameTextField.text!
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.relevanceAccount, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                AppConfig.shared.isUserSigned = true
                let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_bind_credit_sucess(), preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default) { (determine) -> Void in
                    if let tab = self.tabBarController, let controllers = tab.viewControllers {
                        guard let nav = controllers[0] as? UINavigationController else {
                            return
                        }
                        nav.popToRootViewController(animated: false)
                        self.tabBarController?.selectedViewController = nav
                    }
                }
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // 获取验证码
    @IBAction func getVerificationCodeAction(_ sender: UIButton) {

        if let phoneNumb = phoneTextField.text, phoneNumb.characters.isEmpty {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_mobile())
            return
        }
        if AppConfig.shared.keychainData.getMobile() != phoneTextField.text! {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_please_write_mobile())
            return
        }
        guard let captchaVC = R.storyboard.container.captchaViewController() else { return }
        captchaVC.mobile = phoneTextField.text!
        captchaVC.smsType = .associationCredit
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
    
    @IBAction func helpAction(_ sender: UIButton) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_card_logout(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// 请求上次绑卡身份信息
    fileprivate func requestQueryCard() {
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint( BankCardPath.queryCard, param: nil))
        req.then { (value) -> Void in
            if let name = value.data?.name {
                self.nameTextField.text = name
                self.nameTextField.isUserInteractionEnabled = name.isEmpty
                self.helpButton.isHidden = name.isEmpty
            }
            }.catch { _ in
                self.requestQueryCard()
        }
    }
    
}

extension AssociatedCreditViewController {
    func setTitle() {
        title = R.string.localizable.controller_title_associated_credit()
    }
    func setCheckButtonState() {
        checkButton.isSelected = true
        self.codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
        self.codeButton.isEnabled = false
    }
}

extension AssociatedCreditViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
/*      if range.location = 11 {
 self.codeButton.backgroundColor = UIColor(hex: 0x00A8FE)
 self.codeButton.isEnabled = true
 return false
 } else {
 self.codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
 self.codeButton.isEnabled = false
 return true
 }*/

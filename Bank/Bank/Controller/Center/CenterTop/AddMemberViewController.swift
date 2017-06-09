//
//  AddMemberViewController.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import ContactsUI
import PromiseKit
import URLNavigator
import MBProgressHUD

class AddMemberViewController: BaseViewController {

    @IBOutlet weak fileprivate var phoneTextField: UITextField!
    @IBOutlet weak fileprivate var remarkTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        helpHtmlName = "IAddMembers"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showHelpVC", let vc = segue.destination as? HelpViewController {
            vc.htmlName = helpHtmlName
        }
    }
    
    func keyboardWillShow(_ notific: Foundation.Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: -100), size: self.view.frame.size)
        })
    }
    
    func keyboardWillHidden(_ notific: Foundation.Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: 63), size: self.view.frame.size)
        })
    }
    
    //确定邀请
    @IBAction func determineAction(_ sender: UIButton) {
        view.endEditing(true)
        validInputs().then { (param) -> Promise<MemberDetailData> in
            let req: Promise<MemberDetailData> = handleRequest(Router.endpoint( MemberPath.add, param: param))
            return req
        }.then { object in
            self.showAlertView(R.string.localizable.alertTitle_invite_success())
        }.catch { error in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    fileprivate func validInputs() -> Promise<MemberParameter> {
        return Promise { fulfill, reject in
            let count = phoneTextField.text?.characters.isEmpty == false && remarkTextField.text?.characters.isEmpty == false
            switch count {
            case true:
                let param = MemberParameter()
                param.mobile = phoneTextField.text
                param.remark = remarkTextField.text
                fulfill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    //访问通讯录
    @IBAction func accessAddressbookAction(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        present(contactPicker, animated: true, completion: nil)
    }
    
    func showAlertView(_ message: String) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: message, preferredStyle: .alert)
        let determineAction = UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default) { (determine) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(determineAction)
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - CNContactPickerDelegate
extension AddMemberViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        var phoneString = (contactProperty.value as AnyObject).stringValue
        phoneString = phoneString?.deleteWith("-")
        phoneTextField.text = phoneString
    }
}

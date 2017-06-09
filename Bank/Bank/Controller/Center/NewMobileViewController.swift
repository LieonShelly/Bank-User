//
//  NewMobileViewController.swift
//  Bank
//
//  Created by kilrae on 2017/4/18.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class NewMobileViewController: BaseTableViewController {

    @IBOutlet weak var mobileTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        mobileTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 17
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        view.endEditing(true)
        if mobileTextField.text?.isEmpty == true {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.error_title_input_mobile())
        } else {
            requestPendNewData()
        }
    }
    
    /// 登记新手机号
    fileprivate func requestPendNewData() {
        let hud = MBProgressHUD.loading(view: view)
        let param = UserParameter()
        param.mobile = mobileTextField.text?.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.pendNew, param: param))
        req.always {
            hud.hide(animated: true)
        }.then { (value) -> Void in
            guard let vc = R.storyboard.setting.inputCodeViewController() else {
                return
            }
            if let mobile = param.mobile {
                vc.mobile = mobile
            }
            Navigator.push(vc)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension NewMobileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return validatePhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
}

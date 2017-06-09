//
//  UpdateNameViewController.swift
//  Bank
//
//  Created by yang on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class UpdateNameViewController: BaseViewController {

    @IBOutlet weak fileprivate var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    var needUpdateData: ((String?) -> Void)?
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        nameTextField.text = userName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<NullDataResponse> in
            let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.update, param: param))
            return req
            }.then { (value) -> Void in
                if let block = self.needUpdateData {
                    block(self.nameTextField.text)
                }
                _ = self.navigationController?.popViewController(animated: true)
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
            let count = nameTextField.text?.characters.isEmpty
            if count == true {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            } else {
                let regx = "^[\\u4e00-\\u9fa5a-zA-Z][\\u4e00-\\u9fa5a-zA-Z0-9]+$"
                let pre = NSPredicate(format: "SELF MATCHES %@", regx)
                if let name = nameTextField.text {
                    let length = self.convertToInt(str: NSString(string: name))
                    if length >= 4 && length <= 16 && pre.evaluate(with: name) == true {
                        let param = UserParameter()
                        param.nickName = nameTextField.text
                        param.userName = nameTextField.text
                        fufill(param)
                    } else {
                        let error = AppError(code: ValidInputsErrorCode.nameFormatError, msg: nil)
                        reject(error)
                    }
                }
            }
        }
    }
    
    fileprivate func convertToInt(str: NSString = "") -> Int {
        var strlength = 0
        for i in 0..<str.length {
            let uc = str.character(at: i)
            let ax = isascii(Int32(uc))
            if ax == 1 {
                strlength += 1
            } else {
                strlength += 2
            }
        }
        return strlength
    }

}

//
//  MemberEditViewController.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import MBProgressHUD

class MemberEditViewController: BaseViewController {
    var member: Member?
//    var butler: Butler?
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak fileprivate var remarkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        if member != nil {
            remarkTextField.text = member?.remark
        }
//        if butler != nil {
//            remarkTextField.text = butler?.remark
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
     
        if member?.memberID != nil {
            validInputs().then { param -> Promise<MemberParameter> in
                let req: Promise<MemberParameter> = handleRequest(Router.endpoint( MemberPath.update, param: param))
                return req
                }.then { object in
                    self.showAlertView(R.string.localizable.alertTitle_revise_success())
                }.catch { (error) in
                    if let err = error as? AppError {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
            }
        } else {
            validInputs().then { param -> Promise<MemberParameter> in
                let req: Promise<MemberParameter> = handleRequest(Router.endpoint( ButlerPath.bind, param: param))
                return req
                }.then { object in
                    self.showAlertView(R.string.localizable.alertTitle_revise_success())
                }.catch { (error) in
                    if let err = error as? AppError {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
            }
        }
    }

    fileprivate func validInputs() -> Promise<MemberParameter> {
        if member?.memberID != nil {
            return Promise { fulfill, reject in
                guard let remark = remarkTextField.text else {
                    let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                    return reject(error)
                }
                let count = !remark.characters.isEmpty
                switch count {
                case true:
                    let param = MemberParameter()
                    param.memberID = member?.memberID
                    param.remark = remarkTextField.text
                    fulfill(param)
                case false:
                    let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                    reject(error)
                }
            }
        } else {
            return Promise { fulfill, reject in
                guard let remark = remarkTextField.text else {
                    let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                    return reject(error)
                }
                let count = !remark.characters.isEmpty
                switch count {
                case true:
                    let param = MemberParameter()
//                    param.bankerJobno = butler?.jobID
                    param.bankerRemark = remarkTextField.text
                    fulfill(param)
                case false:
                    let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                    reject(error)
                }
            }
        }
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

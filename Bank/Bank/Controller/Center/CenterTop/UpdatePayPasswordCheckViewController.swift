//
//  UpdatePayPasswordCheckViewController.swift
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

class UpdatePayPasswordCheckViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet fileprivate weak var progressImageView: UIImageView!
    @IBOutlet fileprivate weak var oldPayPasswordTextField: UITextField!
    @IBOutlet fileprivate weak var warnningLabel: UILabel!
    @IBOutlet fileprivate weak var findPasswordButton: UIButton!
    internal var numberInput: InputView?
    @IBOutlet var headerView: UIView!
    fileprivate var errorPromptView: ErrorPromptView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        warnningLabel.isHidden = true
        findPasswordButton.isHidden = true
        numberInput = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput?.keyInput = oldPayPasswordTextField
        oldPayPasswordTextField.inputView = numberInput
        requestPayPassStatusData()
        if Device.size() == .screen5_5Inch {
            progressImageView.contentMode = .scaleAspectFill
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        oldPayPasswordTextField.text = ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UpdatePayPasswordSetTableViewController {
            vc.oldPayPassword = oldPayPasswordTextField.text
        }
    }

    @IBAction func nextAction(_ sender: UIButton) {
        view.endEditing(true)
        if oldPayPasswordTextField.text?.characters.count != 6 {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_password_count_error())
            return
        }
        requestData()
    }
    
    func requestData() {
        MBProgressHUD.loading(view: view)
        vaildInput().then { (param) -> Promise<UpdatePayPasswordData> in
            let req: Promise<UpdatePayPasswordData> = handleRequest(Router.endpoint( UserPath.updatePayPassword, param: param))
            return req
            }.then { (value) -> Void in
                
                if value.isValid {
                    self.warnningLabel.isHidden = true
                    self.findPasswordButton.isHidden = true
                    self.performSegue(withIdentifier: R.segue.updatePayPasswordCheckViewController.showUpdatePayPasswordSetVC, sender: nil)
                } else {
                    self.warnningLabel.isHidden = false
                    self.warnningLabel.text = value.msg
                    self.findPasswordButton.isHidden = false
                }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                /*
                 status=0 code=01070003 是旧支付密码错误，status＝1就是正确
                 */
                if let err = error as? AppError {
                    if err.errorCode.errorCode() == RequestErrorCode.payPassError.errorCode() {
                        self.findPasswordButton.isHidden = false
                        self.warnningLabel.isHidden = false
                        self.warnningLabel.text = err.toError().localizedDescription
                    } else if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                        self.setErrorPromptView()
                    } else {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
                    
                }
        }

    }
    
    fileprivate func vaildInput() ->Promise<UserParameter> {
        return Promise { fufill, reject in
            guard let oldPayPassword = oldPayPasswordTextField.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error)
            }
            let count = !oldPayPassword.characters.isEmpty
            switch count {
            case true:
                let param = UserParameter()
                param.oldPayPassword = oldPayPasswordTextField.text
                param.payPassword = nil
                param.step = .checkOldPassword
                fufill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    //支付密码状态
    func requestPayPassStatusData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            self.tableView.isHidden = false
        }.always { 
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    self.setErrorPromptView()
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
                
            }

        }
        
    }
    
    func setErrorPromptView() {
        if errorPromptView == nil {
             errorPromptView = R.nib.errorPromptView.firstView(owner: nil)
        }
        errorPromptView?.frame = view.bounds
        errorPromptView?.buttonHandleBlock = {
            self.performSegue(withIdentifier: R.segue.updatePayPasswordCheckViewController.showFindPayPasswordVC, sender: nil)
        }
        if let errorPromptView = errorPromptView {
            self.view.addSubview(errorPromptView)
            self.title = "错误提示"
        }
    }
}

//
//  TransConfirmViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/13.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import URLNavigator

class TransConfirmViewController: FormViewController {
    
    @IBOutlet fileprivate weak var footerView: UIView!
    
    var isCrossBank: Bool = false
    var transParam = BankCardParameter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "跨行转账"
        if !isCrossBank {
            title = "同行转账"
        }
        setBackBarButton()
        tableView?.configBackgroundView()
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 30))
        button.setTitle(R.string.localizable.button_title_get_code(), for: UIControlState())
        button.layer.cornerRadius = 2.0
        button.titleLabel?.font = .systemFont(ofSize: 13.0)
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = .colorFromHex(CustomKey.Color.MainBlueColor)
        button.addTarget(self, action: #selector(self.refreshCaptcha), for: .touchUpInside)
        
        form +++
            Section() {
                $0.tag = "receiver_info"
        }
        guard let receiverInfoSection = form.sectionBy(tag: "receiver_info") else {
            return
        }
        receiverInfoSection
            <<< TextRow() {
                $0.title = "付款账号"
                $0.value = transParam.cardNo
                }
                .cellSetup({ (cell, row) in
                    cell.textField.isUserInteractionEnabled = false
                })
        
        if isCrossBank {
            receiverInfoSection
                <<< TextRow() {
                    $0.title = "收款方银行"
                    $0.value = transParam.receiverBankName
                    }.cellSetup({ (cell, row) in
                        cell.textField.isUserInteractionEnabled = false
                    })
        }
        receiverInfoSection
            <<< TextRow() {
                $0.title = "收款方姓名"
                $0.value = transParam.receiverName
                }
                .cellUpdate({ (cell, row) in
                    cell.textField.textColor = .colorFromHex(0xfe8d00)
                    cell.textField.isUserInteractionEnabled = false
                })
            <<< TextRow() {
                $0.title = "收款方账号"
                $0.value = transParam.receiverCardNo
                }
                .cellUpdate({ (cell, row) in
                    cell.textField.textColor = .colorFromHex(0xfe8d00)
                    cell.textField.isUserInteractionEnabled = false
                })
            <<< TextRow() {
                $0.title = "转账金额"
                let amount = transParam.amount ?? 0
                $0.value = "\(amount)元"
                }
                .cellUpdate({ (cell, row) in
                    cell.textField.textColor = .colorFromHex(0xfe8d00)
                    cell.textField.isUserInteractionEnabled = false
                })
            <<< TextRow() {
                $0.title = "手续费"
                $0.value = "0.00元"
                }
                .cellSetup({ (cell, row) in
                    cell.textField.isUserInteractionEnabled = false
                })
            <<< TextRow() {
                $0.title = "备注"
                $0.value = transParam.remark
                }
                .cellSetup({ (cell, row) in
                    cell.textField.isUserInteractionEnabled = false
                })
            form +++ Section()
            <<< PasswordRow() {
                $0.title = "取款密码"
                $0.tag = "card_pass"
                $0.placeholder = "请输入银行卡取款密码"
            }
            form +++ Section()
            <<< PhoneRow() {
                $0.title = "手机号码"
                $0.placeholder = "请输入手机号码"
                $0.tag = "mobile"
                $0.textFieldLeftConst = 110
                }
            <<< TextRow() {
                $0.title = "验证码"
                $0.tag = "sms_code"
                $0.placeholder = "请输入验证码"
                }.cellSetup({ (cell, row) in
                    cell.accessoryView = button
                })
        
        tableView?.configBackgroundView()
        tableView?.tableFooterView = footerView
        tableView?.reloadData()
    }
    
    fileprivate func validInputs() -> Promise<BankCardParameter> {
        // 转账确认必填项3个, 银行卡密码，手机号，短信验证码
        return Promise { fulfill, reject in
            let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
            let values = form.values()
            // TODO: 转账确认
            if let _ = values["card_pass"] as? String,
                let _ = values["mobile"] as? String,
                let _ = values["sms_code"] as? String {
                let param = BankCardParameter()
                param.cardID = transParam.cardID
                param.amount = transParam.amount
                param.crossTrans = transParam.crossTrans
                param.receiverName = transParam.receiverName
                param.receiverCardNo = transParam.receiverCardNo
                param.receiverBankID = transParam.receiverBankID
                param.receiverMobile = transParam.receiverMobile
                param.remark = transParam.remark
                fulfill(param)
            } else {
                reject(error)
            }
        }
    }
    
    @IBAction fileprivate func transConfirmHandle() {
        validInputs().then { (param) -> Void in
            self.performSegue(withIdentifier: R.segue.transConfirmViewController.showTransSuccessVC, sender: nil)
            }.catch { _ in }
//        MBProgressHUD.showHUDAddedTo(view, animated: true)
//        validInputs().then { (param) -> Promise<NullDataResponse> in
//            return handleRequest(Router.endpoint(endpoint: BankCardPath.Trans, param: param))
//        }.then { (value) -> Void in
//            // success
//        }.always { 
//            MBProgressHUD.hideHUDForView(self.view, animated: true)
//        }.error { (error) in
//            if let err = error as? AppError {
//                Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
//            }
//        }
    }
    
    @objc func refreshCaptcha() {
        guard let value = form.values()["mobile"] as? String else {
            let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
            Navigator.showAlertWithoutAction(nil, message: error.toError().localizedDescription)
            return
        }
        let mobile = value.stringByRemovingCharactersInSet(CharacterSet.whitespaces)
        guard let captchaVC = R.storyboard.container.captchaViewController() else { return }
        captchaVC.mobile = mobile.stringByRemovingCharactersInSet(CharacterSet.whitespaces)
        captchaVC.smsType = .balanceTrans
        captchaVC.finishHandle = { [weak self] captcha in
            if let cap = captcha, !cap.isEmpty {
                self?.form.setValues(["sms_code": cap])
                self?.tableView?.reloadData()
            }
            self?.dim(.out, coverNavigationBar: true)
            self?.dismiss(animated: true, completion: nil)
        }
        dim(.in, coverNavigationBar: true)
        present(captchaVC, animated: true, completion: nil)
    }
    
    override func textInput<T>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool {
        if cell.row.tag != "mobile" {
            return true
        } else {
            guard let textField = textInput as? UITextField else { return false }
            return validatePhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
        }
    }
}

extension TransConfirmViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 17.0
        }
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 17.0
        }
        return 10.0
    }
}

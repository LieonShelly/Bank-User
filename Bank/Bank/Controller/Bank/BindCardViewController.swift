//
//  BindingOtherBackCarViewController.swift
//  Bank
//
//  Created by Mac on 15/11/24.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import Eureka
import PromiseKit
import URLNavigator
import ObjectMapper
import MBProgressHUD
import Device

class BindCardViewController: FormViewController {
    
    @IBOutlet fileprivate weak var footerView: UIView!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    @IBOutlet fileprivate weak var acceptButton: UIButton!
    @IBOutlet weak var treatyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var remarkLabel: UILabel!
    
    fileprivate let helpHtmlName = "PeerCardHelp"
    fileprivate var codeButton = CodeButton()
    fileprivate var phoneNumber: String = ""
    fileprivate var idCard: String = ""
    fileprivate var bankCardNum: String = ""
    fileprivate var myContext = 0
    fileprivate var step: Int = 1
    fileprivate var param = BankCardParameter()
    // 是否有身份信息
    fileprivate var isHasInfo: Bool = false
    // 银行预留的手机号
    fileprivate var bankMobile: String?
    
    var lastViewController: UIViewController?
    var verifyPayPassword: String?
    var bindCardType: PaymentType = .currentBank
    var name: String = ""
    var isSigned: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if bindCardType == .currentBank {
            title = R.string.localizable.bank_bind_card_title()
        } else if bindCardType == .otherBank {
            title = R.string.localizable.bank_bind_other_card_title()
        }
        self.isHasInfo = !self.name.isEmpty
        setLeftBarButton()
        setBackBarButton()
        setupTableView()
        requestBind(step: 0)
    }
    
    override func leftAction() {
        if step == 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            step -= 1
            form.removeAll()
            self.setupRows()
        }
    }

    func setupTableView() {
        
        codeButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 30))
        codeButton.setTitle(R.string.localizable.button_title_get_code(), for: UIControlState())
        codeButton.layer.cornerRadius = 2.0
        codeButton.titleLabel?.font = .systemFont(ofSize: 13.0)
        codeButton.setTitleColor(UIColor.white, for: UIControlState())
        codeButton.isEnabled = false
        codeButton.backgroundColor = UIColor(hex: 0xc9c9ce)
        codeButton.addTarget(self, action: #selector(self.requestVerifyCode), for: .touchUpInside)
        if Device.size() == .screen4Inch || Device.size() == .screen3_5Inch {
            codeButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 20))
            codeButton.titleLabel?.font = .systemFont(ofSize: 11.0)
        }
        tableView?.configBackgroundView()
        tableView?.tableFooterView = footerView
    }
    
    fileprivate func setupRows() {
        if isHasInfo && step == 1 {
            form +++ Section()
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_card_name_title()
                    $0.tag = R.string.localizable.eureka_textrow_title_name_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_name_placeholder()
                    $0.value = self.name
                    $0.cell.textField.isUserInteractionEnabled = self.name.isEmpty
                    }.cellSetup { (cell, row) in
                        cell.textField.keyboardType = .default

                    }.onChange { (row) in
//                        row.cell.textField.isUserInteractionEnabled = self.name.isEmpty
                }
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_number_title()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_number_paceholder()
                    $0.tag = R.string.localizable.eureka_textrow_title_number_tag()
                    $0.value = self.bankCardNum
                    }.cellSetup({ (cell, row) in
                        cell.textField.keyboardType = .numberPad
                    })
            confirmButton.setTitle("下一步", for: UIControlState())
        } else if isHasInfo && step == 2 {
            form +++ Section()
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_phone_title()
                    $0.tag = R.string.localizable.eureka_textrow_title_phone_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_phone_paceholder()
                    $0.value = self.phoneNumber
                    }.cellSetup { (cell, row) in
                        cell.textField.keyboardType = .numberPad
                    }
            confirmButton.setTitle("下一步", for: UIControlState())
        } else if isHasInfo && step == 3 {
            form +++ Section()
                <<< TextRow() {
                    $0.tag = R.string.localizable.eureka_textrow_title_verify_code_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_verify_code_paceholder()
                    $0.textFieldLeftConst = 17
                    }.cellSetup({ (cell, row) in
                        cell.textField.keyboardType = .numberPad
                        cell.accessoryView = self.codeButton
                    })
            confirmButton.setTitle("确定", for: UIControlState())
        } else if !isHasInfo && step == 1 {
            form +++ Section()
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_number_title()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_number_paceholder()
                    $0.tag = R.string.localizable.eureka_textrow_title_number_tag()
                    $0.value = self.bankCardNum
                    }.cellSetup({ (cell, row) in
                        cell.textField.keyboardType = .numberPad
                    })
            confirmButton.setTitle("下一步", for: UIControlState())
        } else if !isHasInfo && step == 2 {
            form +++ Section()
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_name_title()
                    $0.tag = R.string.localizable.eureka_textrow_title_name_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_name_placeholder()
                    $0.value = self.name
                    $0.cell.textField.isUserInteractionEnabled = self.name.isEmpty
                    }.cellSetup { (cell, row) in
                        cell.textField.keyboardType = .default
                        //                    cell.textField.text = self.name
                    }.onChange { (row) in
//                        row.cell.textField.isUserInteractionEnabled = self.name.isEmpty
                }
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_id_title()
                    $0.tag = R.string.localizable.eureka_textrow_title_id_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_id_placeholder()
                    $0.value = self.idCard
                    }.cellSetup({ (cell, row) in
                        cell.textField.keyboardType = .default
                    })
                +++ Section()
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_phone_title()
                    $0.tag = R.string.localizable.eureka_textrow_title_phone_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_phone_paceholder()
                    $0.value = phoneNumber
                    }.cellSetup { (cell, row) in
                        cell.textField.keyboardType = .numberPad
            }
            confirmButton.setTitle("下一步", for: UIControlState())
        } else if !isHasInfo && step == 3 {
            form +++ Section()
                <<< TextRow() {
                    $0.textFieldLeftConst = 17
                    $0.tag = R.string.localizable.eureka_textrow_title_verify_code_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_verify_code_paceholder()
                    }.cellSetup({ (cell, row) in
                        cell.textField.keyboardType = .numberPad
                        cell.accessoryView = self.codeButton
                    })
            confirmButton.setTitle("确定", for: UIControlState())
        }
        
        if step == 2 {
            treatyViewHeight.constant = 50
        } else {
            treatyViewHeight.constant = 0
        }
        if step == 2 && !isHasInfo {
            remarkLabel.isHidden = false
        } else {
            remarkLabel.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonHandle() {
        requestBind(step: self.step)
    }
    
    @IBAction fileprivate func checkHandle(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction fileprivate func showTOS() {
        guard let vc = R.storyboard.main.helpViewController() else { return }
        vc.title = "绑定银行卡协议"
        var string = WebViewURL.protocol.URL()
        if AppConfig.shared.userInfo?.isSigned == true {
            string.append("?tag=0102")
        } else {
            string.append("?tag=0402")
        }
        if let url = URL(string: string) {
            vc.loadURL(url)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showHelpVC", let vc = segue.destination as? HelpViewController {
            vc.htmlName = helpHtmlName
        }
    }
    
    func validateIdentityCard(_ identityCard: String) -> Bool {
        let idRegex = "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X|x)$"
         let identifyCardPredicate: NSPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
        return identifyCardPredicate.evaluate(with: identityCard)
    }
    
    override func textInput<T>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool {
        if cell.row.tag != "mobile" {
            return true
        } else {
            guard let textField = textInput as? UITextField else { return false }
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
}

// MARK: - Request
extension BindCardViewController {
    func requestVerifyCode() {
        guard let captchaVC = R.storyboard.container.captchaViewController() else { return }
        let mobile = phoneNumber.stringByRemovingCharactersInSet(CharacterSet.whitespaces)
        if mobile.characters.count == 11 {
            //            guard mobile == self.phoneNumber else {
            //                let error = AppError(code: ValidInputsErrorCode.inputReservedPhoneNumber, msg: nil)
            //                Navigator.showAlertWithoutAction(nil, message: error.toError().localizedDescription)
            //                return
            //            }
            captchaVC.mobile = mobile
            captchaVC.smsType = .bindCard
            captchaVC.finishHandle = { [weak self] captcha in
                if let cap = captcha, !cap.isEmpty {
                    self?.form.setValues(["verify_code": cap])
                    let row = self?.form.rowBy(tag: "verify_code")
                    row?.updateCell()
                    self?.codeButton.starTime()
                }
                self?.dim(.out, coverNavigationBar: true)
                self?.dismiss(animated: true, completion: nil)
            }
            dim(.in, coverNavigationBar: true)
            present(captchaVC, animated: true, completion: nil)
        } else {
            let error = AppError(code: ValidInputsErrorCode.inputRightPhoneNumber, msg: nil)
            Navigator.showAlertWithoutAction(nil, message: error.toError().localizedDescription)
        }
        
    }
    
    func requestBind(step: Int) {
        let hud = MBProgressHUD.loading(view: view)
        validInput(step: step).then { (value) -> Promise<BindCardData> in
            return handleRequest(Router.endpoint(BankCardPath.bind, param: value))
            }.then { (value) -> Void in
                self.bankMobile = value.data?.mobile
                if step == 0 {
                    if let isInfo = value.data?.isInfo {
                        self.isHasInfo = isInfo
                        self.setupRows()
                    }
                    return
                }
                self.step += 1
                if self.step > 3 {
                    self.step = 3
                } else {
                    self.form.removeAll()
                    self.setupRows()
                }
                if step == 3 {
                    MBProgressHUD.errorMessage(view: self.view, message: "银行卡绑定成功")
                    let deadlineTime = DispatchTime.now() + .milliseconds(2000)
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                        if self.lastViewController != nil {
                            self.performSegue(withIdentifier: R.segue.bindCardViewController.showPayViewVC, sender: nil)
                        } else {
                            self.performSegue(withIdentifier: R.segue.bindCardViewController.showCardsListVC, sender: nil)
                        }
                    })
                }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    func validInput(step: Int) -> Promise<BankCardParameter> {
        return Promise { fulfill, reject in
            let dic = form.values()
            let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
            switch step {
            case 1:
                if isHasInfo {
                    if let name = !self.name.characters.isEmpty ? self.name : dic["name"] as? String, let number = dic["number"] as? String {
                        guard number.characters.count <= 19 else {
                            let error = AppError(code: ValidInputsErrorCode.inputRightBankCard, msg: nil)
                            reject(error)
                            return
                        }
                        self.name = name
                        self.bankCardNum = number
                        param.holderName = name
                        param.cardNo = number
                    } else {
                        reject(error)
                    }
                } else {
                    if let number = dic["number"] as? String {
                        guard number.characters.count <= 19 else {
                            let error = AppError(code: ValidInputsErrorCode.inputRightBankCard, msg: nil)
                            reject(error)
                            return
                        }
                        self.bankCardNum = number
                        param.cardNo = number
                    } else {
                        reject(error)
                    }
                }
            case 2:
                if isHasInfo {
                    if let mobile = dic["mobile"] as? String, mobile.stringByRemovingCharactersInSet(CharacterSet.whitespaces).characters.count == 11 {
                        if mobile.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces) != self.bankMobile {
                            let error = AppError(code: ValidInputsErrorCode.inputRightPhoneNumber, msg: nil)
                            reject(error)
                            return
                        }
                        self.phoneNumber = mobile
                        param.holderMobile = mobile.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
                    } else {
                        reject(error)
                    }
                } else {
                    if let name = dic["name"] as? String, let idcard = dic["idcard"] as? String, let mobile = dic["mobile"] as? String, mobile.stringByRemovingCharactersInSet(CharacterSet.whitespaces).characters.count == 11 {
                        guard validateIdentityCard(idcard) else {
                            let error = AppError(code: ValidInputsErrorCode.idCardLengthError, msg: nil)
                            reject(error)
                            return
                        }
                        if mobile.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces) != self.bankMobile {
                            let error = AppError(code: ValidInputsErrorCode.inputRightPhoneNumber, msg: nil)
                            reject(error)
                            return
                        }
                        self.name = name
                        self.idCard = idcard
                        self.phoneNumber = mobile
                        param.holderName = name
                        param.idNumber = idCard
                        param.holderMobile = mobile.stringByRemovingCharactersInSet(NSCharacterSet.whitespaces)
                    } else {
                        reject(error)
                    }
                }
            case 3:
                if let code = dic["verify_code"] as? String {
                    param.verifyCode = code
                } else {
                    reject(error)
                }
            default:
                break
            }
            param.step = step + 1
            if !acceptButton.isSelected && step == 2 {
                let error = AppError(code: ValidInputsErrorCode.notAcceptAgreements, msg: nil)
                reject(error)
            } else {
                fulfill(param)
            }
        }
    }

}

// MARK: Table View Delegate
extension BindCardViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

//
//  VerifyPayPassViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/22.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable empty_count
// swiftlint:disable force_unwrapping

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import Device

public enum VerifyPayPassResult {
    case passed
    case failed
    case canceled
}

/// 支付用途
public enum VerifyPayPassType {
    /// 在线购物订单支付
    case onlinePay
    /// 优惠买单付款
    case privilegePay
    /// 现金还款
    case moneyRepay
    /// 仅验证支付密码
    case verify
}

class VerifyPayPassViewController: BaseViewController {
    
    let pwdCount = 6
    
    @IBOutlet fileprivate weak var passTextField: UITextField!
    @IBOutlet fileprivate var dotLabels: [UILabel]!
    @IBOutlet fileprivate weak var tipLabel: UILabel!
    @IBOutlet var payView: UIView!
    @IBOutlet weak var payPassView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    internal var numberInput: InputView?
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet private weak var toolbar: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var codeTipLabel: UILabel!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    fileprivate var timer: Timer!
    fileprivate var timeInterval: Int = 60
    fileprivate var userPay: UserPay?
    fileprivate var codeStatus: CodeStatus = .wait {
        didSet {
            sendCodeButton.backgroundColor = codeStatus == .allow ? UIColor(hex: 0x00a8fe) : UIColor(hex: 0xd3d3d7)
            confirmButton.isEnabled = codeTextField.text?.characters.isEmpty == true ? false : true
            confirmButton.backgroundColor = codeTextField.text?.characters.isEmpty == true ? UIColor(hex: 0xd2d2d2) : UIColor(hex: 0xfc8d25)
            let title = codeStatus == .allow ? "重新发送" : "60s"
            sendCodeButton.isEnabled = codeStatus == .allow ? true : false
            sendCodeButton.setTitle(title, for: UIControlState())
            let titleColor = codeStatus == .allow ? UIColor.white : UIColor(hex: 0x666666)
            sendCodeButton.setTitleColor(titleColor, for: UIControlState())
            if codeStatus == .wait {
                // 添加定时器
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
                RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
            } else {
                timer.invalidate()
                timer = nil
            }
        }
    }
    var cardID: String?
    var subOrderIDs: [String]?
    var orderID: String?
    var money: String?
    var resultHandle: ((VerifyPayPassResult, String?) -> Void)?
    var type: VerifyPayPassType = .verify

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        passTextField.tag = 1
        codeTextField.tag = 2
        passTextField.addTarget(self, action: #selector(codeHandle(_:)), for: .editingChanged)
        for label in dotLabels {
            label.isHidden = true
        }
        numberInput = R.nib.inputView().instantiate(withOwner: self, options: nil).first as? InputView
        numberInput?.keyInput = passTextField
        passTextField.inputView = numberInput
        passTextField.inputAccessoryView = toolbar
        let tap = UITapGestureRecognizer(target: self, action: #selector(showKeyBoard(_:)))
        stackView.addGestureRecognizer(tap)
        let title = type == .verify ? R.string.localizable.alertTitle_confirm() : "下一步"
        nextButton.setTitle(title, for: UIControlState())
        
        switch Device.size() {
        case .screen4Inch:
            viewHeight.constant = 485
        case .screen4_7Inch:
            viewHeight.constant = 495
        case .screen5_5Inch:
            viewHeight.constant = 505
        default:
            viewHeight.constant = 485
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc fileprivate func showKeyBoard(_ tap: UITapGestureRecognizer) {
        passTextField.becomeFirstResponder()
    }
    
    @objc fileprivate func timerAction() {
        timeInterval -= 1
        sendCodeButton.titleLabel?.text = "\(timeInterval)s"
        sendCodeButton.setTitle("\(timeInterval)s", for: UIControlState())
        if timeInterval == 0 {
            codeStatus = .allow
            if codeTextField.text?.characters.isEmpty == true {
                confirmButton.isEnabled = false
                confirmButton.backgroundColor = UIColor(hex: 0xd2d2d2)
            } else {
                confirmButton.isEnabled = true
                confirmButton.backgroundColor = UIColor(hex: 0xfc8d25)
            }
        }
    }
    // 短信页面取消
    @IBAction func cancelHandleMsg(_ sender: Any) {
        requestDeblock()
        dismiss(.canceled, payPass: nil)
    }
    
    /// 取消
    @IBAction fileprivate func cancelHandle() {
        requestDeblock()
        dismiss(.canceled, payPass: nil)
    }
    
    /// 确认支付密码(点击下一步)
    @IBAction fileprivate func confirmHandle() {
        view.endEditing(true)
        if type == .verify {
            requestVerify()
        } else {
            requestVerifyForPay()
        }
    }
    
    /// 下一步
    fileprivate func next() {
        payView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: payPassView.frame.height)
        view.addSubview(payView)
        UIView.animate(withDuration: 0.5) {
            self.payView.frame = self.payPassView.frame
        }
        codeStatus = .wait
        guard let mobile = userPay?.mobile else { return }
        codeTipLabel.text = "(短信验证码已发送至\(mobile))"
        codeTextField.addTarget(self, action: #selector(codeHandle(_:)), for: .editingChanged)

    }
    
    @objc fileprivate func codeHandle(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            self.setDotWithCount(textField.text?.characters.count ?? 0)
            if textField.text?.characters.count == 6 {
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor(hex: 0xfc8d25)
            } else {
                nextButton.isEnabled = false
                nextButton.backgroundColor = UIColor(hex: 0xd2d2d2)
            }
        case 2:
            if textField.text?.characters.isEmpty == true {
                confirmButton.isEnabled = false
                confirmButton.backgroundColor = UIColor(hex: 0xd2d2d2)
            } else {
                confirmButton.isEnabled = true
                confirmButton.backgroundColor = UIColor(hex: 0xfc8d25)
            }
        default:
            break
        }
    }
    
    /// 发送验证码
    @IBAction func resendCode(_ sender: UIButton) {
        requestSendCode()
    }
    
    /// 确认支付
    @IBAction func confirmPay(_ sender: UIButton) {
        switch type {
        case .verify:
            break
        case .onlinePay:
            requestOnlinePay()
        case .privilegePay:
            requestPrivilegePay()
        case .moneyRepay:
            requestMoneyRepay()
        }
    }
    
    fileprivate func setDotWithCount(_ count: Int) {
        for dot in dotLabels {
            dot.isHidden = true
        }
        
        for i in 0..<min(count, 6) {
            dotLabels[i].isHidden = false
        }
    }
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func dismiss(_ result: VerifyPayPassResult, payPass: String?) {
        passTextField.resignFirstResponder()
        if let block = resultHandle {
            block(result, payPass)
        }
    }
}

extension VerifyPayPassViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        numberInput?.loadOnlyNumbers()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if (textField.text?.characters.count >= pwdCount) && (string.characters.count > 0) {
            return false
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]*$")
        if !predicate.evaluate(with: string) {
            return false
        }
        
        var totalString: String
        if string.characters.count <= 0 {
            let index = textField.text?.characters.index((textField.text?.endIndex)!, offsetBy: -1)
            totalString = textField.text!.substring(to: index!)
        } else {
            totalString = textField.text! + string
        }
        
        self.setDotWithCount(totalString.characters.count)
        return true
    }
    
}

// MARK: - Request
extension VerifyPayPassViewController {
    /// 验证支付密码(仅验证)
    fileprivate func requestVerify() {
        if passTextField.text?.characters.count != 6 {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_password_count_error())
            return
        }
        MBProgressHUD.loading(view: view)
        let param = UserParameter()
        param.payPassword = passTextField.text
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.verifyPayPassword, param: param))
        req.then { (value) -> Void in
            self.view.endEditing(true)
            self.dismiss(.passed, payPass: param.payPassword)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                guard let err = error as? AppError else { return }
                self.setDotWithCount(0)
                self.passTextField.text = nil
                if err.errorCode.errorCode() == RequestErrorCode.payPassError.errorCode() {
                    self.tipLabel.text = err.toError().localizedDescription
                    self.tipLabel.isHidden = false
                } else if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    // 密码错误次数已达上限
                    self.dismiss(.failed, payPass: param.payPassword)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 验证支付密码(用于支付)
    fileprivate func requestVerifyForPay() {
        MBProgressHUD.loading(view: view)
        let param = UserPayParameter()
        param.payPass = passTextField.text
        param.cardID = cardID
        let req: Promise<UserPayData> = handleRequest(Router.endpoint( UserPayPath.verifyPayPass, param: param))
        req.then { (value) -> Void in
            self.view.endEditing(true)
            self.userPay = value.data
            // 下一步验证短信验证码
            self.next()
            self.codeTextField.text = value.msg
            self.confirmButton.isEnabled = true
            self.confirmButton.backgroundColor = UIColor(hex: 0xfc8d25)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                guard let err = error as? AppError else { return }
                self.setDotWithCount(0)
                self.passTextField.text = nil
                if err.errorCode.errorCode() == RequestErrorCode.payPassError.errorCode() {
                    self.tipLabel.text = err.toError().localizedDescription
                    self.tipLabel.isHidden = false
                } else if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    // 密码错误次数已达上限
                    self.dismiss(.failed, payPass: param.payPass)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 发送验证码
    fileprivate func requestSendCode() {
        MBProgressHUD.loading(view: view)
        let param = UserPayParameter()
        param.token = self.userPay?.token
        let req: Promise<UserPayData> = handleRequest(Router.endpoint( UserPayPath.sendSmsCode, param: param))
        req.then { (value) -> Void in
                self.codeTextField.text = value.msg
                self.userPay = value.data
                self.codeStatus = .wait
                self.timeInterval = 60
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 支付在线购物订单
    fileprivate func requestOnlinePay() {
        MBProgressHUD.loading(view: view)
        let param = UserPayParameter()
        param.token = self.userPay?.token
        param.smsCode = codeTextField.text
        param.subOrderIDs = self.subOrderIDs
        let req: Promise<UserPayData> = handleRequest(Router.endpoint( UserPayPath.onlinePay, param: param))
        req.then { (value) -> Void in
            self.userPay = value.data
            // 返回一个支付成功的result
            self.dismiss(.passed, payPass: param.payPass)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 优惠买单付款
    fileprivate func requestPrivilegePay() {
        MBProgressHUD.loading(view: view)
        let param = UserPayParameter()
        param.token = self.userPay?.token
        param.smsCode = codeTextField.text
        param.orderID = self.orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPayPath.privilegePay, param: param))
        req.then { (value) -> Void in
            // 返回一个支付成功的result
            self.dismiss(.passed, payPass: param.payPass)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 现金还款
    fileprivate func requestMoneyRepay() {
        MBProgressHUD.loading(view: view)
        let param = UserPayParameter()
        param.token = self.userPay?.token
        param.smsCode = codeTextField.text
        param.money = self.money
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPayPath.moneyRepay, param: param))
        req.then { (value) -> Void in
            // 返回一个支付成功的result
            self.dismiss(.passed, payPass: param.payPass)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 解锁支付
    fileprivate func requestDeblock() {
        let param = LockOrderParameter()
        guard let subOrderIds = subOrderIDs else {return}
        param.subOrderIds = subOrderIds
        param.lockTime = 1
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPayPath.lockOrder, param: param))
        req.then { (value) -> Void in
            }.always {
            }.catch { (error) in
        }
    }
}

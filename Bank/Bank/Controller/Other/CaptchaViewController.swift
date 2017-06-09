//
//  CaptchaViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class CaptchaViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tipLabel: UILabel!
    @IBOutlet fileprivate weak var captchaImageView: UIImageView!
    @IBOutlet fileprivate weak var textField: UITextField!
    
    var mobile: String?
    var smsType: MobileVerifyType?
    var finishHandle: ((_ captcha: String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        requestCaptcha()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func requestCaptcha() {
        guard let mobile = mobile else { return }
        let param = HomeBasicParameter()
        param.mobile = mobile.stringByRemovingCharactersInSet(CharacterSet.whitespaces)
        let req: Promise<ImageCaptchaData> = handleRequest(Router.endpoint( HomeBasicPath.captcha, param: param), needToken: .false)
        req.then { (value) -> Void in
            guard let string = value.data?.imageData, let imageData = Data(base64Encoded: string, options: [.ignoreUnknownCharacters]), let image = UIImage(data: imageData) else {
                return
            }
            
            self.tipLabel.textColor = UIColor(hex: 0x686868)
            self.tipLabel.text = R.string.localizable.input_captcha_tip()
            self.captchaImageView.image = image
        }.catch { (_) in
            
        }
    }
    
    fileprivate func requestSMSCode(_ mobile: String, captcha: String) -> Promise<NullDataResponse> {
        let param = HomeBasicParameter()
        param.mobile = mobile.stringByRemovingCharactersInSet(CharacterSet.whitespaces)
        param.verifyType = smsType
        param.captcha = captcha
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( HomeBasicPath.smsVerifyCode, param: param), needToken: .false)
        return req
    }
    
    @IBAction fileprivate func buttonHandle(_ sender: UIButton) {
        guard let block = finishHandle else { return }
        if sender.tag == 0 {
            // cancel
            block(nil)
        } else {
            if let text = textField.text, !text.isEmpty, let mobile = mobile {
                MBProgressHUD.loading(view: view)
                requestSMSCode(mobile, captcha: text).then { (value) -> Void in
                    block(value.msg)
                }.always {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }.catch { (error) in
                    guard let err = error as? AppError else { return }
                    if err.errorCode.errorCode() == RequestErrorCode.imageCaptchaError.errorCode() {
                        self.tipLabel.text = R.string.localizable.input_captcha_error()
                        self.tipLabel.textColor = UIColor.red
                        self.textField.text = nil
                        self.requestCaptcha()
                    } else {
                        Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
                    }
                }
            } else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                Navigator.showAlertWithoutAction(nil, message: error.toError().localizedDescription)
            }
        }
    }
}

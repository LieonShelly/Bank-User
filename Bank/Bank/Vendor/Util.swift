//
//  Util.swift
//  Bank
//
//  Created by Koh Ryu on 2016/12/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import MBProgressHUD

class Util {
    /*ID身份证验证*/
    class func isValidateIDNumber(_ idNumb: String) -> Bool {
        let emailRegex = "^[0-9]{17}[0-9X]$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: idNumb)
    }
    
    class func isValidatePassword(_ password: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z_]{6,16}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: password)
    }
    
    class func isOnlyNumber(_ str: String?) -> Bool {
        let numberRegex = "[0-9.-]+"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        return numberTest.evaluate(with: str)
    }
    
    class func isValidLegalPersonName(_ str: String?) -> Bool {
        let numberRegex = "[\\u4e00-\\u9fa5]{2,13}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        return numberTest.evaluate(with: str)
    }
    
    class func isValidBankCardNumber(_ str: String?) -> Bool {
        let numberRegex = "[0-9]{19}"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        return numberTest.evaluate(with: str)
    }
    
    /*工商注册号验证*/
    class func isValidLegalCode(_ idNumb: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z]{18}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: idNumb)
    }
    
    /*验证店铺名应为15个字以内汉字、英文字母或数字组成*/
    class func isValidateShopName(_ name: String) -> Bool {
        let emailRegex = "[\\u4e00-\\u9fa5A-Z0-9a-z]{1,15}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: name)
    }
    
    class func containsChineseEnglishAndNumber(_ str: String, length: Int) -> Bool {
        let regex = "[\\u4e00-\\u9fa5A-Z0-9a-z]{1,\(length)}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: str)
    }
    
    class func isValidURL(_ url: String) -> Bool {
        let urlRegex = "^http[s]{0,1}://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$"
        let test = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return test.evaluate(with: url)
        
    }
    
    /*手机号*/
    class func isPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[1-9][0-9]{4,14}$"
        let test = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return test.evaluate(with: phone)
    }
    
    /*姓名*/
    class func isTrueName(_ name: String) -> Bool {
        let nameRegex = "^(([\\u4e00-\\u9fa5]{2,8})|([a-zA-Z]{2,16}))$"
        let test = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return test.evaluate(with: name)
    }
}

extension MBProgressHUD {
    
    /*
     1、没有网络的时候  提示：网络断开连接，请检查手机网络。
     2、请求超时。 提示：请求超时，请稍后再试。
     3、服务器请求失败。 提示：请求失败，服务器维护中。
     4、服务器返回业务逻辑错误。 提示接口json里面 msg 对应的信息。
     5. 网页和请求过程 显示 加载中和风火轮
     */
    @discardableResult class func networkNotReachableHud(view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = R.string.localizable.hud_disconnect()
        hud.hide(animated: true, afterDelay: 3.0)
        return hud
    }
    
    @discardableResult class func requestTimeout(view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD(view: view)
        hud.mode = .text
        hud.label.text = R.string.localizable.hud_request_timeout()
        return hud
    }
    
    @discardableResult class func requestFailed(view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD(view: view)
        hud.mode = .text
        hud.label.text = R.string.localizable.hud_request_failed()
        return hud
    }
    
    @discardableResult class func loading(view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = R.string.localizable.hud_loading()
        return hud
    }
    
    @discardableResult class func errorMessage(view: UIView, message: String?) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.numberOfLines = 0
        hud.label.textAlignment = .left
        hud.label.text = message
        hud.hide(animated: true, afterDelay: 3.0)
        return hud
    }
}

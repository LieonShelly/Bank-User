//
//  AppConfig.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/15.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import URLNavigator
import MBProgressHUD
import ObjectMapper

class AppConfig {
    
    fileprivate static let sharedInstance = AppConfig()
    lazy var networkListener = NetworkReachabilityManager(host: "www.baidu.com")
    lazy var keychainData: KeychainData = KeychainData()
    var pushToken: String? = "nopushtoken"
    var registrationID: String? = ""

    var baseData: BaseData?
    lazy var userInfo: User? = User()
    var isUserSigned: Bool = false {
        didSet {
            // save userdefauls
            UserDefaults.standard.set(isUserSigned, forKey: CustomKey.UserDefaultsKey.isSigned)
        }
    }
    
    var rememberAccountStatus: RememberAccountType? {
        didSet {
            if rememberAccountStatus == .manualQuitAccount {
                isLoginFlag = false
            }
            do {
                try  rememberAccountStatus?.rawValue.write(toFile: Const.appStatusFilePath, atomically: true, encoding: String.Encoding.utf8)
                
            } catch {
                debugPrint("存储rememberAccountStatus失败")
            }
        }
    }
    var isLoginFlag: Bool = false
    fileprivate var timeInterval: TimeInterval = 0.0
    var launchShortcutItemURL: URL?
    var encrypt: Bool = false
    /// 未读消息数
    var unreadCount: Int = 0 {
        didSet {
            if unreadCount <= 0 {
                unreadCount = 0
            }
        }
    }
    
    class var shared: AppConfig {
        return sharedInstance
    }
    
    init() {
        let value = UserDefaults.standard.bool(forKey: CustomKey.UserDefaultsKey.firstLaunchAfterColdInstall)
        if !value {
            // clean keychain data
            keychainData.removeSession()
            UserDefaults.standard.set(true, forKey: CustomKey.UserDefaultsKey.firstLaunchAfterColdInstall)
        }
        isUserSigned = UserDefaults.standard.bool(forKey: CustomKey.UserDefaultsKey.isSigned)
        
        networkListener?.listener = { status in
            if status == .notReachable {
                if let window = UIApplication.shared.keyWindow {
                    MBProgressHUD.networkNotReachableHud(view: window)
                }
            }
        }
        networkListener?.startListening()
        if let value = Bundle.main.infoDictionary?["ENCRYPT"] as? String, let enc = Bool(value) {
            encrypt = enc
        }
        if let token = keychainData.sessionToken, !token.isEmpty {
            print("====token [\(token)]")
            isLoginFlag = true
        }
    }
    
    func getRememberAccountType() -> RememberAccountType {
        do {
            let type =  try String(contentsOfFile: Const.appStatusFilePath) as String
            return RememberAccountType.needRemember(type)
        } catch {
            debugPrint("获取是否记住账号标志失败")
        }
        return RememberAccountType.normalStatus
    }
    
    /// 消息置为已读
    func requestToggleRead(_ messageID: String?) {
        let param = UserParameter()
        param.messageID = messageID
        let req: Promise<NullDataResponse> =
            handleRequest(Router.endpoint( UserPath.readNotification, param: param))
        req.then { (value) -> Void in
        }.catch { _ in }
    }
}

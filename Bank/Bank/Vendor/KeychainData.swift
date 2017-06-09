//
//  KeychainData.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/16.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import Foundation
import KeychainAccess
import PromiseKit
import ObjectMapper

struct KeychainData {
    
    fileprivate let keyUUID = "UUID"
    fileprivate let keyToken = "TOKEN"
    fileprivate let keyPublicKey = "PublicKey"
    fileprivate let sessionAccountMobileKey = "sessionAccountMobileKey"
    fileprivate let keyFingerLogin = "FingerLogin"
    fileprivate let keySession = "LoginSession"
    
    let keychain = Keychain(service: KeychainStore.account)

    var sessionToken: String? = nil {
        didSet {
            _ = save()
        }
    }
    var deviceUUID: String {
        didSet {
            _ = save()
        }
    }
    var publicKey: String? {
        didSet {
            _ = save()
        }
    }
    var mobile: String? {
        didSet {
            _ = save()
        }
    }

    var loginSession: String? {
        didSet {
            _ = save()
        }
    }
    
    /// 指纹登录信息
    var fingerLogin: String? {
        didSet {
            _ = save()
        }
    }
    
    init() {
        sessionToken = keychain[keyToken]
        if let uuid = keychain[keyUUID], !uuid.isEmpty {
            deviceUUID = uuid
        } else {
            deviceUUID = UUID().uuidString
        }
        publicKey = keychain[keyPublicKey]
        if let session = keychain[keySession] {
            loginSession = session
        }
        if let fingerLogin = keychain[keyFingerLogin] {
            self.fingerLogin = fingerLogin
        }
        _ = save()
    }
    
    mutating func removeSession() {
        do {
            try keychain.remove(keySession)
            try keychain.remove(keyToken)
            sessionToken = nil
            loginSession = nil
        } catch {}
    }
    
    /// 获取账号 
    func getMobile() -> String {
        do {
            let account = try keychain.getString(sessionAccountMobileKey)
            return account ?? ""
        } catch {
            debugPrint("从keychain中获取账号失败")
        }
        return ""
    }
    /// 保存数据到 keychain
    func save() -> Bool {
        
        do {
            if let token = sessionToken {
                try keychain.set(token, key: keyToken)
            }
            try keychain.set(deviceUUID, key: keyUUID)
            if let key = publicKey {
                try keychain.set(key, key: keyPublicKey)
            }
            if let mobile = mobile {
                try keychain.set(mobile, key: sessionAccountMobileKey)
            }
            if let session = loginSession {
                print(session)
                try keychain.set(session, key: keySession)
            }
            if let fingerLogin = self.fingerLogin {
                try keychain.set(fingerLogin, key: keyFingerLogin)
            }
        } catch let error {
            // 保存 keychain 失败
            debugPrint("save keychain failed")
            debugPrint(error)
            return false
        }
        return true
    }
    
    /**
     判断是否有有效的session token
     
     - returns: **true**:有效, **false**:无效
     */
    func isValidSession() -> Bool {
        if let token = sessionToken, !token.isEmpty {
            return true
        }
        return false
    }
    
    /// 获取登录账号信息
    ///
    /// - returns: 返回登录账号信息
    func getLoginSession() -> String {
        do {
            let string = try keychain.getString(keySession)
            return string ?? ""
        } catch {
            debugPrint("从keychain中获取账号失败")
        }
        return ""
    }
    
    /// 获取指纹登录账号信息
    ///
    /// - returns: 返回指纹登录账号信息
    func getFingerLoginSession() -> String {
        do {
            let string = try keychain.getString(keyFingerLogin)
            return string ?? ""
        } catch {
            debugPrint("从keychain中获取账号失败")
        }
        return ""
    }

}

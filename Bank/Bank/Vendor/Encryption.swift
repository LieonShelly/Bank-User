//
//  Encryption.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/27.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyRSA

public class PayloadObject: Mappable {
    public var header: Header?
    public var post: [String: Any] = [:]
    public var get: [String: String] = [:]
    
    public init() {
        header = Header()
        post = [:]
        get = [:]
    }
    
    required public init?(map: Map) {
        fatalError("init has not been implemented")
    }
    
    public func mapping(map: Map) {
        header <- map["header"]
        post <- map["post"]
        get <- map["get"]
    }
}

public class KeysObject: Mappable {
    public var hash: String
    public var key: String
    public var ivSalt: String
    
    public init() {
        key = String.randomText(16)
        ivSalt = String.randomText(16)
        hash = ""
    }
    
    required public init?(map: Map) {
        fatalError("init has not been implemented")
    }
    
    public func mapping(map: Map) {
        hash <- map["hash"]
        key <- map["key"]
        ivSalt <- map["iv"]
    }
}

public class PostData: Mappable {
    public var keysObject: KeysObject
    public var payloadObject: PayloadObject
    public var keys: String
    public var payload: String
    
    public init() {
        keys = ""
        payload = ""
        keysObject = KeysObject()
        payloadObject = PayloadObject()
    }
    
    convenience public init(param: Mappable?, header: Header?) {
        self.init()
        if let p = param {
            payloadObject.post = p.toJSON()
        }
        if let head = header {
            payloadObject.header = head
        }
        guard let payloadString = payloadObject.toJSONString() else { return }
        keysObject.hash = payloadString.md5()
        
        guard let publicKey = AppConfig.shared.keychainData.publicKey else { return }
        guard let keysString = keysObject.toJSONString() else { return }
        
        do {
            keys = try SwiftyRSA.encryptString(keysString, publicKeyPEM: publicKey)
        } catch _ {
            
        }
        
        payload = payloadString.aesEncrypt(keysObject.key, ivSalt: keysObject.ivSalt)
    }
    
    public func decrypt(_ encryptString: String) -> String {
        let result = encryptString.aesDecrypt(keysObject.key, ivSalt: keysObject.ivSalt).stringByRemovingCharactersInSet(CharacterSet.controlCharacters)
        return result
    }
    
    required public init?(map: Map) {
        fatalError("init has not been implemented")
    }
    
    public func mapping(map: Map) {
        keys <- map["keys"]
        payload <- map["payload"]
    }
}

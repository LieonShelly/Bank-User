//
//  Model.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import Foundation
import ObjectMapper
import PINCache

extension Mappable {
    
    func saveToCache(key: String) {
        if let value = self.toJSONString(), !value.isEmpty {
            PINCache.shared().setObject((value as NSString), forKey: key)
        }
    }
    
    static func getFromCache(key: String, block: @escaping (Self) -> Void ) {
        PINCache.shared().object(forKey: key, block: { (cache, key, object) in
            if let value = object as? String, let instance = Mapper<Self>().map(JSONString: value) {
                block(instance)
            }
        })
    }
}

open class Model: Mappable {
    
    public init() {
        
    }
    
    // MARK: Mappable
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        
    }
    
}

// MARK: - Model Debug String
extension Model: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var str = "\n"
        let properties = Mirror(reflecting: self).children
        for c in properties {
            if let name = c.label {
                str += name + ": \(c.value)\n"
            }
        }
        return str
    }
}

//
//  StoreList.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 参与团购的分店列表
class StoreList: Model {
    var storeList: [Store]?
    
    override func mapping(map: Map) {
        storeList <- map["store_list"]
    }
}

class Store: Model {
    var storeID: String = ""
    var name: String?
    var address: String?
    var tel: String?
    
    override func mapping(map: Map) {
        storeID <- map["store_id"]
        name <- map["name"]
        address <- map["address"]
        tel <- map["tel"]
    }
}

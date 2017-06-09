//
//  Address.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class Address: Model {
    var addressID: String?
    var name: String?
    var regionPath: String?
    var region: String?
    var address: String?
    var mobile: String?
    /// 邮政编码
    var postCode: String?
    /// 是否默认地址
    var isDefault: Bool?
    
    override func mapping(map: Map) {
        addressID <- map["address_id"]
        name <- map["name"]
        regionPath <- map["region_path"]
        region <- map["region"]
        address <- map["address"]
        mobile <- map["mobile"]
        postCode <- map["postcode"]
        isDefault <- (map["is_default"], BoolStringTransform())
    }
}

class AddressList: Model {
    var addressList: [Address]?
    
    override func mapping(map: Map) {
        addressList <- map["address_list"]
    }
}

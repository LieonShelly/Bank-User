//
//  MobileRecharge.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//话费充值备选金额
class MobileRecharge: Model {
    var rechargeID: String = ""
    //充值金额
    var rechargeMoney: Float?
    var price: Float?
    
    override func mapping(map: Map) {
        rechargeID <- map["recharge_id"]
        rechargeMoney <- (map["recharge_money"], FloatStringTransform())
        price <- (map["price"], FloatStringTransform())
    }
}

//话费充值列表
class MobileRechargeList: Model {
    var rechargeList: [MobileRecharge]?
    
    override func mapping(map: Map) {
        rechargeList <- map["recharge_lsit"]
    }
}

//
//  Pay.swift
//  Bank
//
//  Created by yang on 16/5/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class UserPay: Model {
    var token: String?
    var mobile: String?
    /// 付款code
    var outTradeNo: String?
    
    override func mapping(map: Map) {
        token <- map["token"]
        mobile <- map["mobile"]
        outTradeNo <- map["out_trade_no"]
    }
}

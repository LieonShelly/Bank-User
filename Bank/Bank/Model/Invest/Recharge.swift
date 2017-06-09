//
//  Recharge.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 充值
class Recharge: Model {
    // TODO:
    var thisBank: AnyObject?
    var otherBank: AnyObject?
    var wechatPayBank: AnyObject?
    var alipayBank: AnyObject?
    
    override func mapping(map: Map) {
        thisBank <- map["this_bank"]
        otherBank <- map["other_bank"]
        wechatPayBank <- map["wechat_pay_bank"]
        alipayBank <- map["alipay_bank"]
    }
}

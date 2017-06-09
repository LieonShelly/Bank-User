//
//  MyCredit.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 我的信用
class MyCredit: Model {
    var totalCredit: Float = 0.0
    var availableCredit: Float = 0.0
    var creditGoodsList: [CreditGoods]?
    var isMoneyPay: Bool?
    var moneyPayTime: String = ""
    
    override func mapping(map: Map) {
        totalCredit <- (map["total_credit"], FloatStringTransform())
        availableCredit <- (map["available_credit"], FloatStringTransform())
        isMoneyPay <- (map["is_money_pay"], BoolStringTransform())
        creditGoodsList <- map["credit_goods_list"]
        moneyPayTime <- (map["money_pay_time"])
    }
}

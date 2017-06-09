//
//  EAccount.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 理财e账户
class EAccount: Model {
    /// 总资产
    var assets: Double = 0
    /// 累计收益
    var totalProfit: Float = 0
    /// 可用余额
    var availableProfit: Float = 0
    /// 信用额度
    var totalCredit: Float = 0
    /// 可用信用额度
    var availableCredit: Float = 0
    
    override func mapping(map: Map) {
        assets <- (map["assets"], DoubleStringTransform())
        totalProfit <- (map["total_profit"], FloatStringTransform())
        totalCredit <- (map["total_credit"], FloatStringTransform())
        availableCredit <- (map["available_credit"], FloatStringTransform())
        availableProfit <- (map["available_profit"], FloatStringTransform())
    }
}

class AccountStatement: Model {
    var stateID: String?
    var type: String?
    var detail: String?
    var changeAmount: Float = 0
    var balance: Float = 0
    var time: Date?
    
    override func mapping(map: Map) {
        stateID <- map["id"]
        type <- map["type"]
        detail <- map["detail"]
        changeAmount <- (map["change_amount"], FloatStringTransform())
        balance <- (map["after_amount"], FloatStringTransform())
        time <- (map["time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm"))
    }
}

class AccountDetailList: Model {
    var totalPage: Int = 0
    var totalItems: Int = 0
    var items: [AccountStatement]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

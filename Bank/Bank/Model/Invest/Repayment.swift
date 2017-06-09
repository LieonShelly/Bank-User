//
//  Repayment.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 还款
class Repayment: Model {
    var created: Date?
    var amount: Float = 0
    var payID: Int?
    var detail: String?
    var remainAmount: Float = 0
    var creat: String?
    
    override func mapping(map: Map) {
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:ss"))
        amount <- (map["amount"], FloatStringTransform())
        remainAmount <- (map["remain_amount"], FloatStringTransform())
        detail <- (map["detail"])
        payID <- (map["id"], IntStringTransform())
        creat <- (map["created"])
    }
}

/// 还款列表
class RepaymentList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [Repayment]?

    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

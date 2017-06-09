//
//  PaymentLogs.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//缴费记录
class PaymentLogs: Model {
    //收款单位
    var payee: String?
    var billType: BillType?
    //缴费户号/学号/手机号
    var number: String?
    var created: Date?
    var money: Float?

    override func mapping(map: Map) {
        payee <- map["payee"]
        billType <- map["bill_type"]
        number <- map["number"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        money <- (map["amount"], FloatStringTransform())
    }
}

//缴费记录列表
class PaymentLogsList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [PaymentLogs]?

    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

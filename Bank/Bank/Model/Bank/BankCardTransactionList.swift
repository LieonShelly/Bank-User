//
//  BankCardTransactionDetails.swift
//  Bank
//
//  Created by yang on 16/3/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//银行卡交易明细
class TransactionDetail: Model {
    var type: TransactionType?
    var time: Date?
    var money: Float?
    
    override func mapping(map: Map) {
        type <- map["type"]
        time <- (map["time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        money <- (map["money"], FloatStringTransform())
    }
}

//交易明细列表
class TransactionDetailsList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [TransactionDetail]?

    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

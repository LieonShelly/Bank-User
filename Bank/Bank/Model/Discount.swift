//
//  Discount.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 优惠买单
class Discount: Model {
    var orderID: String = ""
    var merchantName: String?
    var orderNO: String = ""
    var total: Double?
    var actual: Double?
    var payTime: Date?
    
    /// 不参与优惠金额
    var outSum: Double = 0
    var type: DiscountType?
    var discount: String?
    /// 最高优惠
    var fullSum: Double = 0
    /// 当前优惠
    var minusSum: Double = 0
    var ruleID: String = ""
    var privilegeName: String?
    var topPrivilege: Double?
    var rule: String?
    var isOpen: Bool = false
    
    override func mapping(map: Map) {
        orderID <- map["order_id"]
        merchantName <- map["store_name"]
        orderNO <- map["order_no"]
        total <- (map["total"], DoubleStringTransform())
        actual <- (map["actual"], DoubleStringTransform())
        payTime <- (map["pay_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        outSum <- (map["out_sum"], DoubleStringTransform())
        type <- map["type"]
        discount <- map["discount"]
        fullSum <- (map["full_sum"], DoubleStringTransform())
        minusSum <- (map["minus_sum"], DoubleStringTransform())
        ruleID <- map["rule_id"]
        privilegeName <- map["privilege_name"]
        topPrivilege <- (map["top_privilege"], DoubleStringTransform())
        rule <- map["rule"]
    }
}

/// 优惠买单订单列表
class DiscountList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Discount]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["cuttent_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
}

/// 优惠买单列表
class DiscountRuleList: Model {
    var ruleList: [Discount]?
    
    override func mapping(map: Map) {
        ruleList <- map["rule_list"]
    }
}

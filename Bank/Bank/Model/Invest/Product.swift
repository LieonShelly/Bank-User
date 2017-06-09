//
//  ProductObject.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//投资理财产品
class Product: Model {
    var productID: String = ""
    var title: String?
    /// 收益类型
    var type: ProductProfitType?
    var number: Int?
    // 计息开始时间
    var interestStart: Date?
    // 计息结束时间
    var interestEnd: Date?
    /// 开始时间
    var saleStart: Date?
    /// 结束时间
    var saleEnd: Date?
    /// 年化收益
    var profit: Float = 0
    var saleNum: Int?
    /// 计息方式
    var interestType: InterestType?
    /// 收益计算方式
    var incomeCalculation: IncomeCalculationType?
    /// 风险提示
    var risk: String?
    var remark: String?
    /// 购买金额
    var boughtAmount: Float = 0
    /// 是否人气
    var isHot: Bool = false
    /// 是否保本
    var isGuarantee: Bool = false
    /// 起投金额
    var minAmount: Float = 0
    /// 年化收益
    var aer: Float?
    var news: String?
    var status: ProductsStatus?
    
    var shareURL: URL?
    var html: String?
    
    override func mapping(map: Map) {
        productID <- map["product_id"]
        title <- map["title"]
        type <- map["type"]
        number <- (map["money"], IntStringTransform())
        interestStart <- (map["interest_start"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        interestEnd <- (map["interest_end"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        saleStart <- (map["sale_start"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        saleEnd <- (map["sale_end"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        profit <- (map["profit"], FloatStringTransform())
        saleNum <- (map["sale_num"], IntStringTransform())
        interestType <- map["interest_type"]
        incomeCalculation <- map["income_calculation"]
        risk <- map["risk"]
        remark <- map["remark"]
        
        boughtAmount <- (map["amount"], FloatStringTransform())
        isHot <- (map["is_hot"], BoolStringTransform())
        isGuarantee <- (map["is_guarantee"], BoolStringTransform())
        minAmount <- (map["min_amount"], FloatStringTransform())
        aer <- (map["aer"], FloatStringTransform())
        news <- map["news"]
        status <- map["status"]
        shareURL <- (map["share_url"], URLTransform())
        html <- map["html"]
    }
}

class ProductList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Product]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
}

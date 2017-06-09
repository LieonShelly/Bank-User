//
//  PointObject.swift
//  Bank
//
//  Created by yang on 16/4/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 积分明细
class PointObject: Model {
    var pointID: String = ""
    var type: String?
    var typeName: String?
    var detail: String?
    var point: Int?
    var created: Date?
    var redeemID: String = ""
    var approveStatus: ApproveStatus?
    var money: String?
    var card: String?
    var payee: String?
    var redeemUpdated: Date?
    var redeemCreated: Date?
    
    override func mapping(map: Map) {
        pointID <- map["point_id"]
        type <- map["type"]
        typeName <- map["type_name"]
        detail <- map["detail"]
        point <- (map["point"], IntStringTransform())
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        redeemID <- map["redeem_id"]
        approveStatus <- map["is_approved"]
        money <- map["money"]
        card <- map["card"]
        payee <- map["payee"]
        redeemUpdated <- (map["updated"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        redeemCreated <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
    }
}

/// 积分明细列表
class PointObjectList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [PointObject]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
}

/// 积分兑换汇率
class PointRate: Model {
    var rate: Int?
    var desc: String?
    
    override func mapping(map: Map) {
        rate <- (map["rate"], IntStringTransform())
        desc <- map["desc"]
    }
}

/// 查询可兑换积分
class IsRedeemPoint: Model {
        /// 关联用户是否有欠款
    var isDebt: Bool = false
        /// 提交的积分是否能兑换
    var isRedeem: Bool = false
        /// 当前最大可兑换积分
    var redeemPoint: String?
        /// 积分提示信息（当is_debt 和is_redeem 都为1时，调用msg）
    var message: String?
    
    override func mapping(map: Map) {
        isDebt <- (map["is_debt"], BoolStringTransform())
        isRedeem <- (map["is_redeem"], BoolStringTransform())
        redeemPoint <- map["redeem_point"]
        message <- map["msg"]
    }
}

/// 积分兑换成功
class RedeemPoint: Model {
    var redeemId: String?
    override func mapping(map: Map) {
        redeemId <- (map["redeem_id"])
    }
}

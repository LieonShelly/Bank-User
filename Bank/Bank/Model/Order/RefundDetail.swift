//
//  RefundDetail.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 普通商品退款详情
class RefundDetail: Model {
    var refundID: String = ""
    var refundNumber: String?
    var type: String?
    var typeName: String?
    var storeName: String?
    var tel: String?
    var amount: Float?
    var reason: String?
    var refuseReason: String = ""
    var remark: String?
    var status: RefundStatus?
    var images: [URL]?
    var created: Date?
    var flow: [RefundFlow] = []
    var refundAccount: String = ""
    
    override func mapping(map: Map) {
        refundID <- map["refund_id"]
        refundNumber <- map["refund_no"]
        type <- map["type"]
        typeName <- map["type_name"]
        storeName <- map["store_name"]
        tel <- map["store_tel"]
        amount <- (map["amount"], FloatStringTransform())
        reason <- map["reason"]
        refuseReason <- map["refuse_reaso"]
        remark <- map["remark"]
        status <- map["status"]
        images <- (map["images"], URLTransform())
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        flow <- map["flow"]
        refundAccount <- map["refund_account"]
    }
}

/// 退款处理流程
class RefundFlow: Model {
    var result: RefundFlowStatus?
    var updated: Date?
    var role: RefundFlowRole?
    
    override func mapping(map: Map) {
        result <- map["result"]
        updated <- (map["updated"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        role <- map["role"]
    }
}

/// 服务商品退款详情
class ServiceRefundDetail: Model {
    var couponCode: String?
    var status: RefundStatus?
    var finishedTime: Date?
    var amount: Double = 0
    var refundAccount: String?
    var created: Date?
    
    override func mapping(map: Map) {
        couponCode <- map["code"]
        status <- map["status"]
        finishedTime <- (map["finished"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        amount <- (map["amount"], DoubleStringTransform())
        refundAccount <- map["refund_account"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
    }
}

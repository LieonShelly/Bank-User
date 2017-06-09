//
//  Order.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 普通订单
class Order: Model {
    var orderID: String = ""
    var merchantID: String = ""
    var refundID: String = ""
    var orderType: OrderTypes?
    var storeName: String?
    var totalPrice: Float = 0
    var totalItems: Int?
    var totalDiscount: Float = 0
    var totalPoint: Int = 0
    /// 运费
    var deliveryCost: Float = 0
    var status: OrderStatus?
    var goodsList: [Goods]?
    
    var orderNumber: String?
    var created: Date?
    var payTime: Date?
    var shipTime: Date?
    var arrivalTime: Date?
    var closeTime: Date?
    /// 收货人名字
    var cneeName: String?
    /// 收货人电话
    var mobile: String?
    /// 商家电话
    var storeTel: String?
    var address: String?
    var point: String?
    /// 物流信息
    var shipment: Shipment?
    var deadlineDesc: String?
    var refundStatus: RefundStatus?
    var refundAmount: Float?
    var isUserEvaluate: Bool = false
    var isCanEvaluate: Bool = false
    var isCheck = true
    var platformPoint: Int = 0
    var merchantPoint: Int = 0
    
    override func mapping(map: Map) {
        orderID <- map["order_id"]
        merchantID <- map["merchant_id"]
        refundID <- map["refund_id"]
        orderType <- map["order_type"]
        storeName <- map["store_name"]
        totalPrice <- (map["total_price"], FloatStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        totalDiscount <- (map["total_discount"], FloatStringTransform())
        totalPoint <- (map["total_point"], IntStringTransform())
        deliveryCost <- (map["delivery_cost"], FloatStringTransform())
        status <- map["status"]
        goodsList <- map["goods_list"]
        orderNumber <- map["order_no"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        payTime <- (map["pay_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        shipTime <- (map["ship_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        arrivalTime <- (map["arrival_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        closeTime <- (map["close_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        cneeName <- map["name"]
        mobile <- map["mobile"]
        address <- map["address"]
        point <- map["point"]
        shipment <- map["logistics"]
        deadlineDesc <- map["deadline_desc"]
        refundStatus <- map["refund_status"]
        refundAmount <- (map["refund_amount"], FloatStringTransform())
        isUserEvaluate <- (map["is_user_evaluate"], BoolStringTransform())
        isCanEvaluate <- (map["if_can_evaluate"], BoolStringTransform())
        storeTel <- map["store_tel"]
        merchantPoint <- (map["merchant_point"], IntStringTransform())
        platformPoint <- (map["platform_point"], IntStringTransform())
    }
}

/// 订单列表
class OrderList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Order]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["cuttent_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
    
}

/// 物流
class Shipment: Model {
    var company: String?
    var number: String?
    /// 物流状态
    var dynamic: String?
    var time: Date?
    var detailURL: URL?
    
    override func mapping(map: Map) {
        company <- map["company"]
        number <- map["number"]
        dynamic <- map["dynamic"]
        time <- (map["time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd hh:mm:ss"))
        detailURL <- (map["detail_url"], URLTransform())
    }
}

/// 添加订单
class AddOrder: Model {
    var subOrders: [Order]?
    
    override func mapping(map: Map) {
        subOrders <- map["sub_orders"]
    }
}

/// 订单数量
class OrderNum: Model {
    var statusNum: [StatusNum] = []
    var refundNum: Int = 0
    
    override func mapping(map: Map) {
        statusNum <- map["status_num"]
        refundNum <- (map["refund_num"], IntStringTransform())
    }
}

/// 订单相应状态和数量
class StatusNum: Model {
    var status: OrderStatus?
    var num: Int = 0
    
    override func mapping(map: Map) {
        status <- map["status"]
        num <- (map["num"], IntStringTransform())
    }
}

//
//  RefundOrder.swift
//  Bank
//
//  Created by 杨锐 on 16/8/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 退款订单
class RefundOrder: Model {
    var refundID: String = ""
    var orderID: String = ""
    var merchantID: String = ""
    var status: RefundStatus?
    var storeName: String?
    var orderType: OrderTypes?
    var totalPrice: Float = 0
    var totalItem: Int?
     /// 运费
    var deliveryCost: Float = 0
    var goodsList: [Goods]?
    var couponID: String?
    
    override func mapping(map: Map) {
        refundID <- map["refund_id"]
        orderID <- map["order_id"]
        merchantID <- map["merchant_id"]
        status <- map["status"]
        storeName <- map["store_name"]
        orderType <- map["order_type"]
        totalPrice <- (map["total_price"], FloatStringTransform())
        totalItem <- (map["total_item"], IntStringTransform())
        deliveryCost <- (map["delivery_cost"], FloatStringTransform())
        goodsList <- (map["goods_list"])
        couponID <- map["coupon_id"]
    }
}

/// 退款订单列表
class RefundOrderList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [RefundOrder]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["cuttent_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }

}

//
//  ShoppingCart.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class ShoppingCart: Model {
    var totalItems: Int?
    var totalPrice: Double = 0
    var totalDiscount: Double = 0
    var totalPoint: Int = 0
    /// 商家赠送的总积分
    var merchantPoint: Int = 0
    /// 平台赠送的总积分
    var platformPoint: Int = 0
    var merchants: [Merchant]?
    var isAllChecked: Bool = false
    var isAllCannotCheck: Bool = false
    
    override func mapping(map: Map) {
        totalItems <- (map["total_items"], IntStringTransform())
        totalPrice <- (map["total_price"], DoubleStringTransform())
        totalDiscount <- (map["total_discount"], DoubleStringTransform())
        totalPoint <- (map["total_point"], IntStringTransform())
        merchantPoint <- (map["merchant_point"], IntStringTransform())
        platformPoint <- (map["platformPoint"], IntStringTransform())
        merchants <- map["merchants"]
        isAllChecked <- (map["is_all_checked"], BoolStringTransform())
        isAllCannotCheck <- (map["is_all_cannot_check"], BoolStringTransform())
    }
    
}

/// 加入购物车
class AddToShoppingCart: Model {
    var goodsNumber: Int?
    
    override func mapping(map: Map) {
        goodsNumber <- (map["goods_num"], IntStringTransform())
    }
}

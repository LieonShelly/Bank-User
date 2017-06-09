//
//  Coupon.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class Coupon: Model {
    var couponID: String = ""
    var goodsID: String = ""
    var goodsTitle: String?
    var merchantID: String = ""
    var storeName: String = ""
    var code: String?
    /// 有效日期
    var expireTime: Date?
    var status: CouponStatus?
    var qrcodeData: String?
    var price: Float?
    override func mapping(map: Map) {
        couponID <- map["coupon_id"]
        goodsID <- map["goods_id"]
        goodsTitle <- map["goods_title"]
        merchantID <- map["merchant_id"]
        storeName <- map["store_name"]
        code <- map["code"]
        expireTime <- (map["expire_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        status <- map["status"]
        qrcodeData <- map["qrcode_data"]
        price <- (map["price"], FloatStringTransform())
    }
}

class CouponList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Coupon]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }

}

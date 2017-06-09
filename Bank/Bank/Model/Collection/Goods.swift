//
//  GoodsObject.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class Collectable: Model {
    var collectType: CollectionType?
    var collectId: String?
    
    override func mapping(map: Map) {
        //super.mapping(map)
        collectType <- map["type"]
        collectId <- map["id"]
    }
}

// 商品
class Goods: Model {
    var goodsID: String = ""
    var title: String?
    var imageURL: URL?
    var price: Float = 0
    /// 商品原价
    var marketPrice: Float = 0
    var status: GoodsStatus?
    var type: GoodsType?
    var sellNum: Int = 0
    /// 收藏时间
    var expireTime: Date?
    /// 是否已收藏
    var isMarked: Bool?
    /// 购物车数量
    var cartGoodsCount: Int?
    var eventCount: Int?
    var canChecked: Bool = false
    var deliveryCost: Float?
    var num: Int = 0
    /// 库存数量
    var stockNum: Int?
    var point: Int?
    var events: [OnlineEvent]?
    
    var isChecked: Bool = false
    var thumb: URL?
    var merchantID: String?
    var summary: String?
    var couponList: [Coupon]?
    var html: String?
    var shareURL: URL?
    /// 评分
    var source: Float = 0
    /// 商品规格属性
    var propertyList: [GoodsProperty] = []
    /// 商品货号
    var goodsConfigID: String?
    var detail: String?
    
    override func mapping(map: Map) {
        //super.mapping(map)
        goodsID <- map["goods_id"]
        title <- map["title"]
        imageURL <- (map["cover"], URLTransform())
        price <- (map["price"], FloatStringTransform())
        marketPrice <- (map["market_price"], FloatStringTransform())
        status <- map["status"]
        type <- map["type"]
        sellNum <- (map["sell_num"], IntStringTransform())
        expireTime <- (map["expire_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        isMarked <- (map["is_marked"], BoolStringTransform())
        cartGoodsCount <- (map["cart_goods_count"], IntStringTransform())
        eventCount <- (map["event_count"], IntStringTransform())
        canChecked <- (map["can_checked"], BoolStringTransform())
        deliveryCost <- (map["delivery_cost"], FloatStringTransform())
        num <- (map["num"], IntStringTransform())
        stockNum <- (map["stock_num"], IntStringTransform())
        point <- (map["point_percent"], IntStringTransform())
        events <- map["events"]
        isChecked <- (map["is_checked"], BoolStringTransform())
        thumb <- (map["thumb"], URLTransform())
        merchantID <- map["merchant_id"]
        summary <- map["summary"]
        couponList <- map["coupon_list"]
        html <- (map["html"])
        shareURL <- (map["share_url"], URLTransform())
        source <- (map["score"], FloatStringTransform())
        propertyList <- map["prop_list"]
        goodsConfigID <- map["goods_config_id"]
        detail <- map["detail"]
    }
}

/// 商品规格属性
class GoodsProperty: Model, Equatable, Hashable {
    var `id`: String = ""
    var title: String = ""
    var value: String = ""
    
    override func mapping(map: Map) {
        id <- map["prop_id"]
        title <- map["title"]
        value <- map["value"]
    }
    
    func desc() -> String? {
        if !title.isEmpty && !value.isEmpty {
            return title + ":" + value
        }
        return nil
    }
    
    var valueHashValue: Int {
        return value.hashValue
    }
    
    var idHashValue: Int {
        return id.hashValue
    }
    
    var titleHashValue: Int {
        return title.hashValue
    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func == (lhs: GoodsProperty, rhs: GoodsProperty) -> Bool {
        return (lhs.valueHashValue == rhs.valueHashValue && lhs.idHashValue == rhs.idHashValue && lhs.titleHashValue == rhs.titleHashValue)
    }

}

class TheGoods: Model {
    var theId: String?
    var num: Int?
    
    override func mapping(map: Map) {
        theId <- map["id"]
        num <- (map["num"], IntStringTransform())
    }
}

/// 购物车商品数量
class CartGoodsNum: Model {
    var goodsNum: Int = 0
    
    override func mapping(map: Map) {
        goodsNum <- (map["goods_num"], IntStringTransform())
    }
}

class PropetryList: Model {
    var goodsList: [Goods] = []
    
    override func mapping(map: Map) {
        goodsList <- map["goods_list"]
    }
}

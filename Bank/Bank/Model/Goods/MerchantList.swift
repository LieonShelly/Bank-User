//
//  MerchantList.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 品牌专区
class MerchantList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Merchant]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["current_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
}

/// 店铺
class Merchant: Model {
    var merchantID: String = ""
    var name: String?
    var storeDetail: String?
    var logo: URL?
    var goodsList: [Goods]?
    
    var tel: String?
    /// 分类条目
    var classifyList: [Classify]?
    
    var detail: String?
    var isAuthenticated: Bool?
    var score: Float?
    var created: Date?
    var storeList: [Store] = []
    var couponList: [Coupon]?
    
    var storeID: String?
    var storeName: String?
    var storeLogo: URL?
    var attachImages: [URL]?
    
    var isChecked: Bool = false
    var totalItems: Int?
    var totalPrice: Double = 0
    var totalDiscount: Double = 0
    var totalPoint: Int = 0
    var platformPoint: Int = 0
    var merchantPoint: Int = 0
    /// 运费
    var deliveryCost: Float?
    var deliveryMode: String?
    var onlineEvents: [OnlineEvent]?
    var goods: Goods?
    var cover: URL?
    var groups: [Group]?
    var isAllCannotCheck: Bool = false
    var shareURL: URL?
    var privilegeList: [Discount]?
    
    override func mapping(map: Map) {
        merchantID <- map["merchant_id"]
        name <- map["store_name"]
        storeDetail <- map["store_detail"]
        logo <- (map["store_logo"], URLTransform())
        goodsList <- map["goods_list"]
        tel <- map["store_tel"]
        classifyList <- map["cat_list"]
        detail <- map["store_detail"]
        isAuthenticated <- (map["is_authenticated"], BoolStringTransform())
        score <- (map["score"], FloatStringTransform())
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        storeList <- map["store_list"]
        couponList <- map["coupon_list"]
        storeID <- map["store_id"]
        storeName <- map["store_name"]
        storeLogo <- (map["store_logo"], URLTransform())
        attachImages <- (map["attach_images"], URLTransform())
        isChecked <- (map["is_checked"], BoolStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        totalPrice <- (map["total_price"], DoubleStringTransform())
        totalPoint <- (map["total_point"], IntStringTransform())
        merchantPoint <- (map["merchant_point"], IntStringTransform())
        platformPoint <- (map["platformPoint"], IntStringTransform())
        totalDiscount <- (map["total_discount"], DoubleStringTransform())
        deliveryCost <- (map["dildelivery_cost"], FloatStringTransform())
        deliveryMode <- map["dildelivery_type"]
        onlineEvents <- map["events"]
        goods <- map["goods"]
        cover <- (map["store_cover"], URLTransform())
        groups <- map["groups"]
        isAllCannotCheck <- (map["is_all_cannot_check"], BoolStringTransform())
        shareURL <- (map["share_url"], URLTransform())
        privilegeList <- map["privilege_list"]
    }
}

class Group: Model {
    var event: OnlineEvent?
    var goodsList: [Goods]?
    
    override func mapping(map: Map) {
        event <- map["event"]
        goodsList <- map["goods_list"]
    }
}

/// 分类条目
class Classify: Model {
    var classifyID: String = ""
    var name: String?
    var isTop: Bool?
    var goodsList: [Goods]?
    
    override func mapping(map: Map) {
        classifyID <- map["cat_id"]
        name <- map["cat_name"]
        isTop <- (map["is_top"], BoolStringTransform())
        goodsList <- map["goods_list"]
    }
}

/// 品牌专区置顶分类商品列表
class TopCatGoodsList: Model {
    var topCats: [Classify]?
    
    override func mapping(map: Map) {
        topCats <- map["top_cats"]
    }
}

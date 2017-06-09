//
//  Prize.swift
//  Bank
//
//  Created by yang on 16/7/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 奖品信息
class Prize: Model {
    var prizeID: String = ""
    var title: String?
    var cover: URL?
    var marketPrice: Float?
    var summary: String?
    
    var type: PrizeType?
    var merchantID: String?
    var goodsID: String?
    var detail: String?
    var imagesURL: [URL]?
    
    var userListID: String?
    var created: Date?
    var status: PrizeStatus?
    
    var code: String?
    var qrcodeData: String?
    var expireTime: Date?
    var html: String?
    var shareURL: URL?
    var shareToGetTime: Bool = false
    
    override func mapping(map: Map) {
        prizeID <- map["gift_id"]
        title <- map["title"]
        cover <- (map["cover"], URLTransform())
        marketPrice <- (map["market_price"], FloatStringTransform())
        summary <- map["summary"]
        type <- map["type"]
        merchantID <- map["merchant_id"]
        goodsID <- map["goods_id"]
        detail <- map["detail"]
        imagesURL <- (map["imgs"], URLTransform())
        userListID <- map["user_list_id"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        status <- map["status"]
        code <- map["code"]
        qrcodeData <- map["qrcode_data"]
        expireTime <- (map["expire_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        html <- map["html"]
        shareURL <- (map["share_url"], URLTransform())
        shareToGetTime <- (map["share_to_get_time"], BoolStringTransform())
    }
}

/// 奖品列表
class PrizeList: Model {
    var totalPage: Int?
    var currentPage: Int?
    var perpage: Int?
    var totalItems: Int?
    var items: [Prize]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["cuttent_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]

    }
}

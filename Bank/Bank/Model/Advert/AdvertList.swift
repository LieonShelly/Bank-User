//
//  AdvertList.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 广告列表
class AdvertList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [Advert]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

/// 广告
class Advert: Model {
    var advertID: String = ""
    var imageURL: URL?
    var title: String?
    var point: Int = 0
    /// 参与人数
    var joinNumber: Int?
    /// 是否关闭
    var isClosed: Bool = false
    /// 是否已参加
    var isJoin: Bool = false
    var isPointOut: Bool = false
    var startTime: Date?
    var endTime: String?
    var listEndTime: Date?
    var shareURL: URL?
    var html: String?
    var type: AdvertType?
    var merchantID: String?
    
    override func mapping(map: Map) {
        advertID <- map["ad_id"]
        imageURL <- (map["thumb"], URLTransform())
        title <- map["title"]
        point <- (map["point"], IntStringTransform())
        joinNumber <- (map["join_num"], IntStringTransform())
        isClosed <- (map["is_closed"], BoolStringTransform())
        isJoin <- (map["is_joined"], BoolStringTransform())
        isPointOut <- (map["is_point_out"], BoolStringTransform())
        startTime <- (map["start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        endTime <- (map["end_time"])
        shareURL <- (map["share_url"], URLTransform())
        html <- map["html"]
        type <- map["type"]
        merchantID <- map["merchant_id"]
    }
}

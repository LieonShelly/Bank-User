//
//  Event.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 热门线上活动
class OnlineEvent: Model {
    var eventID: String = ""
    var title: String?
    var imageURL: URL?
    var startTime: Date?
    var endTime: Date?
    var type: EventType?
    var shareURL: URL?
    var html: String?
    var point: String?
    var selected: Bool?
    var isSelected: Bool?
    var desc: String?
    
    var thumbID: String?
    var thumb: URL?
    
    var merchantID: String?
    var promo: String?
    var typeName: String?
    
    override func mapping(map: Map) {
        eventID <- map["event_id"]
        title <- map["title"]
        imageURL <- (map["cover"], URLTransform())
        startTime <- (map["start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        endTime <- (map["end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        type <- map["type"]
        shareURL <- (map["share_url"], URLTransform())
        point <- map["point"]
        selected <- (map["selected"], BoolStringTransform())
        isSelected <- (map["is_selected"], BoolStringTransform())
        desc <- map["desc"]
        thumbID <- (map["id"])
        thumb <- (map["thumb"], URLTransform())
        html <- map["html"]
        merchantID <- map["merchant_id"]
        promo <- map["promo"]
        typeName <- map["type_name"]
    }
}

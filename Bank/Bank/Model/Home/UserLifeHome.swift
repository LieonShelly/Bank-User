//
//  UserLifeHome.swift
//  Bank
//
//  Created by lieon on 2016/10/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 新增加的首页数据
class UserLifeHome: Model {
    var cityEvents: [CityEvent]?
    var merchantAds: [Advert]?
    
    override func mapping(map: Map) {
        cityEvents <- map["city_events"]
        merchantAds <- map["merchant_ads"]
    }
}

class CityEvent: Model {
   
    var eventID: String?
    var title: String?
    var cover: URL?
    var startTime: String?
    var endTime: String?
    var maxNum: Int = 0
    var appointmentNum: Int = 0
    var joinNum: String?
    var point: Int = 0
    var status: EventSatus = .unbegin
    var appointmentID: String?
    var isApproved: Bool = false
    
    override func mapping(map: Map) {
        eventID <- map["event_id"]
        title <- map["title"]
        cover <- (map["cover"], URLTransform())
        startTime <- map["start_time"]
        endTime <- map["end_time"]
        maxNum <- (map["max_num"], IntStringTransform())
        appointmentNum <- (map["appointment_num"], IntStringTransform())
        joinNum <- map["join_num"]
        point <- ( map["point"], IntStringTransform())
        status <- map["status"]
        appointmentID <- map["appointment_id"]
        isApproved <- (map["is_approved"], BoolStringTransform())
    }
}

class MerchantAdvertisement: Model {
    var advertisementID: String?
    var thumb: String?
    var title: String?
    var point: String?
    var joinNum: String?
    var isClosed: Bool = false
    var isJoined: Bool = false
    var startTime: String?
    var endTime: String?
    var type: AdvertType = .image
    var url: URL?
    
    override func mapping(map: Map) {
        advertisementID <- map["ad_id"]
        thumb <- map["thumb"]
        title <- map["title"]
        point <- map["point"]
        joinNum <- map["join_num"]
        isClosed <- (map["is_closed"], BoolStringTransform())
        isJoined <- (map["is_joined"], BoolStringTransform())
        startTime <- map["start_time"]
        endTime <- map["end_time"]
        type <- map["type"]
        url <- (map["url"], URLTransform())
    }
}

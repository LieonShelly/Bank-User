//
//  MessageCenter.swift
//  Bank
//
//  Created by yang on 16/3/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 消息中心
class NotificationList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var newMessageCount: [NewNotificationCount]?
    var items: [Notification]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        newMessageCount <- map["new_msg_count"]
        items <- map["items"]
    }
}

/// 新消息的数量
class NewNotificationCount: Model {
    var tab: Int = 0
    var count: Int = 0
    
    override func mapping(map: Map) {
        tab <- (map["tab"], IntStringTransform())
        count <- (map["count"], IntStringTransform())
    }
}

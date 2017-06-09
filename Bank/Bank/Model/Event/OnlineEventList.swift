//
//  EventList.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 促销活动列表
class OnlineEventList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var items: [OnlineEvent]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

/// 商品参与的优惠活动
class GoodsEventList: Model {
    var events: [OnlineEvent]?
    
    override func mapping(map: Map) {
        events <- map["events"]
    }
}

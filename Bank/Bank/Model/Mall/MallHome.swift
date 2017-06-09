//
//  MallHome.swift
//  Bank
//
//  Created by yang on 16/4/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//积分商城首页数据
class MallHome: Model {
     /// 是否签到
    var isCheckedIn: Bool?
    //var banners: [Banner]?
    //var onlineEvents: [OnlineEvent]?
    //var offlineEvents: [OfflineEvent]?
    var newsList: [News]?
    var goodsList: [Goods]?
    var merchantList: [Merchant]?
    var goodsCatList: [GoodsCats]?
    
    override func mapping(map: Map) {
        isCheckedIn <- (map["is_checked_in"], BoolStringTransform())
        //banners <- map["banner"]
        //onlineEvents <- map["online_events"]
        //offlineEvents <- map["offline_events"]
        newsList <- map["information"]
        goodsList <- map["goods_list"]
        merchantList <- map["store_list"]
        goodsCatList <- map["goods_cat_list"]
    }
}

/// 积分宝首页
class IntegerHome: Model {
    var totalPoint: Int = 0
    var taskNumber: Int = 0
    var eventNumber: Int = 0
    /// 是否能进入兑换积分页面
    var isExchange: Bool = false
    var isCheckedIn: Bool = false
    
    override func mapping(map: Map) {
        totalPoint <- (map["total_point"], IntStringTransform())
        taskNumber <- (map["task_num"], IntStringTransform())
        eventNumber <- (map["event_num"], IntStringTransform())
        isExchange <- (map["is_exchange"], BoolStringTransform())
        isCheckedIn <- (map["is_checked_in"], BoolStringTransform())
    }
}

/// 签到
class CheckIn: Model {
    var point: Int?
    
    override func mapping(map: Map) {
        point <- (map["point"], IntStringTransform())
    }
}

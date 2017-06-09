//
//  Logistics.swift
//  Bank
//
//  Created by 杨锐 on 16/8/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 物流信息
class Logistics: Model {
     /// 简写
    var com: String?
     /// 公司
    var company: String?
    /// 订单编号
    var logisticsNo: String?
    /// 轨迹
    var tracks: [Track]?
    
    override func mapping(map: Map) {
        com <- map["logistics_com"]
        company <- map["logistics_company"]
        logisticsNo <- map["logistics_no"]
        tracks <- map["tracks"]
    }
}

class Track: Model {
        /// 时间
    var acceptTime: Date?
        /// 轨迹描述
    var acceptStation: String?
    
    override func mapping(map: Map) {
        acceptTime <- (map["accept_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        acceptStation <- map["accept_station"]
    }
}

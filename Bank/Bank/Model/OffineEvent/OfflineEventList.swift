//
//  OfflineEventList.swift
//  Bank
//
//  Created by yang on 16/3/17.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class OfflineEventList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [OfflineEvent]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["total_items"], IntStringTransform())
        perpage <- (map["total_items"], IntStringTransform())
        items <- map["items"]
    }
}

class OfflineEvent: Model {
    /// 参与记录ID
    var joinID: String = ""
    var eventID: String = ""
    var title: String = ""
    /// 活动封面
    var cover: URL?
    /// 开始时间
    var startTime: Date?
    /// 结束时间
    var endTime: Date?
    /// 最大名额
    var maxNumber: Int = 0
    /// 已参加人数
    var joinNumber: Int = 0
    /// 已报名人数
    var signedNumber: Int = 0
    /// 参与可获得的积分
    var point: Double = 0
    /// 活动状态
    var status: OfflineEventStatus?
    var tag: OfflineEventTag?
    
    /// 报名时间
    var signedTime: Date?
    /// 预约ID
    var appointmentID: String?
    /// 预约报名开始时间
    var appointmentStartTime: Date?
    /// 预约报名结束时间
    var appointmentEndTime: Date?
    var qrcode: String?
    var qrcodeData: String?
    var rewards: [Reward]?
    var store: Store?
    
    var isApproved: Bool = false
    var isClosed: Bool = false
    var shareURL: URL?
    var html: String?
    override func mapping(map: Map) {
        joinID <- map["id"]
        eventID <- map["event_id"]
        title <- map["title"]
        cover <- (map["cover"], URLTransform())
        startTime <- (map["start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm"))
        endTime <- (map["end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm"))
        signedNumber <- (map["singup_num"], IntStringTransform())
        joinNumber <- (map["join_num"], IntStringTransform())
        signedNumber <- (map["appointment_num"], IntStringTransform())
        signedTime <- (map["appointment_start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm"))
        point <- (map["point"], DoubleStringTransform())
        status <- map["status"]
        tag <- map["tag"]
        appointmentID <- map["appointment_id"]
        appointmentStartTime <- (map["appointment_start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm"))
        appointmentEndTime <- (map["appointment_end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm"))
        qrcodeData <- map["qrcode_data"]
        qrcode <- map["qrcode"]
        rewards <- map["rewards"]
        store <- map["store"]
        isApproved <- (map["is_approved"], BoolStringTransform())
        isClosed <- (map["is_closed"], BoolStringTransform())
        shareURL <- (map["share_url"], URLTransform())
        html <- map["html"]
    }
}

/// 奖品
class Reward: Model {
     /// 奖品类型
    var type: RewardType?
     /// 奖品数量
    var amount: Int?
    
    override func mapping(map: Map) {
        type <- map["type"]
        amount <- (map["amount"], IntStringTransform())
    }
}

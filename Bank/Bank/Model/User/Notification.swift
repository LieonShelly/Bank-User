//
//  Message.swift
//  Bank
//
//  Created by yang on 16/3/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 消息(消息中心)
class Notification: Model {
    var messageID: String = ""
    var type: NotificationType?
    var title: String?
    var created: Date?
    var content: String?
    /// 消息已读状态
    var readStatus: NotificationReadStatus = .unread
    var detailLink: URL?
    var html: String?
    /// 是否已处理
    var processProgress: NotificationProcessStatus = .unDeal
    /// 附加数据
    var extra: [String: Any]?
    var buttonTitle: String?
    
    override func mapping(map: Map) {
        messageID <- map["msg_id"]
        type <- map["type"]
        title <- map["title"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        content <- map["content"]
        readStatus <- map["status"]
        detailLink <- (map["detail_link"], URLTransform())
        html <- map["html"]
        processProgress <- map["is_processed"]
        extra <- map["extra"]
        buttonTitle <- map["button_txt"]
    }
}

/// 系统消息
class SystemNotice: Model {
    var noticeID: String?
    var title: String?
    var html: String?
    
    override func mapping(map: Map) {
        noticeID <- map["notice_id"]
        title <- map["title"]
        html <- map["html"]
    }
}

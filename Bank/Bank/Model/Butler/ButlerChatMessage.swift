//
//  ContactMessage.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 图片
class ChatImage: Model {
    var srcURL: URL?
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    fileprivate var width: Double = 0
    fileprivate var height: Double = 0
    
    override func mapping(map: Map) {
        srcURL <- (map["src"], URLTransform())
        width <- (map["width"], DoubleStringTransform())
        height <- (map["height"], DoubleStringTransform())
    }
}

/// 聊天消息
class ButlerChatMessage: Model {
    var messageID: String = ""
    var message: String = ""
    var image: ChatImage?
    var replyContent: ReplyContent?
    var shareProduct: SharedProduct?
    var created: Date?
    var type: MessageType?
    
    override func mapping(map: Map) {
        messageID <- map["id"]
        message <- map["msg"]
        image <- map["img"]
        replyContent <- map["reply_content"]
        shareProduct <- map["shared_product"]
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        type <- map["type"]
    }
}

class ChatMessageList: Model {
    var items: [ButlerChatMessage]?
    
    override func mapping(map: Map) {
        items <- map["items"]
    }
}

class ButlerMessage: NSObject {
    var chatEndMessageID: String = ""
    var jsqMessage: JSQMessage?
    var messageType: MessageType? 
    
    init(chatEndMessageID: String, jsqMessage: JSQMessage, messageType: MessageType) {
        self.chatEndMessageID = chatEndMessageID
        self.jsqMessage = jsqMessage
        self.messageType = messageType
    }
}

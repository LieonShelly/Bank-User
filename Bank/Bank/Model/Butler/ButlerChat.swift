//
//  ContactDetails.swift
//  Bank
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

//联系详情
class ButlerChat: Model {
    var listId: String = ""
    var name: String?
    var status: StatusType?
    var user: User?
    var butler: Butler?
    var items: [ButlerChatMessage]?
    
    override func mapping(map: Map) {
        listId <- map["list_id"]
        name <- map["name"]
        status <- map["status"]
        user <- map["user"]
        butler <- map["banker"]
        items <- map["items"]
    }
}

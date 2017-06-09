//
//  Member.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 成员
class Member: Model {
    var memberID: String = ""
    //备注
    var remark: String = ""
    //姓名
    var name: String = ""
    var mobile: String  = ""
    var imageURL: URL?
    var point: Double = 0
    var status: MemberStatus?
    var nickName: String = ""
    
    override func mapping(map: Map) {
        memberID <- map["member_id"]
        remark <- map["remark"]
        name <- map["name"]
        mobile <- map["mobile"]
        imageURL <- (map["avatar"], URLTransform())
        point <- (map["point"], DoubleStringTransform())
        status <- map["status"]
        nickName <- map["nickname"]
    }
}

//成员列表
class MemberList: Model {
    var items: [Member]?
    var totalItems: Int = 0
    var totalPoint: Int = 0
    
    override func mapping(map: Map) {
        items <- map["items"]
        totalItems <- (map["total_items"], IntStringTransform())
        totalPoint <- (map["total_point"], IntStringTransform())
    }
}

//
//  Banker.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 银行管家
class Butler: Model {
    var butlerID: String = ""
    var name: String = ""
    var imageURL: URL?
    var mobile: String?
    var jobID: String = ""
    var rate: String = ""
    var remark: String?
    
    override func mapping(map: Map) {
        butlerID <- map["banker_id"]
        name <- map["name"]
        imageURL <- (map["avatar"], URLTransform())
        mobile <- map["mobile"]
        jobID <- map["jobno"]
        rate <- map["grade"]
        remark <- map["remark"]
    }
}

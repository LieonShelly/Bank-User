//
//  SubscribeObject.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 预约内容
class Appoint: Model {
    var appointID: String = ""
    var type: AppointType?
    var status: AppointStatus? = .waiting
    var date: Date?
    var time: Date?
    var loanTypeID: String?
    var loanTypeName: String?
    var mobile: String?
    var bankBranch: Branch?
    var amount: Double?
    
    override func mapping(map: Map) {
        appointID <- map["bespeak_id"]
        type <- map["type"]
        status <- map["status"]
        date <- (map["date"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        time <- (map["time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        loanTypeID <- map["loan_type"]
        loanTypeName <- map["loan_type_name"]
        amount <- (map["amount"], DoubleStringTransform())
        mobile <- map["mobile"]
        bankBranch <- map["bank_branch"]
    }

}

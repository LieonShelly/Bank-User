//
//  BaseData.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 基础数据
class BaseData: Model {
        /// 反馈类型
    var feedbackType: [FeedbackType] = []
        /// 贷款类型
    var loanType: [LoanType] = []
        /// 银行卡类型
    var bankCardType: [BankCardType] = []
        /// 合作银行列表
    var bankList: [Bank] = []
        /// 普通商品退款原因
    var normalRefundReasons: [NormalRefundReason] = []
        /// 服务商品退款原因
    var serviceRefundReasons: [ServiceRefundReason] = []
        /// 职业
    var jobs: [Job] = []
        /// 客服电话
    var serviceHotLine: String?
    
    override func mapping(map: Map) {
        feedbackType <- map["feedback_type"]
        loanType <- map["loan_type"]
        bankList <- map["bank_list"]
        bankCardType <- map["bank_card_type"]
        normalRefundReasons <- map["normal_refund_reason"]
        serviceRefundReasons <- map["service_refund_reason"]
        jobs <- map["job"]
        serviceHotLine <- map["service_hotline"]
    }
}

/// 银行
class Bank: Model {
    var bankID: String = ""
    var name: String?
    var logo: String?
    var isCurrentBank: Bool = true
    var background: String?
    override func mapping(map: Map) {
        bankID <- map["id"]
        name <- map["name"]
        logo <- map["logo"]
        background <- map["background"]
        isCurrentBank <- (map["type"], BoolStringTransform())
    }
}

/// 贷款类型
class LoanType: Model {
    var typeID: String = ""
    var name: String?
    
    override func mapping(map: Map) {
        typeID <- map["id"]
        name <- map["name"]
    }
}

extension LoanType: Equatable {}

func == (lhs: LoanType, rhs: LoanType) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

/// 反馈原因
class FeedbackReason: Model {
    var reasonID: String = ""
    var name: String?
    
    override func mapping(map: Map) {
        reasonID <- map["id"]
        name <- map["name"]
    }
}

/// 反馈类型
class FeedbackType: Model {
    var typeID: String = ""
    var name: String?
    var reasons: [FeedbackReason] = []
    
    override func mapping(map: Map) {
        typeID <- map["id"]
        name <- map["name"]
        reasons <- map["reasons"]
    }
}
/// 银行卡类型
class BankCardType: Model {
    var typeID: String = ""
    var name: String = ""
    
    override func mapping(map: Map) {
        typeID <- map["id"]
        name <- map["name"]
    }
}
/// 普通商品退款原因
class NormalRefundReason: Model {
    var reasonID: String?
    var reasonName: String?
    
    override func mapping(map: Map) {
        reasonID <- map["id"]
        reasonName <- map["name"]
    }
}
/// 服务商品退款原因
class ServiceRefundReason: Model {
    var reasonID: String?
    var reasonName: String?
    
    override func mapping(map: Map) {
        reasonID <- map["id"]
        reasonName <- map["name"]
    }
}
/// 普通商品退款原因
class Job: Model {
    var jobID: String = ""
    var jobName: String?
    
    override func mapping(map: Map) {
        jobID <- map["id"]
        jobName <- map["name"]
    }
}

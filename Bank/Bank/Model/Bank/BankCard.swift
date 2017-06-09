//
//  BankCard.swift
//  Bank
//
//  Created by yang on 16/3/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 我的银行卡详情
class BankCard: Model {
    /// 卡ID
    var cardID: String = ""
    /// 所属银行ID
    var bankID: BankType = .mccb
    /// 所属银行名称
    var bankName: String = ""
    /// 所属银行 logo
    var bankLogo: URL?
    var bankBackground: URL?
    var bankType: PaymentType = .currentBank
    /// 银行卡类型
    var cardType: String?
    /// 银行卡类型名称
    var cardTypeName: String?
    /// 卡号
    var number: String = ""
    /// 储蓄种类id
    var depositType: String?
    /// 储蓄卡种类名称
    var depositTypeName: String?
    /// 银行卡余额
    var blance: Double = 0
    //可用余额
    var available: Double = 0
    //存储币种
    var currency: String?
    //开户网点
    var bankAddress: String?

    override func mapping(map: Map) {
        cardID <- map["card_id"]
        bankID <- map["bank_id"]
        bankName <- map["bank_name"]
        bankLogo <- (map["bank_logo"], URLTransform())
        bankBackground <- (map["bank_background"], URLTransform())
        bankType <- map["bank_type"]
        cardType <- map["card_type"]
        cardTypeName <- map["card_type_name"]
        depositType <- map["deposit_type"]
        depositTypeName <- map["deposit_type_name"]
        number <- map["number"]
        blance <- (map["blance"], DoubleStringTransform())
        available <- (map["available"], DoubleStringTransform())
        currency <- map["currency"]
        bankAddress <- map["bank_address"]
    }
}

/// 我的银行卡列表
class BankCardList: Model {
    var cardList: [BankCard]?
    
    override func mapping(map: Map) {
        cardList <- map["card_list"]
    }
}

class BindCard: Model {
    var idcard: String?
    var name: String?
    var mobile: String?
    var isInfo: Bool?
    
    override func mapping(map: Map) {
        idcard <- map["idnumber"]
        name <- map["name"]
        mobile <- map["mobile"]
        isInfo <- (map["is_info"], BoolStringTransform())
    }
}

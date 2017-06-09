//
//  CreditGoods.swift
//  Bank
//
//  Created by yang on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 信用产品
class CreditGoods: Model {
    var goodsID: String = ""
    var title: String?
    var imageURL: URL?
    /// 总金额
    var total: Float = 0.0
    /// 待还金额
    var remain: Float = 0.0
    var endTime: Date?
    var searchButtons: [CreditGoodDetail]?
    
    override func mapping(map: Map) {
        goodsID <- map["goods_id"]
        title <- map["title"]
        imageURL <- (map["cover"], URLTransform())
        total <- (map["total"], FloatStringTransform())
        endTime <- (map["end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        remain <- (map["remain"], FloatStringTransform())
        searchButtons <- (map["search_buttons"])
    }
}

class CreditGoodDetail: Model {
    var text: String = ""
    var start: String = ""
    var end: String = ""
    var isCustom: Bool?
    
    override func mapping(map: Map) {
        text <- (map["text"])
        start <- (map["start"])
        end <- (map["end"])
        isCustom <- (map["is_custom"], BoolStringTransform())
    }
}

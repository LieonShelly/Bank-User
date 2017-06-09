//
//  Award.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/21.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

/// 打赏
class Award: Model {
    var awardID: String = ""
    var code: String?
    var avatar: URL?
    var merchantID: String = ""
    var storeName: String?
    var staffID: String?
    /// 服务员
    var staffName: String?
    var staffAvatar: URL?
    var point: String?
    var awardStatus: AwardStatus?
    var message: String?
    var updated: Date?
    var couponID: String?
    var goodsTitle: String?
    var logo: URL?
    var created: Date?
    /// 打赏人
    var userName: String?
    /// 打赏时间
    var awardTime: Date?
    
    override func mapping(map: Map) {
        awardID <- map["award_id"]
        code <- map["code"]
        avatar <- (map["avatar"], URLTransform())
        merchantID <- map["merchant_id"]
        storeName <- map["store_name"]
        staffID <- map["staff_id"]
        staffName <- map["name"]
        staffAvatar <- (map["staff_avatar"], URLTransform())
        point <- map["point"]
        awardStatus <- map["status"]
        message <- map["message"]
        updated <- (map["updated"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        couponID <- map["coupon_id"]
        goodsTitle <- map["goods_title"]
        logo <- (map["logo"], URLTransform())
        created <- (map["created"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
        userName <- map["user_name"]
        awardTime <- (map["award_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss"))
    }
}

/// 打赏/被打赏列表
class AwardList: Model {
    var totalPage: Int?
    var totalItems: Int?
    var currentPage: Int?
    var perpage: Int?
    var items: [Award]?
    
    override func mapping(map: Map) {
        totalPage <- (map["total_page"], IntStringTransform())
        totalItems <- (map["total_items"], IntStringTransform())
        currentPage <- (map["cuttent_page"], IntStringTransform())
        perpage <- (map["perpage"], IntStringTransform())
        items <- map["items"]
    }
}

/// 打赏排行榜
class AwardRank: Model {
    var name: String?
    var avatar: URL?
    var mobile: String?
    var times: String?
    
    override func mapping(map: Map) {
        name <- map["name"]
        avatar <- (map["avatar"], URLTransform())
        mobile <- map["mobile"]
        times <- map["times"]
    }
}

/// 打赏排行榜
class AwardRankList: Model {
    var items: [AwardRank]?
    
    override func mapping(map: Map) {
        items <- map["items"]
    }
}

//
//  User.swift
//  Bank
//
//  Created by yang on 16/3/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

///　用户安全验证状态
public enum SignedState: String {
    /// 签约用户
    case signed = "0"
    /// 未设置支付密码
    case notSetPayPass = "1"
    /// 设置了支付密码 未绑定银行卡
    case setPayPassNotLinkCard = "2"
    /// 绑定了银行卡
    case linkedCard = "3"
}
/// 用户
class User: Model {
    var userID: String = ""
    var name: String = ""
    var nickname: String = ""
    var imageURL: URL?
    var mobile: String?
    var sex: Gender?
    var sexName: String?
    var birthday: Date?
    /// 未读消息数
    var informationCount: Int?
    var butlerID: String?
    var token: String?
    /// 是否签约
    var isSigned: Bool = false
    var state: SignedState?
    /// 是否设置了支付密码
    var isSetPayPassword: Bool = false
    /// 密码是否已过期，需要修改密码
    var isPasswordExpired: Bool = false
    /// 绑定用户ID
    var fatherID: String = "0"
    var isStaff: Bool = false
    var staffID: String = "" {
        didSet {
            if !staffID.isEmpty && staffID != "0" {
                isStaff = true
            } else {
                isStaff = false
            }
        }
    }
    
    override func mapping(map: Map) {
        userID <- map["user_id"]
        name <- map["name"]
        nickname <- map["nickname"]
        imageURL <- (map["avatar"], URLTransform())
        mobile <- map["mobile"]
        sex <- map["sex"]
        sexName <- map["sex_name"]
        birthday <- (map["birthday"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        informationCount <- (map["information_num"], IntStringTransform())
        butlerID <- map["banker_jobno"]
        token <- map["token"]
        isSigned <- (map["is_signed"], BoolStringTransform())
        state <- map["state"]
        isSetPayPassword <- (map["is_pay_password"], BoolStringTransform())
        isPasswordExpired <- (map["is_password_expired"], BoolStringTransform())
        fatherID <- map["father_id"]
        staffID <- map["staff_id"]
    }
}

class UpdatePayPassword: Model {
    var wrongPasswordTimes: Int?
    override func mapping(map: Map) {
        wrongPasswordTimes <- (map["wrong_password_times"], IntStringTransform())
    }
}

class UserPoint: Model {
    var totalPoint: String?
    /// 用户剩余积分
    var userPoint: String?
    
    override func mapping(map: Map) {
        totalPoint <- (map["total_point"])
        userPoint <- (map["user_point"])
    }
}

/// 我的店铺
class MyStore: Model {
    
    /// 店员权限
    var permissionLevel: StorePermissionLevel = .unknown
    var staffID: String?
    var storeName: String?
    var storeLogo: URL?
    var storeDetail: String?
    var awardList: AwardList?
    
    override func mapping(map: Map) {
        permissionLevel <- map["limits"]
        staffID <- map["staff_id"]
        storeName <- map["store_name"]
        storeLogo <- (map["store_logo"], URLTransform())
        storeDetail <- map["store_detail"]
        awardList <- map["award_list"]
    }
}

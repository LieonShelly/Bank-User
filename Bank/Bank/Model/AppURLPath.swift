//
//  URLObjectMap.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/16.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import Alamofire
import ObjectMapper

class URLData<T: Mappable>: Mappable {
    var action: URLAction?
    var extra: T?
    var isProcessed: NotificationProcessStatus?
    var msgID: String?
    var type: String?
    
    init() {
        
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        action <- map["action"]
        extra <- map["extra"]
        isProcessed <- map["is_processed"]
        msgID <- map["msg_id"]
        type <- map["type"]
    }
}

public enum URLAction: String {
    /// 展示详情页
    case showDetail = "showDetail"
    /// 跳到指定页面
    case gotoPage = "gotoPage"
    /// 图片预览
    case previewImage = "previewImage"
    /// 展示普通商品参与所有的优惠
    case showGoodsPromos = "showGoodsPromos"
    /// 显示服务商品参与的店铺地址
    case showGoodsAddress = "showGoodsAddresses"
    /// 显示促销活动介绍
    case showEventIntro = "showEventIntroduce"
    /// 显示信用会员邀请普通会员
    case showUserInvitation = "showUserInvitation"
    /// 显示管家邀请信用会员
    case showButlerInvitation = "showBankerInvitation"
    /// 播放视频
    case showPlayVideo = "playVideo"
    /// 打开 URL
    case openURL = "openUrl"
    /// 添加店员
    case addStaff = "addMerchantStaff"
    /// 商家删除店员
    case delStaff = "showDelMerchantStaff"
    /// 店员绑定成功
    case bindingStaff = "bindingMerchantStaff"
    /// 获得免费打赏机会
    case getFreeAwardChance = "couponAwardStaff"
    /// 成功打赏服务员
    case staffGetTipsSuccess = "couponAwardStaffSuccess"
    /// 普通商品货号下的备选规格
    case alternativeGoods = "showAlternativeGoods"
    /// 查看奖品详情
    case giftInfo = "giftInfo"
    /// 活动扫码成功
    case qrcodeEventSuccess = "qrcodeEventSuccess"
    /// 刷新订单详情
    case refreshOrderInfo = "refreshOrderInfo"
    
    var path: String {
        switch self {
        case .gotoPage:
            return "goto_page"
        case .previewImage:
            return "preview_image"
        case .showDetail:
            return "show_detail"
        case .showGoodsAddress:
            return "show_goods_address"
        case .showGoodsPromos:
            return "show_goods_promos"
        case .showEventIntro:
            return "show_event_introduce"
        case .showUserInvitation:
            return "show_user_invitation"
        case .showButlerInvitation:
            return "show_butler_invitation"
        case .showPlayVideo:
            return "play_video"
        case .openURL:
            return "open_url"
        case .alternativeGoods:
            return "show_alternative_goods"
        case .addStaff:
            return "add_merchant_staff"
        case .qrcodeEventSuccess:
            return "qrcode_event_success"
        case .refreshOrderInfo:
            return "refresh_order_info"
        default:
            return ""
        }
    }
}

class BaseInnerURLData: URLData<Model> {}

/// 内容分类
public enum DetailContentType: String {
    case invest = "1"
    case goods = "2"
    case shop = "3"
    case advertise = "4"
    case offlineEvent = "5"
    case onlineEvent = "6"
    case headline = "7"
    /// 订单
    case order = "8"
    case serviceGoods = "9"
    case coupon = "10"
    case butler = "11"
    case goodsRefund = "12"
    case serviceRefund = "13"
    case system = "14"
    case goodsCats = "15"
    case staff = "16"
    case dailyTask = "19"
}

class ShowDetailExtra: Mappable {
    var contentType: DetailContentType = .invest
    var contentID: String = ""
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        contentType <- map["content_type"]
        contentID <- map["content_id"]
    }
}

// showDetail?type=1&id=1
/// 显示详情页
class ShowDetailData: URLData<ShowDetailExtra> {}

public enum PageID: String {
    /// 便民支付
    case lifeService = "home/lifeService"
    /// 积分宝
    case pointMall = "pointShop/point"
    /// 理财e账户
    case eAccount = "invest/eacconut"
    /// 消费券
    case coupon = "usercenter/coupon"
    /// 大额取款
    case withdraw = "bank/withdrawWithLarge"
    /// 银行卡
    case bankCards = "bank/bankcard"
    /// 汇款转账
    case bankTransfer = "bank/transfer"
    /// 联系管家
    case butlerContact = "bank/steward"
    /// 个人贷款
    case loan = "bank/loan"
    /// 购物车
    case shoppingCart = "pointShop/shoppingCart"
    /// 银行预约
    case appoint = "usercenter/appoint"
    /// 我的成员
    case member = "usercenter/member"
    /// 我的收藏
    case collection = "usercenter/collection"
    /// 扫一扫
    case scanQR = "usercenter/scanqr"
    /// 我的订单
    case myOrder = "usercenter/myOrder"
    /// 推荐好友
    case recommendToBF = "usercenter/recommendation"
    /// 还款明细
    case repayList = "usercenter/repayList"
    /// 现场活动
    case offlineEvent = "pointShop/offlineEvent"
    /// 日常任务
    case dailyTask = "pointShop/dailyTask"
    /// 看广告
    case advertise = "pointShop/advertis"
    /// 我的信用
    case myCredit = "invest/myCredit"
    /// 头条
    case headline = "pointShop/news"
    /// 我的任务
    case myTask = "pointShop/myTask"
    /// 我的活动
    case myEvent = "pointShop/myEvent"
    /// 快捷方式设置
    case shortcutSetting = "usercenter/quickMenu"
    /// 优惠买单
    case privilegeList = "usercenter/privilegeList"
    
    case index = "index/index"
    
    var verifyLogin: Bool {
        switch self {
        case .advertise:
            fallthrough
        case .recommendToBF:
            fallthrough
        case .offlineEvent:
            fallthrough
        case .dailyTask:
            fallthrough
        case .advertise:
            fallthrough
        case .headline:
            fallthrough
        case .pointMall:
            return false
        default:
            return true
        }
    }
}

class GotoPageExtra: Mappable {
    var pageID: PageID?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        pageID <- map["page_id"]
    }
}

/// 跳转到指定页面
class GotoPageData: URLData<GotoPageExtra> {
    override init() {
        super.init()
        action = URLAction.gotoPage
        extra = GotoPageExtra()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
}

class GiftInfoExtra: Mappable {
    var giftID: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        giftID <- map["gift_id"]
    }
}

/// 奖品详情
class GiftInfoData: URLData<GiftInfoExtra> {}

class PreviewImageExtra: Mappable {
    var currentImageURL: URL?
    var URLs: [URL?] = []
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        currentImageURL <- (map["current"], URLTransform())
        URLs <- (map["urls"], ArrayOfURLTransform())
    }
}

/// 图片预览
class PreviewImageData: URLData<PreviewImageExtra> {}

class ShowGoodsPromoExtra: Mappable {
    var goodsID: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        goodsID <- map["goods_id"]
    }
}

/// 展示普通商品参与所有的优惠
class ShowGoodsPromoData: URLData<ShowGoodsPromoExtra> {}

class ShowGoodsAddressExtra: Mappable {
    var goodsID: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        goodsID <- map["goods_id"]
    }
}

/// 展示服务商品参与的店铺地址
class ShowGoodsAddressData: URLData<ShowGoodsAddressExtra> {}

/// 显示促销活动介绍
class ShowEventIntroData: URLData<ShowDetailExtra> {
    override init() {
        super.init()
        action = URLAction.showEventIntro
        let extraData = ShowDetailExtra()
        if let type = DetailContentType(rawValue: "6") {
            extraData.contentType = type
        }
        extra = extraData
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
}

class ShowUserInvitationExtra: Mappable {
    var userID: String = ""
    var nickname: String = ""
    var mobile: String = ""
    var processStatus: NotificationProcessStatus = .unDeal
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userID <- map["user_id"]
        nickname <- map["nickname"]
        mobile <- map["mobile"]
        processStatus <- map["is_processed"]
    }
}

/// 显示信用会员邀请普通会员
class ShowUserInvitationData: URLData<ShowUserInvitationExtra> {}

class ShowButlerInvitationExtra: Mappable {
    var butlerID: String = ""
    var jobID: String = ""
    var processStatus: NotificationProcessStatus = .unDeal
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        butlerID <- map["banker_id"]
        jobID <- map["jobno"]
        processStatus <- map["is_processed"]
    }
}

/// 显示管家邀请信用会员
class ShowButlerInvitationData: URLData<ShowButlerInvitationExtra> {}

/// 播放视频
class PlayVideoData: URLData<PlayVideoExtra> {}

class PlayVideoExtra: Mappable {
    var url: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        url <- map["url"]
    }
}

class OpenURLData: URLData<OpenURLExtra> {}

class OpenURLExtra: Mappable {
    var url: String = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        url <- map["url"]
    }
}

class MerchantStaffExtra: Mappable {
    var merchantID: String = ""
    var username: String = ""
    var storeName: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        merchantID <- map["merchant_id"]
        username <- map["user_name"]
        storeName <- map["store_name"]
    }
}

/// 商家添加店员
class AddMerchantStaffData: URLData<MerchantStaffExtra> {}

class DelMerchantStaff: URLData<MerchantStaffExtra> {}

class BindingMerchantStaff: URLData<MerchantStaffExtra> {}

class StaffTipsExtra: Mappable {
    var awardID: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        awardID <- map["award_id"]
    }
}

/// 获得免费打赏机会
class FreeChanceTipsData: URLData<StaffTipsExtra> {}

/// 成功打赏服务员
class TipsStaffSuccessData: URLData<StaffTipsExtra> {}

class AlternativeGoodsExtra: Mappable {
    var goodsConfigID: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        goodsConfigID <- map["goods_config_id"]
    }
}

/// 普通商品货号下的备选规格
class AlternativeGoodsData: URLData<AlternativeGoodsExtra> {}

class QRCodeEvnetSuccessExtra: Mappable {
    var eventID: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        eventID <- map["id"]
    }
}

/// 活动扫码成功
class QRCodeEventSuccessData: URLData<QRCodeEvnetSuccessExtra> {}

class RefreshOrderInfoExtra: Mappable {
    var orderID: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        orderID <- map["order_id"]
    }
}

/// 刷新订单详情
class RefreshOrderInfoData: URLData<RefreshOrderInfoExtra> {}

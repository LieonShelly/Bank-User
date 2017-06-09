//
//  BaseResponse.swift
//  Bank
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseResponseObject<T: Mappable>: Mappable {
    
    var status: Bool = true
    var code: RequestErrorCode = .unknown
    var msg: String?
    var needRelogin: Bool = false
    var data: T?
    
    var isValid: Bool {
        // FIXME: !!! status type
        return status && code == .success
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- (map["status"], BoolStringTransform())
        code <- map["code"]
        msg <- map["msg"]
        needRelogin <- (map["need_relogin"], BoolStringTransform())
        data <- map["data"]
    }
}

class BaseResponseObjectArray<T: Mappable>: Mappable {
    var status: Bool = true
    var code: RequestErrorCode = .unknown
    var msg: String?
    var needRelogin: Bool = false
    var data: [T]?
    
    var isValid: Bool {
        // FIXME: !!! status type
        return status && code == .success
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- (map["status"], BoolStringTransform())
        code <- map["code"]
        msg <- map["msg"]
        needRelogin <- (map["need_relogin"], BoolStringTransform())
        data <- map["data"]
    }
    
}
/// 我的成员,绑定管家
class BaseResponseData: Model {
    var status: StatusType?
    var code: RequestErrorCode = .unknown
    var msg: String?
    var needRelogin: String?
    
    var isValid: Bool {
        // FIXME: !!! status type
        return status == .carriedOut && code == .success
    }
    
    override func mapping(map: Map) {
        status <- map["status"]
        code <- map["code"]
        msg <- map["msg"]
        needRelogin <- map["need_relogin"]
    }
}

class FingerLoginSession: Model {
    var userID: String?
    var password: String?
    var mobile: String?
    var isOpenFinger: Bool = false
    
    override func mapping(map: Map) {
        userID <- map["id"]
        password <- map["password"]
        mobile <- map["mobile"]
        isOpenFinger <- (map["isOpen"], BoolStringTransform())
    }
}

/// 用户名 密码
class SessionAccount: Model {
    var mobile: String? 
    var password: String?
//    var isOpenFinger: Bool = false
    
    override func mapping(map: Map) {
        mobile <- map["mobile"]
        password <- map["password"]
    }
}

class PublicKey: Model {
    var publicKey: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        publicKey <- map["public_key"]
    }
}

class UnreadCount: Model {
    var unreadCount: Int = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        unreadCount <- (map["unread_msg_count"], IntStringTransform())
    }
}

class SSHResponse: BaseResponseObject<PublicKey> {}

class FileObject: Model {
    var path: String?
    var url: URL?
    var name: String?
    var size: UInt64?
    var type: String?
    
    override func mapping(map: Map) {
        path <- map["file_name"]
        url <- (map["url"], URLTransform())
        name <- map["name"]
        size <- map["size"]
        type <- map["image/jpeg"]
    }
}

class FileListObject: Model {
    var successList: [FileObject]? = []
    
    override func mapping(map: Map) {
        successList <- map["success"]
    }
}

class NullDataResponse: BaseResponseObject<Model> {}

/// 上传文件
class FileUploadResponse: BaseResponseObject<FileListObject> {}

/// 我的管家
//class ButlerInfoData: BaseResponseObject<Butler> {}

/// 管家联系详情
//class ChatDetailData: BaseResponseObject<ButlerChat> {}

/// 发送消息
//class SendMessageData: BaseResponseObject<ChatMessageList> {}

/// 银行首页 新公告数量
class BankHomeData: BaseResponseObject<BankHome> {}

/// 预约列表
class AppointListData: BaseResponseObject<AppointList> {}

/// 预约详情
class AppointData: BaseResponseObject<Appoint> {}

/// 网点查询
class BranchListData: BaseResponseObject<BranchList> {}

/// 收藏列表
class CollectionData: BaseResponseObject<CollectionList> {}

/// 已购投资理财产品详情
class ProductDetailData: BaseResponseObject<Product> {}

/// 已购投资理财产品列表
class BoughtProductsListData: BaseResponseObject<BoughtProducts> {}

/// 理财e账户
class EAccountData: BaseResponseObject<EAccount> {}

/// 充值
class RechargeData: BaseResponseObject<Recharge> {}

/// 我的信用
class MyCreditData: BaseResponseObject<MyCredit> {}

/// 信用商品
class CreditGoodsData: BaseResponseObject<CreditGoods> {}

/// 还款明细
class RepaymentListData: BaseResponseObject<RepaymentList> {}

/// 话费充值
class MobileRechargeListData: BaseResponseObject<MobileRechargeList> {}

/// 查询燃气费或水费
class GasWaterBillData: BaseResponseObject<GasWaterBill> {}

/// 缴费记录
class PaymentLogsData: BaseResponseObject<PaymentLogs> {}

/// banner广告
class BannerListData: BaseResponseObject<BannerList> {}

/// 首页数据
class LifeHomeData: BaseResponseObject<LifeHome> {}

/// 新增首页数据
class  UserLifeHomeData: BaseResponseObject<UserLifeHome> {}

/// 基础数据
class BaseDataListData: BaseResponseObject<BaseData> {}

/// 图形验证码
class ImageCaptchaData: BaseResponseObject<ImageCaptcha> {}

/// 区域编码
class RegionCodeListData: BaseResponseObject<RegionCodeList> {}

/// 成员列表
class MemberListData: BaseResponseObject<MemberList> {}

/// 成员详情
class MemberDetailData: BaseResponseObject<Member> {}

/// 我的银行卡列表
class BankCardListData: BaseResponseObject<BankCardList> {}

/// 银行卡详情
class BankCardDetailData: BaseResponseObject<BankCard> {}

/// 银行卡交易明细
class BankCardTransformDetailListData: BaseResponseObject<TransactionDetailsList> {}

/// 获取登录用户基本信息
class GetUserInfoData: BaseResponseObject<User> {}

/// 获取绑定的用户信息
class GetFatherUserInfoData: BaseResponseObject<User> {}

/// 获取现有的积分
class GetPointData: BaseResponseObject<UserPoint> {}

/// 修改支付密码
class UpdatePayPasswordData: BaseResponseObject<UpdatePayPassword> {}

/// 获取快捷菜单
class GetQuickMenuData: BaseResponseObject<GetQuickMenu> {}

/// 消息中心
class NotificationListData: BaseResponseObject<NotificationList> {}

/// 消息详情
class NotificationDetailData: BaseResponseObject<Notification> {}

class SystemNoticeDetailData: BaseResponseObject<SystemNotice> {}

/// 未读消息数量
class NotificationUnreadData: BaseResponseObject<UnreadCount> {}

/// 促销活动列表
class EventListData: BaseResponseObject<OnlineEventList> {}

/// 促销活动详情
class EventDetailData: BaseResponseObject<OnlineEvent> {}

/// 商品参与的优惠促销活动
class GoodsEventListData: BaseResponseObject<GoodsEventList> {}

/// 商品列表
class GoodsListData: BaseResponseObject<GoodsList> {}

/// 通过商品ID获得列表
class GetListByGoodsIDData: BaseResponseObject<GoodsList> {}

/// 热门商品列表
class HotGoodsListData: BaseResponseObject<HotGoodsList> {}

/// 商品详情
class GoodsObjectData: BaseResponseObject<Goods> {}

/// 参与团购的分店列表
class StoreListData: BaseResponseObject<StoreList> {}

/// 品牌专区首页
class MerchantListData: BaseResponseObject<MerchantList> {}

/// 品牌专区详情
class MerchantData: BaseResponseObject<Merchant> {}

/// 品牌专区置顶分类商品列表
class MerchantTopCatsData: BaseResponseObject<TopCatGoodsList> {}

/// 添加订单
class AddOrderData: BaseResponseObject<AddOrder> {}

/// 订单列表
class OrderListData: BaseResponseObject<OrderList> {}

/// 订单数量
class OrderNumData: BaseResponseObject<OrderNum> {}

/// 订单详情
class OrderDetailData: BaseResponseObject<Order> {}

/// 物流信息
class LogisticsData: BaseResponseObject<Logistics> {}

/// 申请退款
class ApplyRefundData: BaseResponseObject<RefundOrder> {}

/// 退款订单列表
class RefundOrderListData: BaseResponseObject<RefundOrderList> {}

/// 普通商品退款详情
class RefundDetailData: BaseResponseObject<RefundDetail> {}

/// 服务商品退款详情
class ServiceRefundDetailData: BaseResponseObject<ServiceRefundDetail> {}

/// 地址列表
class AddressListData: BaseResponseObject<AddressList> {}

/// 添加新地址
class AddNewAddressData: BaseResponseObject<Address> {}

/// 加入购物车
class AddToShoppingCartData: BaseResponseObject<AddToShoppingCart> {}

/// 购物车
class ShoppingCartData: BaseResponseObject<ShoppingCart> {}

/// 购物车商品数量
class CartGoodsNumData: BaseResponseObject<CartGoodsNum> {}

/// 银行卡支付
class BankCardPayData: BaseResponseObject<UserPay> {}

/// 用户支付
class UserPayData: BaseResponseObject<UserPay> {}

/// 团购券列表
class CouponListData: BaseResponseObject<CouponList> {}

/// 团购券详情
class CouponData: BaseResponseObject<Coupon> {}

/// 广告列表
class AdvertListData: BaseResponseObject<AdvertList> {}

/// 广告详情
class AdvertDetailData: BaseResponseObject<Advert> {}

/// 广告问题
class AdvertQuestionData: BaseResponseObject<AdvertQuestion> {}

/// 现场活动列表
class OfflineEventListData: BaseResponseObject<OfflineEventList> {}

/// 现场活动详情
class OfflineEventDetailData: BaseResponseObject<OfflineEvent> {}

/// 理财产品列表
class InvestProductListData: BaseResponseObject<ProductList> {}

/// 理财产品详情
class InvestProductDetailData: BaseResponseObject<Product> {}

/// e账户明细
class EAccountDetailListData: BaseResponseObject<AccountDetailList> {}

/// 日常任务列表
class DailyTaskListData: BaseResponseObject<DailyTaskList> {}

/// 日常任务详情
class DailyTaskDetailData: BaseResponseObject<DailyTask> {}

/// 资讯列表
class NewsListData: BaseResponseObject<NewsList> {}

/// 资讯详情
class NewsDetailData: BaseResponseObject<News> {}

/// 资讯分类列表
class NewsTypeListData: BaseResponseObject<NewsTypeList> {}

/// 置顶资讯列表
class TopNewsListData: BaseResponseObject<TopNewsList> {}

/// 反馈分类列表
class FeedbackCatListData: BaseResponseObject<FeedbackCatList> {}

/// 程序版本数据
class VerionData: BaseResponseObject<Version> { }

/// 积分商城首页数据
class MallHomeData: BaseResponseObject<MallHome> {}

/// 签到
class CheckInData: BaseResponseObject<CheckIn> {}

/// 积分宝首页数据
class IntegerHomeData: BaseResponseObject<IntegerHome> {}

/// 积分明细列表
class PointObjectListData: BaseResponseObject<PointObjectList> {}

/// 积分兑换结果详情
class PointRedeemInfoData: BaseResponseObject<PointObject> {}

/// 查询可兑换积分
class IsRedeemPointData: BaseResponseObject<IsRedeemPoint> {}

/// 积分兑换成功
class PointRedeemData: BaseResponseObject<RedeemPoint> {}

/// 积分兑换汇率
class PointRateData: BaseResponseObject<PointRate> {}

/// 商品分类列表
class GoodsCatsListData: BaseResponseObject<GoodsCatsList> {}

/// 商品排序列表
class GoodsSortListData: BaseResponseObject<GoodsSortsList> {}

/// 砸金蛋首页数据
class LotteryHomeData: BaseResponseObject<LotteryHome> {}

/// 砸金蛋奖品列表
class PrizeListData: BaseResponseObject<PrizeList> {}

/// 砸金蛋奖品详情数据
class PrizeDetailData: BaseResponseObject<Prize> {}

/// 分享 app 的内容
class ShareAppData: BaseResponseObject<ShareAppContent> {}

/// 优惠买单数据
class DiscountData: BaseResponseObject<Discount> {}

/// 优惠买单订单列表
class DiscountListData: BaseResponseObject<DiscountList> {}

/// 优惠买单列表
class DiscountRuleListData: BaseResponseObject<DiscountRuleList> {}

/// 我的店铺
class MyShopData: BaseResponseObject<MyStore> {}

/// 我的打赏列表
class AwardListData: BaseResponseObject<AwardList> {}

/// 打赏详情
class AwardData: BaseResponseObject<Award> {}

/// 打赏排行榜
class AwardRankListData: BaseResponseObject<AwardRankList> {}

/// 同一货号下的商品
class PropetryListData: BaseResponseObject<PropetryList> {}

/// 绑定银行卡
class BindCardData: BaseResponseObject<BindCard> {}

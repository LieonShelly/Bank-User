//
//  Const.swift
//  Bank
//
//  Created by Koh Ryu on 12/2/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import UIKit

/// 系统 3D Touch 快捷菜单
public enum SystemShortcutType: String {
    /// 扫一扫
    case scan = "cn.msh.mobilebank.ios.user.scan"
    /// 积分宝
    case point = "cn.msh.mobilebank.ios.user.point"
    /// 购物车
    case cart = "cn.msh.mobilebank.ios.user.cart"
    /// 消费券
    case coupon = "cn.msh.mobilebank.ios.user.coupon"
}

/// 帮助中心 TAG
public enum HelpCenterTag: String {
    /// 激活
    case active = "0101"
    /// 银行卡
    case card = "0102"
    /// 转账
    case transfer = "0103"
    /// 积分兑换
    case exchange = "0104"
    /// 玩活动-详情页
    case offlineEventDetail = "0105"
    /// 看广告-详情页
    case adDetail = "0106"
    /// 日常任务-详情页
    case dailyTaskDetail = "0107"
    /// 我的成员
    case member = "0108"
    /// 绑定管家
    case butler = "0109"
    /// 我的信用
    case credit = "0110"
    /// 我的打赏
    case award = "0111"
}

/// 理财产品状态
public enum ProductState {
    
    /// 即将发售
    case coming(TimeInterval)
    /// 已售罄
    case soldOut
    /// 销售中
    case inStock(TimeInterval)
    /// 已结束
    //case Finished
    
    var title: String {
        switch self {
        case .coming:
            return R.string.localizable.product_coming_title()
        case .soldOut:
            return R.string.localizable.product_soldout_title()
        case .inStock(let ti):
            let (d, h, m) = Date.timeFromInterval(ti)
            return R.string.localizable.product_instock_title(d, h, m)
        }
    }
    
    var subTitle: String {
        switch self {
        case .coming(let ti):
            let (d, h, m) = Date.timeFromInterval(ti)
            return R.string.localizable.product_coming_sub_title(d, h, m)
        case .soldOut:
            return ""
        case .inStock:
            return R.string.localizable.product_instock_sub_title()
        }
    }
}

/// 文件上传目录
public enum FileUploadDir: String {
    /// 用户头像
    case userAvatar = "user/avatar"
    /// 联系管家发送图片
    case butlerChat = "user/banker_chats"
    /// 用户反馈
    case feedback = "user/feedback"
    /// 订单退款
    case orderRefund = "user_order/refund"
}

/// 商品类型
public enum GoodsType: String {
    /// 实物商品
    case merchandise = "1"
    /// 服务
    case service = "2"
}

/// 商品状态
public enum GoodsStatus: String {
    /// 出售中
    case onSale = "1"
    /// 已售完
    case soldOut = "2"
    /// 已下架
    case shelves = "3"
    /// 不存在
    case noneGoods = "4"
}

/// 商品标签
public enum GoodsTag: String {
    /// 食物
    case food
    /// 休闲
    case leisure
    /// 本地生活
    case local
    /// 精选商品
    case feature
}

/// 性别
public enum Gender: String {
    /// 男
    case male = "1"
    /// 女
    case female = "2"
    /// 未设置
    case unknow = "0"
    
    var desc: String {
        switch self {
        case .male:
            return "男"
        case .female:
            return "女"
        case .unknow:
            return "未设置"
        }
    }
}

/*
 1=客户发的文字消息 2=客户发的图片消息 3=客户发的视频消息 4=管家的回复 5=管家分享的理财产品 6=沟通结束 7=用户评价管家 8=管家无法回复 9=管家撤回消息
 */
///  联系管家时的消息类型
public enum MessageType: String {
    /// 文字消息
    case textFromClient = "1"
    /// 图片消息
    case photoFromClient = "2"
    /// 视频消息
    case videoFromClient = "3"
    /// 管家的回复
    case replyFromButler = "4"
    /// 管家分享的理财产品
    case shareFromButler = "5"
    /// 沟通结束
    case conversationEnd = "6"
    /// 用户评价管家
    case reviewFromClient = "7"
    /// 管家无法回复
    case noResponseFromButler = "8"
    /// 管家撤回消息
    case withdrawalFromButler = "9"
}

/// 排序方式 TODO
public enum SortType: String {
    /// 销量从高到低
    case bestSeller = "1"
    /// 价格从低到高
    case lowestPrice = "2"
    /// 价格从高到低
    case heightPrice = "3"
    /// 评分从高到低
    case heightScore = "4"
    
    var text: String {
        switch self {
        case .bestSeller:
            return "销量从高到低"
        case .lowestPrice:
            return "价格从低到高"
        case .heightPrice:
            return "价格从高到低"
        case .heightScore:
            return "评分从高到低"
        }
    }
    
}

/// 支付类型
public enum PaymentType: String {
    ///  所有类型
    case all = "0"
    ///  本行
    case currentBank = "1"
    ///  其他银行
    case otherBank = "2"
    ///  微信支付
    case wechat = "3"
    ///  支付宝支付
    case alipay = "4"
}

/// 生活服务支付方式
public enum ServicePaymentType: String {
    /// 理财e账户
    case eAccount = "1"
    /// 银行卡
    case currentBank = "2"
}

/// 处理状态
public enum StatusType: String {
    /// 待处理
    case pending = "0"
    /// 进行中
    case carriedOut = "1"
    /// 已结束
    case finished = "2"
    /// 已评价
    case evaluated = "3"
}

/// 预约类型
public enum AppointType: String {
    
    /// 大额取款
    case withdrawAppoint = "1"
    /// 个人贷款
    case personalLoans = "2"
    
    var text: String {
        switch self {
        case .withdrawAppoint:
            return "大额取款"
        case .personalLoans:
            return "个人贷款"
        }
    }
    
}

/// 预约状态
public enum AppointStatus: String {
    /// 等待确认
    case waiting = "1"
    /// 已确认
    case confirm = "2"
    
    var text: String {
        switch self {
        case .waiting:
            return "等待银行确认"
        case .confirm:
            return "银行已确认"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .waiting:
            return UIColor.lightGray
        case .confirm:
            return UIColor.orange
        }
    }
}

/// 便民服务缴费类型
public enum BillType: String {
    
    /// 手机话费
    case mobileBill = "1"
    /// 水费
    case waterBill = "2"
    /// 燃气费
    case gasBill = "3"
    /// 学费
    case tuitionBill = "4"
}

/// 理财产品状态
public enum ProductsStatus: String {
    /// 即将发售
    case coming = "1"
    /// 销售中
    case inStock = "2"
    /// 已售罄
    case soldOut = "3"
    /// 已结束
    case finished = "4"
}

/**
 管家回复内容大分类类型
 */

//TODO
public enum ReplyContentType: String {
    
    /// 文字消息
    case text = "1"
}

/**
 管家回复内容子分类类型
 */

//TODO
public enum ReplyContentSubType: String {
    
    /// 文字消息
    case text = "1"
}

/**
 理财产品收益类型
*/

//TODO
public enum ProductProfitType: String {
    
    /// 保本收益
    case guaranteed = "1"
}

//TODO
/// 计息方式
public enum InterestType: String {
    case stages = "1"
}

//TODO
/// 收益计算方式
public enum IncomeCalculationType: String {
    case add = "1"
}

/// 成员状态
public enum MemberStatus: String {
    
    /// 邀请中
    case invited = "0"
    /// 已激活
    case activated = "1"
    /// 已拒绝
    case refused = "-1"
}

//TODO
/// 银行卡交易类型
public enum TransactionType: String {
    
    case transferAccount = "1"
}

/// 找回登录密码步骤
public enum FindLoginPassStep: String {
    /// 验证短信验证码
    case verifySMS = "1"
    /// 验证支付密码
    case verifyPayPass = "2"
    /// 设置新的登录密码
    case setNewPass = "3"
}

/// 消息分类
public enum NoticeCategory: String {
    /// 全部
    case all = "0"
    /// 我的银行
    case myBank = "1"
    /// 本地生活
    case localLife = "2"
    /// 积分
    case pointChange = "3"
    /// 系统
    case system = "4"

    var tab: Int {
        return Int(self.rawValue) ?? 0
    }
    
    var name: String {
        switch self {
        case .all:
            return "全部"
        case .localLife:
            return "本地生活"
        case .myBank:
            return "银行"
        case .pointChange:
            return "积分"
        case .system:
            return "系统"
        }
    }
    
}

/// 系统通知类型
public enum NotificationType: String {
    
    /// 转账成功
    case transferSuccess = "10101"
    /// 转账失败
    case transferFailed = "10102"
    /// 管家留言
    case messageFromButler = "10201"
    /// 服务结束请求评价
    case conversionEndFromButler = "10202"
    /// 积分还款
    case pointRepay = "10301"
    /// 现金还款
    case cashRepay = "10302"
    /// 交易付款
    case tradePayment = "20101"
    /// 交易完成 商品类
    case goodsBillDone = "20201"
    /// 交易完成 服务类
    case serviceBillDone = "20202"
    /// 商品退款成功
    case goodsRefundSuccess = "20301"
    /// 消费券退款成功
    case couponRefundSuccess = "20302"
    /// 商品退款失败
    case goodsRefundFailed = "20303"
    /// 消费券退款失败
    case couponRefundFailed = "20304"
    /// 完成日常任务
    case dailyTaskDone = "20501"
    /// 完成广告答题
    case adDone = "20601"
    /// 活动报名成功
    case eventEnrollSuccess = "20701"
    /// 活动参与完成
    case eventFinishedSuccess = "20702"
    /// 活动取消
    case eventCancel = "20703"
    /// 完成固定任务
    case finishTask = "20704"
    /// 修改订单价格
    case updateOrderPrice = "20901"
    /// 从订单获得积分
    case pointGetFromOrder = "30101"
    /// 从成员贡献获得积分
    case pointGetFromMember = "30102"
    /// 积分兑换成现金
    case pointExchangeCash = "30201"
    /// 积分变动
    case pointActivity = "30301"
    /// 修改登录密码
    case changeLoginPass = "40101"
    /// 修改支付密码
    case changePayPass = "40102"
    /// 管家关联请求（用户版）
    case inviteFromButler = "40201"
    /// 成员成为用户（用户版）
    case memberBecomeUser = "40301"
    /// 成员邀请成功
    case memberInviteSuccess = "40401"
    /// 成员邀请失败
    case memberInviteFailed = "40402"
    /// 成员关联请求 (会员版)
    case inviteFromUser = "40501"
    /// 用户解绑
    case unbindMember = "40601"
    /// 系统消息
    case systemMessage = "40701"
    /// 添加店员
    case inviteFormStaff = "40801"
    /// 消费获得打赏机会
    case getAwardChoice = "40901"
    /// 消费打赏成功
    case awardSuccess = "40902"
    /// 消费打赏成功感谢
    case awardSuccessThank = "40903"
}

/**
 消息状态
 */
public enum NotificationReadStatus: String {
    ///  未读
    case unread = "1"
    ///  已读
    case read = "2"
}

/**
 消息处理状态
 */
public enum NotificationProcessStatus: String {
    /// 未处理
    case unDeal = "0"
    /// 已接受
    case accepted = "1"
    /// 已失效
    case expired = "2"
    /// 已拒绝
    case refuse = "3"
}

/// banner 广告位置
public enum BannerPosition: String {
    /// 首页
    case homeBanner = "user_index_index_top"
    /// 中间广告区
    case homeMiddleAd = "user_index_index_middle"
    /// 首页热门活动区
    case homeEvents = "user_index_index_hot_events"
    /// 首页同城活动
    case homeCityEvents = "user_index_index_city_events"
    /// 首页商品分类
    case homeGoodsCats = "user_index_index_goods_cats"
    /// 本地生活首页
    case mallHomeBanner = "user_locallife_index_top"
    /// 促销活动区
    case mallHomePromo = "user_locallife_index_promo_events"
    /// 现场活动区
    case mallHomeOfflineEvents = "user_locallife_index_live_events"
    /// 本地生活商品分类
    case mallHomeGoodsCats = "user_locallife_index_goods_cats"
    /// 现场活动列表顶部
    case offineEventsBanner = "user_locallife_live_events_top"
    /// 广告列表顶部
    case adBanner = "user_locallife_ads_top"
    /// 普通商品列表顶部
    case goodsBanner = "user_locallife_goods_top"
    /// 生活服务列表顶部
    case serviceBanner = "user_locallife_service_top"
    /// 热门资讯
    case newsHot = "user_locallife_hot_news"
    /// 热门推荐资讯
    case newsRecommend = "user_locallife_recommend_news"
    /// 优惠资讯
    case newsPromos = "user_locallife_promos_news"
    /// 综合新闻资讯
    case newsGeneral = "user_locallife_general_news"
    /// 财经新闻资讯
    case newsFinance = "user_locallife_finance_news"
    /// 本地新闻资讯
    case newsLocal = "user_locallife_local_news"
}

/// 资讯所在页面
public enum NewsPosition: String {
    /// 本地生活资讯
    case mallHomeNews = "1"
    /// 头条资讯
    case newsHomeNews = "2"
    /// 银行资讯
    case bankHomeNews = "3"
}

/// 手机验证码用途
public enum MobileVerifyType: String {
    /// 绑定银行卡
    case bindCard = "1"
    /// 个人贷款
    case loan = "2"
    /// 用户注册
    case register = "3"
    /// 忘记登录密码
    case forgotLoginPass = "4"
    /// 忘记支付密码
    case forgotPayPass = "5"
    /// 转账
    case balanceTrans = "6"
    ///  验证新手机
    case verifyNewMobile = "7"
    /// 关联信用账户
    case associationCredit = "8"
}

/// 收藏类型
public enum CollectionType: String {
    /// 商品
    case goods = "1"
}

/// 促销活动类型
public enum EventType: String {
    /// 满减
    case fullCut = "1"
    /// 打折
    case discount = "2"
    /// 活动价
    case activityPrice = "3"
}

/// 广告类型
public enum AdvertType: String {
    /// 图片广告
    case image = "1"
    /// 视频广告
    case video = "2"
    /// 网页广告
    case webPage = "3"
}

/// 消费券状态
public enum CouponStatus: String {
    /// 未使用
    case unused = "0"
    /// 已使用
    case used = "1"
    /// 已过期
    case outOfDate = "2"
    /// 已退款
    case refunded = "3"
    /// 退款中
    case refunding = "4"
    
    /// 订单详情中消费券的状态
    var text: String {
        switch self {
        case .unused:
            return "待消费"
        case .used:
            return "已消费"
        case .outOfDate:
            return "已过期"
        case .refunded:
            return "退款成功"
        case .refunding:
            return "退款中"
        }
    }
    
    /// 消费券列表中消费券的状态
    var listTitle: String {
        switch self {
        case .unused:
            return "有效期"
        case .used:
            return "已使用"
        case .outOfDate:
            return "已过期"
        case .refunded:
            return "已退款"
        case .refunding:
            return "退款中"
        }
    }
}

/// 订单状态
public enum OrderStatus: String {
    /// 总计
    case total = "0"
    /// 待付款
    case waitingPay = "1"
    /// 已付款/待发货
    case waitingShip = "2"
    /// 已发货
    case shipped = "3"
    /// 已完成/已收货
    case confirmed = "4"
    /// 已关闭
    case closed = "9"
    /// 退货
    case refund = "5"
    
    var text: String {
        switch self {
        case .waitingPay:
            return "等待买家付款"
        case .waitingShip:
            return "买家已付款"
        case .shipped:
            return "卖家已发货"
        case .confirmed:
            return "交易成功"
        case .closed:
            return "交易关闭"
        case .refund:
            return "退货"
        default:
            return ""
        }
    }
    
    var actionText: String! {
        switch self {
        case .waitingPay:
            return "立即付款"
        case .waitingShip:
            return nil
        case .shipped:
            return "确认收货"
        case .confirmed:
            return "评价"
        case .closed:
            return "删除订单"
        default:
            return nil
        }
    }
    
    var detailText: String! {
        switch self {
        case .waitingPay:
            return "等待买家付款..."
        case .waitingShip:
            return "等待卖家发货..."
        case .shipped:
            return "卖家已发货..."
        case .confirmed:
            return "交易成功"
        case .closed:
            return "交易关闭"
        default:
            return ""
        }
    }
}

/// 订单类型
public enum OrderTypes: String {
    /// 实物商品
    case merchandise = "1"
    /// 服务
    case service = "2"
}

/// 退款状态
public enum RefundStatus: String {
        /// 退款中
    case waiting = "1"
        /// 退款成功
    case success = "2"
        /// 退款拒绝
    case refuse = "3"
        /// 退款异常
    case unusual = "99"
    
    var text: String {
        switch self {
        case .waiting:
            return "退款中"
        case .success:
            return "退款成功"
        case .refuse:
            return "商家已拒绝"
        case .unusual:
            return "退款异常"
        }
    }
    
    var actionText: String {
        switch self {
        case .waiting:
            return "联系客服"
        case .success:
            return "钱款去向"
        case .refuse:
            return "联系客服"
        case .unusual:
            return "联系客服"
        }
    }
    
    /// 服务商品退款详情状态
    var serviceText: String {
        switch self {
        case .waiting:
            return "等待处理"
        case .success:
            return "退款成功"
        case .refuse:
            return "退款失败"
        default:
            return ""
        }
    }
    
    /// 普通商品退款详情状态
    var merchandiseText: String {
        switch self {
        case .waiting:
            return "退款中"
        case .success:
            return "退款成功"
        case .refuse:
            return "退款失败"
        default:
            return ""
        }
    }
    
    var detailText: String {
        switch self {
        case .waiting:
            return "退款中"
        case .success:
            return "退款成功"
        case .refuse:
            return "商家拒绝"
        case .unusual:
            return "退款异常"
        }
    }

}

/// 退款流程状态
public enum RefundFlowStatus: String {
    /// 申请退款
    case apply = "0"
    /// 同意退款
    case agree = "1"
    /// 拒绝退款
    case refused = "2"
}

/// 退款操作人角色
public enum RefundFlowRole: String {
    /// 用户
    case user = "1"
    /// 商户
    case merchant = "2"
    /// 平台
    case platfrom = "3"
}

/// 退款详情状态
public enum RefundDetailStatus: String {
    /// 退款中
    case waiting = "0"
    /// 退款成功
    case success = "1"
    /// 退款拒绝
    case refuse = "-1"
    
    var text: String {
        switch self {
        case .waiting:
            return "等待商家处理退款申请"
        case .success:
            return "退款成功"
        case .refuse:
            return "退款拒绝"
        }
    }
    
}

/// 现场活动状态
public enum OfflineEventStatus: String {
    /// 报名未开始
    case unStart = "1"
    /// 立即报名
    case enrolling = "2"
    /// 取消报名（已报名）
    case signedUp = "3"
    /// 名额已满
    case quotaFull = "4"
    /// 报名已截止
    case signExpired = "5"
    /// 已参加活动
    case finished = "6"
    /// 活动已结束
    case end = "7"
    /// 活动已取消
    case cancel = "8"
    
    var title: String? {
        switch self {
        case .unStart:
            return "报名未开始"
        case .enrolling:
            return "立即报名"
        case .end:
            return "活动已结束"
        case .finished:
            return "已参加"
        case .quotaFull:
            return "名额已满"
        case .signedUp:
            return "取消报名"
        case .signExpired:
            return "报名已截止"
        case .cancel:
            return "活动已取消"
        }
    }
    
    var myEventListText: String {
        switch self {
        case .unStart:
            return "报名未开始"
        case .enrolling:
            return "立即报名"
        case .end:
            return "已结束"
        case .finished:
            return "已参加"
        case .quotaFull:
            return "名额已满"
        case .signedUp:
            return "取消报名"
        case .signExpired:
            return "报名已截止"
        case .cancel:
            return "已取消"
        }
    }
    
    var enable: Bool {
        switch self {
        case .end, .finished, .quotaFull, .signExpired, .unStart, .cancel:
            return false
        case .enrolling, .signedUp:
            return true
        }
    }
}

/// 奖品类型
public enum RewardType: String {
    /// 积分
    case point = "1"
    
    var title: String {
        switch self {
        case .point:
            return "积分"
        }
    }
}

/// 任务类型
public enum TaskType: String {
    /// 现场活动
    case offline = "1"
    /// 答对广告
    case ad = "2"
    /// 添加成员
    case addMember = "3"
    /// 购买商品
    case buyGoods = "4"
    /// 绑定银行卡
    case bindCard = "5"
    /// 签到
    case checkin = "6"
    /// 购买理财产品
    case buyProduct = "7"
    /// 充值
    case chargeEAccount = "8"
    /// 完成银行转账
    case bankTrans = "9"
    /// 绑定管家
    case bindButler = "10"
    /// 分享 APP
    case shareApp = "11"
}

/// 任务状态
public enum TaskStatus: String {
    /// 未领取
    case unGet = "0"
    /// 未完成
    case unfinished = "1"
    /// 已完成
    case finished = "2"
    /// 已领奖
    case gotAward = "3"
    /// 已失效
    case invalid = "4"
    
    var text: String {
        switch self {
        case .unGet:
            return "领取任务"
        case .unfinished:
            return "任务中"
        case .finished:
            return "领取奖励"
        case .gotAward:
            return "已领奖"
        case .invalid:
            return "任务失效"
        }
    }
    
    var enable: Bool {
        switch self {
        case .unGet, .finished:
            return true
        default:
            return false
        }
    }
}

/// 现场活动标签
public enum OfflineEventTag: String {
    /// 热门
    case hot = "1"
    /// 新活动
    case new = "2"
    /// 人气
    case popularity = "3"
}

/// 现场活动活动状态
public enum SignedEventStatus: String {
    ///  未开始
    case notStart = "0"
    ///  报名中
    case enrolling = "1"
    ///  进行中
    case carriedOut = "2"
    ///  已结束
    case finished = "3"
}

/// 砸金蛋抽奖奖品类型
public enum PrizeType: String {
    /// 商品
    case goods = "1"
    /// 积分
    case point = "2"
}

/// 砸金蛋奖品来源
public enum SourceType: String {
    /// 平台或银行
    case platform = "1"
    /// 商家
    case merchant = "2"
}

/// 砸金蛋奖品状态
public enum PrizeStatus: String {
    /// 待兑奖
    case unCash = "1"
    /// 已兑奖
    case cashed = "2"
    /// 已过期
    case outOfTime = "3"
    
    var text: String {
        switch self {
        case .unCash:
            return "待兑换"
        case .cashed:
            return "已兑换"
        case .outOfTime:
            return "已过期"
        }
    }
}

/// 资讯分类
public enum NewsType: String {
    /// 银行咨询
    case bankHeadline = "user_bank_headline"
    /// 本地生活资讯
    case pointMallHeadline = "user_locallife_headline"
}

/// 银行类型
public enum BankType: String {
    /// 绵阳商业银行
    case mccb = "1"
    /// 中国银行
    case boc = "2"
    /// 中国建设银行
    case ccb = "3"
    /// 未知
    case unknown = "0"
    
}

/// 银行卡详细操作
public enum DetailActionType: Int {
    /// 七日明细
    case filterWeek
    /// 本月明细
    case filterMonth
    /// 三个月明细
    case filter3Month
    /// 明细查询
    case filterCustom
    /// 我要转账
    case trans
    /// 我要理财
    case finance
}

public enum BalanceStatementType {
    case cardBill
}

/// 修改密码的步骤
public enum UpdatePasswordType: String {
    /// 验证旧密码
    case checkOldPassword = "1"
    /// 设置新密码
    case updateNewPassword = "2"
}

/// 是否记住帐户的情况
public enum RememberAccountType: String {
    /// 正常退出
    case normalStatus = "NormalStatus"
    /// 五分钟无操作自动退出
    case noOperationAfterFiveMinutes = "NoOperationAfterFiveMinutes"
    /// 手动退出账户
    case manualQuitAccount = "ManualQuitAccount"
    /// 强行结束程序
    case forcedTerminateApp = "ForcedTerminateApp"

    static func needRemember(_ type: String) -> RememberAccountType {
        switch type {
        case "NoOperationAfterFiveMinutes":
        return noOperationAfterFiveMinutes
        case "ManualQuitAccount":
        return manualQuitAccount
        case "ForcedTerminateApp":
        return forcedTerminateApp
        default:
            break
        }
        return normalStatus
    }
}

/// 平台类型
public enum PlatformType: String {
    /// 签约用户版
    case user
    /// 非签约用户版
    case member
}

/// 现场活动状态
public enum EventSatus: String {
    /// 未开始
    case unbegin = "1"
    /// 已开始
    case immediateRegister = "2"
    /// 取消报名
    case cancelRegister = "3"
    /// 名额已满
    case fullQuota = "4"
    /// 报名截止
    case registerEnd = "5"
    /// 已参加
    case registered = "6"
    /// 活动结束
    case eventEnd = "7"
    /// 活动取消
    case eventCancled = "8"
    
    var title: String {
        switch self {
        case .unbegin:
            return "活动未开始"
        case .immediateRegister:
            return "立即报名"
        case .cancelRegister:
            return "取消报名"
        case .fullQuota:
            return "名额已满"
        case .registerEnd:
            return "报名已截止"
        case .registered:
            return "已参加"
        case .eventEnd:
            return "活动已结束"
        case .eventCancled:
            return "活动已取消"
        }
    }
    
}

/// 优惠买单类型
public enum DiscountType: String {
    /// 没有优惠
    case none = "0"
    /// 折扣
    case discount = "1"
    /// 满减
    case fullCut = "2"
    
    var title: String {
        switch self {
        case .discount:
            return "折扣"
        case .fullCut:
            return "满减"
        case .none:
            return "无优惠"
        }
    }
}

/// 打赏排行榜类型
public enum RankListType: Int {
    /// 土豪榜
    case rich = 1
    /// 小蜜蜂榜
    case bee = 2
}

/// 打赏状态
public enum AwardStatus: String {
    /// 未打赏
    case notAward = "0"
    /// 已打赏
    case awarded = "1"
    /// 已过期
    case outDate = "2"
}

/// 店铺权限级别
public enum StorePermissionLevel: String {
    /// 收营员
    case cash = "2"
    /// 服务员
    case waiter = "1"
    /// 未知
    case unknown = "0"
    
    var name: String? {
        switch self {
        case .cash:
            return R.string.localizable.store_permission_cash()
        case .waiter:
            return R.string.localizable.store_permission_waiter()
        case .unknown:
            return nil
        }
    }
}

/// 广告答案类型
public enum AnswerType: String {
    /// 单选
    case radio = "1"
    /// 多选
    case multiselect = "2"
    
    var text: String {
        switch self {
        case .radio:
            return "(单选)"
        case .multiselect:
            return "(多选)"
        }
    }
}

/// 验证码状态
public enum CodeStatus {
    /// 允许发送
    case allow
    /// 等待60s
    case wait
}

/// 积分兑换审核状态
public enum ApproveStatus: String {
    /// 待审核
    case unApprove = "0"
    /// 审核通过
    case success = "1"
    /// 审核不通过
    case fail = "2"
    
    var text: String {
        switch self {
        case .unApprove:
            return "兑换中"
        case .success:
            return "兑换成功"
        case .fail:
            return "兑换失败"
        }
    }
}

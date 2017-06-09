//
//  Header.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

protocol EndPointProtocol {
    var scheme: String { get }
    var environment: String { get }
    var route: String { get }
    var domain: String { get }
    var endpoint: String { get }
    var path: String { get }
    
    func URL() -> String
}

extension EndPointProtocol {
    var scheme: String {
        return "http"
    }
    
    var environment: String {
        return BankURL.environment
    }
    
    var domain: String {
        return BankURL.domain
    }
    
    func URL() -> String {
        var url = scheme
        url.append("://")
        url.append(self.environment)
        url.append(".")
        url.append(self.route)
        url.append(".")
        url.append(self.domain)
        url.append("/")
        url.append(self.path)
        url.append("/")
        url.append(self.endpoint)
        return url
    }
}

protocol UserProtocol: EndPointProtocol {}
protocol ContentProtocol: EndPointProtocol {}
protocol BusinessProtocol: EndPointProtocol {}
protocol MarketProtocol: EndPointProtocol {}
protocol FileUploadProtocol: EndPointProtocol {}

extension UserProtocol {
    var route: String {
        return "user"
    }
}

extension ContentProtocol {
    var route: String {
        return "content"
    }
}

extension BusinessProtocol {
    var route: String {
        return "ebusiness"
    }
}

extension MarketProtocol {
    var route: String {
        return "marketing"
    }
}

extension FileUploadProtocol {
    var route: String {
        return "file"
    }
    var endpoint: String {
        return "upload"
    }
    
    var path: String {
        return "image"
    }
}

struct BankURL {
    static let domain = (Bundle.main.infoDictionary?["BANK_DOMAIN"] as? String) ?? "msh.chcts.cn"
    static let environment = (Bundle.main.infoDictionary?["DOMAIN_ENV"] as? String) ?? "stg"
}

public enum SSHPath: UserProtocol {
    case publicKey
    
    var path: String {
        return "ssh"
    }
    
    var endpoint: String {
        switch  self {
        case .publicKey:
            return "public_key"
        }
    }
}

// MARK: - 上传文件

public enum FileUploadPath: FileUploadProtocol {
    case upload
}

// MARK: - UserProtocol

/// 管家
public enum ButlerPath: UserProtocol {
    
    /// 我的管家
    case info
    /// 绑定/更换管家
    case bind
    /// 联系详情
    case chats
    /// 发送消息
    case sendMessage
    /// 评价管家
    case review
    
    var path: String {
        return "banker"
    }
    
    var endpoint: String {
        switch self {
        case .info:
            return "info"
        case .bind:
            return "binding"
        case .chats:
            return "chats"
        case .sendMessage:
            return "send_msg"
        case .review:
            return "evaluate"
        }
    }
}

/// 用户预约
public enum AppointPath: UserProtocol {
    
    /// 预约列表
    case list
    /// 网点查询
    case bankBranch
    /// 大额取款预约
    case withdraw
    /// 贷款申请预约
    case loan
    /// 预约详情
    case detail
    
    var path: String {
        return "bespeak"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .bankBranch:
            return "bank_branches"
        case .withdraw:
            return "withdraw_apply"
        case .loan:
            return "loan_apply"
        case .detail:
            return "detail"
        }
    }
}

/// 我的理财相关
public enum InvestPath: UserProtocol {
    
    /// 风险评估
    case riskAssess
    ///
    case purchasedProductInfo
    /// 认购理财产品
    case buyProduct
    /// 已购理财产品
    case purchasedProductList
    /// 理财产品列表
    case productList
    /// 理财产品详情
    case productDetail
    
    var path: String {
        return "financing"
    }
    
    var endpoint: String {
        switch self {
        case .riskAssess:
            return "risk_assessment"
        case .purchasedProductInfo:
            return "my_product_info"
        case .buyProduct:
            return "buy_product"
        case .purchasedProductList:
            return "bought_products"
        case .productList:
            return "index"
        case .productDetail:
            return "detail"
        }
    }
}

/// 投资理财
public enum EAccountPath: UserProtocol {
    
    /// 理财e账户
    case eAccount
    /// 充值
    case recharge
    /// 提现
    case withdraw
    /// 我的信用
    case credit
    /// 信用商品详情
    case creditGoodsInfo
    /// 还款
    case payCreditBill
    /// 还款明细
    case creditBillHistory
    
    var path: String {
        return "financing"
    }
    
    var endpoint: String {
        switch self {
        case .eAccount:
            return "e_account"
        case .recharge:
            return "recharge"
        case .withdraw:
            return "extract"
        case .credit:
            return "my_credit"
        case .creditGoodsInfo:
            return "credit_goods_info"
        case .payCreditBill:
            return "repay"
        case .creditBillHistory:
            return "repayment_list"
        }
    }
}

/// 便民服务
public enum ServicePath: UserProtocol {
    
    /// 话费充值
    case mobileBill
    /// 话费充值备选金额
    case mobileBillAmount
    /// 查询燃气费
    case queryGasBill
    /// 缴燃气费
    case payGasBill
    /// 查询水费
    case queryWaterBill
    /// 缴水费
    case payWaterBill
    /// 缴费记录
    case billHistory
    
    var path: String {
        return "handy"
    }
    
    var endpoint: String {
        switch self {
        case .mobileBill:
            return "pay_mobile_bill"
        case .mobileBillAmount:
            return "mobile_bill_spare"
        case .queryGasBill:
            return "query_gas_bill"
        case .payGasBill:
            return "pay_gas_bill"
        case .queryWaterBill:
            return "query_water_bill"
        case .payWaterBill:
            return "pay_water_bill"
        case .billHistory:
            return "payment_logs"
        }
    }
}

/// 首页/基础信息
public enum HomeBasicPath: UserProtocol {
    
    /// banner广告
    case homeBanner
    /// 首页数据
    case homeData
    /// 基础数据
    case basicData
    /// 图形验证码
    case captcha
    /// 发送手机验证码
    case smsVerifyCode
    /// 获取区域编码
    case regionCode
    
    var path: String {
        return "index"
    }
    
    var endpoint: String {
        switch self {
        case .homeBanner:
            return "banner"
        case .homeData:
            return "index"
        case .basicData:
            return "base_data"
        case .captcha:
            return "img_captcha"
        case .smsVerifyCode:
            return "sms_verify_code"
        case .regionCode:
            return "regions"
        }
    }
}

/// 我的成员
public enum MemberPath: UserProtocol {
    
    /// 成员列表
    case list
    /// 添加成员
    case add
    /// 删除成员
    case delete
    /// 修改成员
    case update
    /// 成员详情
    case detail
    /// 提醒TA
    case reInvite
    
    var path: String {
        return "member"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .add:
            return "add"
        case .delete:
            return "delete"
        case .update:
            return "update"
        case .detail:
            return "detail"
        case .reInvite:
            return "reinvite"
        }
    }
}

/// 我的银行
public enum BankCardPath: UserProtocol {
    
    /// 我的银行首页
    case index
    /// 我的银行卡列表
    case list
    /// 我的银行卡详情
    case detail
    /// 绑定银行卡
    case bind
    /// 解除绑定银行卡
    case unbind
    /// 银行卡明细
    case bill
    /// 转账
    case trans
    /// 计算转账手续费
    case transFee
    /// 获取上次绑卡身份信息
    case queryCard
    /// 注销身份
    case logout
    
    var path: String {
        return "my_bank"
    }
    
    var endpoint: String {
        switch self {
        case .index:
            return "index"
        case .list:
            return "my_card_list"
        case .detail:
            return "my_card_info"
        case .bind:
            return "binding_card"
        case .unbind:
            return "delete_card"
        case .bill:
            return "card_detail"
        case .trans:
            return "transfer"
        case .transFee:
            return "cal_rransfer_fee"
        case .queryCard:
            return "query_card"
        case .logout:
            return "logout_card"
        }
    }
}

/// 用户
public enum UserPath: UserProtocol {
    
    /// 获取登录用户基本信息
    case profile
    /// 获取绑定的用户的信息
    case fatherInfo
    /// 获取现有的积分
    case totalPoint
    /// 用户登录
    case login
    /// 会员注册
    case active
    /// 忘记登录密码
    case forgotLoginPassword
    /// 会员设置支付密码
    case setpayPass
    /// 验证支付密码
    case verifyPayPassword
    /// 支付密码状态
    case payPassStatus
    /// 会员贡献积分
    case contributPoint
    /// 会员申请成为签约用户
    case upGrade
    /// 关联信用账户
    case relevanceAccount
    /// 银行调用注册
    case bankRegister
    /// 忘记支付密码
    case forgotPayPassword
    /// 修改支付密码
    case updatePayPassword
    /// 修改用户基本信息
    case update
    /// 用户登出
    case logout
    /// 修改登录密码
    case updateLoginPassword
    /// 快捷菜单设置
    case setShortcuts
    /// 获取用户快捷菜单
    case getShortcuts
    /// 请求分享地址
    case getShareURL
    /// 用户反馈
    case feedback
    /// 用户注册
    case register
    /// 消息中心列表
    case notificationList
    /// 消息详情
    case notificationDetail
    /// 处理邀请信息
    case dealWithInviteMessage
    /// 删除消息
    case deleteNotificationList
    /// 消息置为已读
    case readNotification
    /// 未读消息数量
    case unreadNoticeCount
    /// 积分还款
    case intergralRepay
    /// 现金还款
    case moneyRepay
    /// 保存推送token
    case savePushToken
    /// 我的店铺
    case myStore
    /// 店员解绑
    case unwrap
    /// 发送原手机号验证码
    case sendOldCode
    /// 验证原手机号验证码
    case verifyOldCode
    /// 发送新手机号验证码
    case sendNewCode
    /// 修改新登录手机号
    case updateNewMobile
    /// 无原手机号登记新手机号
    case pendNew
    /// 无原手机号修改新登录手机号
    case updateNew
    
    var path: String {
        return "user"
    }
    
    var endpoint: String {
        switch self {
        case .profile:
            return "profile"
        case .login:
            return "login"
        case .active:
            return "register"
        case .update:
            return "update"
        case .logout:
            return "logout"
        case .updateLoginPassword:
            return "update_login_password"
        case .setShortcuts:
            return "set_quick_menu"
        case .getShortcuts:
            return "quick_menu"
        case .getShareURL:
            return "share"
        case .feedback:
            return "feedback"
        case .notificationList:
            return "msg_list"
        case .dealWithInviteMessage:
            return "process_intite_msg"
        case .deleteNotificationList:
            return "delete_msg"
        case .readNotification:
            return "read_msg"
        case .register:
            return "register"
        case .setpayPass:
            return "set_pay_password"
        case .forgotLoginPassword:
            return "forget_login_password"
        case .verifyPayPassword:
            return "verify_pay_password"
        case .updatePayPassword:
            return "modify_pay_password"
        case .contributPoint:
            return "contribution_point"
        case .forgotPayPassword:
            return "forget_pay_password"
        case .upGrade:
            return "user_upgrade"
        case .fatherInfo:
            return "father_info"
        case .totalPoint:
            return "total_point"
        case .payPassStatus:
            return "pay_password_status"
        case .notificationDetail:
            return "msg_detail"
        case .unreadNoticeCount:
            return "unread_msg"
        case .intergralRepay:
            return "integral_repay"
        case .moneyRepay:
            return "money_repay"
        case .myStore:
            return "my_store"
        case .unwrap:
            return "unwrap_staff"
        case .savePushToken:
            return "save_push_token"
        case .sendOldCode:
            return "login_mobile/send_old_code"
        case .verifyOldCode:
            return "login_mobile/verify_old_code"
        case .sendNewCode:
            return "login_mobile/send_new_code"
        case .updateNewMobile:
            return "login_mobile/update_new"
        case .relevanceAccount:
            return "relevance"
        case .bankRegister:
            return "bank_register"
        case .pendNew:
            return "no_ori_mobile/pend_new"
        case .updateNew:
            return "no_ori_mobile/update_new"
        }
    }
}

/// 本地生活
public enum MallPath: UserProtocol {
    /// 本地生活首页
    case mallHome
    /// 签到
    case checkIn
    /// 积分宝首页
    case pointEarnHome
    /// 积分兑换比例
    case pointExchangeRate
    /// 查询可兑换积分
    case isRedeemPoint
    /// 积分兑换
    case pointExchange
    /// 积分明细
    case pointEarnList
    /// 日常任务
    case newbieTaskList
    /// 领取日常任务
    case getTask
    /// 日常任务领奖
    case newbieTaskReward
    /// 日常任务详情
    case newbieTaskDetail
    /// 我的任务
    case myTasks
    /// 积分兑换记录列表
    case pointRedeemList
    /// 积分兑换结果详情
    case pointRedeemInfo
    
    var path: String {
        return "integral_mall"
    }
    
    var endpoint: String {
        switch self {
        case .mallHome:
            return "index"
        case .checkIn:
            return "check_in"
        case .pointEarnHome:
            return "point_index"
        case .pointExchangeRate:
            return "point_rate"
        case .isRedeemPoint:
            return "is_redeem_point"
        case .pointExchange:
            return "redeem_points"
        case .pointEarnList:
            return "point_list"
        case .newbieTaskList:
            return "daily_tasks"
        case .getTask:
            return "get_task"
        case .newbieTaskReward:
            return "daily_task_reward"
        case .newbieTaskDetail:
            return "task_detail"
        case .myTasks:
            return "my_tasks"
        case .pointRedeemList:
            return "point_redeem_list"
        case .pointRedeemInfo:
            return "point_redeem_info"
        }
    }
}

/// 指纹
public enum FingerPath: UserProtocol {
    
    /// 开启指纹
    case open
    /// 关闭指纹
    case close
    /// 指纹登录
    case login
    
    var path: String {
        return "fingerprint"
    }
    
    var endpoint: String {
        switch self {
        case .open:
            return "add"
        case .close:
            return "delete"
        case .login:
            return "login"
        }
    }
}

// MARK: - Content

/// 最终用户许可协议
public enum UserAgreementPath: ContentProtocol {
    
    /// 列表
    case list
    
    var path: String {
        return "protocol"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "index"
        }
    }
}

/// 理财产品
public enum InvestProductPath: ContentProtocol {
    
    /// 理财产品列表
    case productList
    /// 理财产品详情
    case productDetail
    
    var path: String {
        return "finance"
    }
    
    var endpoint: String {
        switch self {
        case .productDetail:
            return "product_detail"
        case .productList:
            return "product_list"
        }
    }
}

/// 帮助
public enum HelpPath: ContentProtocol {
    
    /// 获取帮助分类
    case list
    
    var path: String {
        return "help"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "index"
        }
    }
}

/// 头条/资讯
public enum NewsPath: ContentProtocol {
    
    /// 资讯列表
    case list
    /// 资讯分类列表
    case types
    /// 置顶资讯列表
    case topList
    /// 资讯详情
    case detail
    
    var path: String {
        return "news"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .types:
            return "types"
        case .topList:
            return "top_list"
        case .detail:
            return "detail"
        }
    }
}

/// 反馈
public enum FeedbackPath: ContentProtocol {
    
    /// 反馈分类列表
    case catList
    /// 保存反馈
    case save
    
    var path: String {
        return "feedback"
    }
    
    var endpoint: String {
        switch self {
        case .catList:
            return "cat_list"
        case .save:
            return "save"
        }
    }
}

/// 版本管理
public enum VersionPath: ContentProtocol {
    
    /// 获取最新版本
    case getLatestVersion
    
    var path: String {
        return "version"
    }
    
    var endpoint: String {
        switch self {
        case .getLatestVersion:
            return "get_version"
        }
    }
}

/// 系统消息(管理端发送)
public enum SystemMessagePath: ContentProtocol {
    
    /// 详情
    case detail
    
    var path: String {
        return "sys_notice"
    }
    
    var endpoint: String {
        switch self {
        case .detail:
            return "detail"
        }
    }
}

// MARK: - Market

/// 用户版首页
public enum UserHomePath: MarketProtocol {
    
    /// 首页的活动和广告
    case homeEvent
    
    var path: String {
        return "user_index"
    }
    
    var endpoint: String {
        switch self {
        case .homeEvent:
            return "index"
        }
    }
}

/// 广告
public enum AdvertisePath: MarketProtocol {
    
    /// 广告列表
    case list
    /// 广告详情
    case detail
    /// 广告问题
    case question
    /// 广告答题
    case answer
    
    var path: String {
        return "user_ad"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .question:
            return "question"
        case .answer:
            return "answer"
        case .detail:
            return "detail"
        }
    }
}

/// 现场活动
public enum OfflineEventPath: MarketProtocol {
    
    /// 活动列表
    case list
    /// 活动详情
    case detail
    /// 报名活动
    case signIn
    /// 取消报名
    case signOut
    /// 我的活动列表(已报名)
    case signedList
    /// 我的活动详情(已报名)
    case signedDetail
    
    var path: String {
        return "user_event"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .signIn:
            return "enroll"
        case .signOut:
            return "cancel_enroll"
        case .signedList:
            return "enrolled"
        case .detail:
            return "detail"
        case .signedDetail:
            return "enrolled_detail"
        }
    }
}

/// 砸金蛋
public enum GiftPath: MarketProtocol {
    
    /// 砸金蛋首页
    case index
    /// 砸金蛋抽奖
    case lottery
    /// 用户分享
    case share
    /// 奖品列表
    case poolList
    /// 奖品详情
    case giftDetail
    /// 我的奖品列表
    case myGiftList
    /// 我的奖品详情
    case myGiftDetail
    
    var path: String {
        return "gift"
    }
    
    var endpoint: String {
        switch self {
        case .index:
            return "index"
        case .lottery:
            return "lottery"
        case .share:
            return "share"
        case .poolList:
            return "pool_list"
        case .giftDetail:
            return "gift_info"
        case .myGiftList:
            return "my_gift_list"
        case .myGiftDetail:
            return "my_gift_info"
        }
    }
}

/// APP分享
public enum SharePath: MarketProtocol {
    
    /// 分享回调
    case callback
    /// 分享内容
    case appShareContent
    
    var path: String {
        return "share"
    }
    
    var endpoint: String {
        switch self {
        case .appShareContent:
            return "content"
        case .callback:
            return "index"
        }
    }
}

// MARK: - Business

/// 用户收藏
public enum CollectionPath: BusinessProtocol {
    
    /// 收藏的商品列表
    case goodsList
    /// 取消收藏
    case remove
    /// 添加收藏
    case add
    
    var path: String {
        return "enshrine"
    }
    
    var endpoint: String {
        switch self {
        case .goodsList:
            return "goods_list"
        case .remove:
            return "remove"
        case .add:
            return "add"
        }
    }
}

/// 促销活动
public enum OnlineEventPath: BusinessProtocol {
    
    /// 活动列表
    case list
    /// 活动详情
    case detail
    /// 活动描述
    case introduce
    
    var path: String {
        return "user_event"
    }
    
    var endpoint: String {
        switch self {
        case .list:
            return "list"
        case .detail:
            return "detail"
        case .introduce:
            return "introduce"
        }
    }
}

/// 商品
public enum GoodsPath: BusinessProtocol {
    
    /// 商品分类
    case category
    /// 商品列表
    case list
    /// 热门商品
    case hotGoodsList
    /// 排序选项
    case sort
    /// 通过商品ID获得列表
    case listByID
    /// 商品详情
    case goodsDetail
    /// 参与的优惠促销活动
    case eventList
    /// 参与团购的分店列表
    case storeList
    /// 商家列表
    case merchantList
    /// 商家详情
    case merchantInfo
    /// 商家置顶分类
    case merchantTopCats
    /// 商家店铺详情
    case storeInfo
    /// 同一货号下的备选商品(不同规格的商品)
    case alternativeGoods
    
    var path: String {
        return "user_goods"
    }
    
    var endpoint: String {
        switch self {
        case .category:
            return "cats"
        case .sort:
            return "orderby_list"
        case .list:
            return "list"
        case .hotGoodsList:
            return "hot_goods_list"
        case .listByID:
            return "list_by_goods_ids"
        case .goodsDetail:
            return "detail"
        case .storeList:
            return "store_list"
        case .merchantList:
            return "merchant_list"
        case .merchantInfo:
            return "merchant_base_info"
        case .storeInfo:
            return "merchant_store_info"
        case .merchantTopCats:
            return "merchant_top_cats"
        case .eventList:
            return "event_list"
        case .alternativeGoods:
            return "alternative_goods"
        }
    }
}

/// 购物车
public enum CartPath: BusinessProtocol {
    
    /// 加入购物车
    case addGoods
    /// 购物车删除商品
    case delGoods
    /// 获取购物车商品
    case getCart
    /// 修改购物车商品数量
    case updateGoodsNum
    /// 修改商品促销活动
    case updateOnlineEvent
    /// 购物车选中切换
    case cartCheck
    /// 移到收藏
    case removeCollection
    /// 购物车结算
    case checkOut
    /// 添加订单
    case addOrder
    /// 商品立刻购买
    case buyNow
    /// 商品准备立刻购买
    case buyNowPrepare
    /// 购物车商品数量
    case goodsNum
    
    var path: String {
        return "user_cart"
    }
    
    var endpoint: String {
        switch self {
        case .addGoods:
            return "add"
        case .delGoods:
            return "del"
        case .getCart:
            return "index"
        case .updateGoodsNum:
            return "change_goods_num"
        case .updateOnlineEvent:
            return "change_goods_event"
        case .cartCheck:
            return "toggle_check"
        case .removeCollection:
            return "move_to_enshrine"
        case .checkOut:
            return "check_out"
        case .addOrder:
            return "place_order"
        case .buyNow:
            return "buy_now"
        case .buyNowPrepare:
            return "buy_now_prepare"
        case .goodsNum:
            return "goods_num"
        }
    }
}

/// 订单
public enum OrderPath: BusinessProtocol {
    
    /// 订单
    public enum OrderAction {
        /// 订单列表
        case goodsOrderList
        /// 订单详情
        case detail
        /// 团购券列表
        case couponOrderList
        /// 团购券详情
        case couponDetail
        /// 团购券退款
        case couponRefund
        /// 团购券退款详情
        case serviceRefundDetail
        /// 取消订单
        case cancel
        /// 申请退款
        case refund
        /// 普通商品退款详情
        case refundDetail
        /// 退款订单列表
        case refundOrderList
        /// 确认收货
        case confirmOrder
        /// 评价
        case review
        /// 订单数量
        case orderNum
        /// 删除订单
        case delete
    }
    
    /// 地址管理
    public enum AddressAction {
        /// 地址列表
        case list
        /// 添加地址
        case add
        /// 修改地址
        case edit
        /// 删除地址
        case delete
    }
    
    case order(OrderAction)
    case address(AddressAction)
    
    var path: String {
        return "user_order"
    }
    
    var endpoint: String {
        switch self {
        case .address(let action):
            switch action {
            case .add:
                return "add_address"
            case .delete:
                return "del_address"
            case .edit:
                return "update_address"
            case .list:
                return "address_list"
            }
        case .order(let action):
            switch action {
            case .goodsOrderList:
                return "list"
            case .refundOrderList:
                return "refund_order"
            case .detail:
                return "detail"
            case .couponOrderList:
                return "coupon_list"
            case .couponDetail:
                return "coupon_detail"
            case .couponRefund:
                return "coupon_withdraw"
            case .cancel:
                return "cancel"
            case .refund:
                return "refund"
            case .refundDetail:
                return "refund_info"
            case .confirmOrder:
                return "confirm_receipt"
            case .review:
                return "evaluate"
            case .serviceRefundDetail:
                return "coupon_refund_info"
            case .orderNum:
                return "summary"
            case .delete:
                return "del_order"
            }
        }
    }
    
}

/// 用户支付
public enum UserPayPath: BusinessProtocol {
    
    /// 验证支付密码
    case verifyPayPass
    /// 重新发送验证码
    case sendSmsCode
    /// 支付在线购物订单
    case onlinePay
    /// 优惠买单付款
    case privilegePay
    /// 现金还款
    case moneyRepay
    //// 锁定订单
    case lockOrder
    
    var path: String {
        return "user/pay_order"
    }
    
    var endpoint: String {
        switch self {
        case .verifyPayPass:
            return "verify_pay_password"
        case .sendSmsCode:
            return "send_sms_code"
        case .onlinePay:
            return "online_pay"
        case .privilegePay:
            return "privilege_pay"
        case .moneyRepay:
            return "money_repay"
        case .lockOrder:
            return "lock_order"
        }
    }
}

/// 物流信息
public enum LogisticsPath: BusinessProtocol {
    
    /// 物流轨迹
    case tracks
    
    var path: String {
        return "logistics"
    }
    
    var endpoint: String {
        switch self {
        case .tracks:
            return "tracks"
        }
    }
    
}

/// 优惠买单
public enum DiscountPath: BusinessProtocol {
    
    /// 优惠买单订单列表
    case orderList
    /// 扫描优惠买单二维码
    case scan
    /// 优惠买单付款
    case payment
    /// 优惠买单优惠规则列表
    case ruleList
    
    var path: String {
        return "user_privilege"
    }
    
    var endpoint: String {
        switch self {
        case .orderList:
            return "order_list"
        case .scan:
            return "scan"
        case .payment:
            return "payment"
        case .ruleList:
            return "rule_list"
        }
    }
}

/// 打赏
public enum AwardPath: BusinessProtocol {
    
    /// 接受打赏
    case accept
    /// 打赏详情
    case detail
    /// 生成打赏二维码
    case code
    /// 用户打赏列表
    case userList
    /// 服务员被打赏列表
    case waiterList
    /// 打赏排行榜
    case rankList
    
    var path: String {
        return "award"
    }
    
    var endpoint: String {
        switch self {
        case .accept:
            return "award_staff"
        case .detail:
            return "award_info"
        case .code:
            return "award_code"
        case .userList:
            return "user_award"
        case .waiterList:
            return "staff_award"
        case .rankList:
            return "award_list"
        }
    }
}

// MARK: - Parameter

public class Header: Model {
    public var appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    public var deviceUUID: String {
        get {
            return AppConfig.shared.keychainData.deviceUUID
        }
        set {
            
        }
    }
    public var deviceModel: String = "1"
    public var deviceVersion: String = UIDevice.current.systemVersion
    public var devicePushToken: String? = AppConfig.shared.pushToken
    public var appSessionToken: String? = AppConfig.shared.keychainData.sessionToken
    public var contentType: String = "application/json"
    public var appRole: String = "member"
    public var registrationID: String? =  AppConfig.shared.registrationID
    
    override public func mapping(map: Map) {
        contentType <- map["Content_Type"]
        if AppConfig.shared.encrypt {
            appVersion <- map["APP_VERSION"]
            deviceUUID <- map["DEVICE_UUID"]
            deviceModel <- map["DEVICE_MODEL"]
            deviceVersion <- map["DEVICE_VERSION"]
            devicePushToken <- map["DEVICE_TOKEN"]
            appSessionToken <- map["APP_TOKEN"]
            appRole <- map["APP_ROLE"]
            registrationID <- map["REGISTRATION_ID"]
        } else {
            appVersion <- map["APP-VERSION"]
            deviceUUID <- map["DEVICE-UUID"]
            deviceModel <- map["DEVICE-MODEL"]
            deviceVersion <- map["DEVICE-VERSION"]
            devicePushToken <- map["DEVICE-TOKEN"]
            appSessionToken <- map["APP-TOKEN"]
            appRole <- map["APP-ROLE"]
            registrationID <- map["REGISTRATION-ID"]
        }
    }
}

// MARK: File Upload Parameter

class FileUploadParameter: Model {
    var dir: FileUploadDir?
    
    override func mapping(map: Map) {
        dir <- map["prefix[image]"]
    }
}

fileprivate let dateFormatter = CustomDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")

// MARK: Butler Parameter
class ButlerParameter: Model {
    
    var butlerNo: String?
    var remark: String?
    var chatsListTopId: String?
    var chatsListBottomId: String?
    var sendContent: Any?
    var type: MessageType?
    var review: String?
    
    override func mapping(map: Map) {
        butlerNo <- map["banker_jobno"]
        chatsListTopId <- map["list_top_id"]
        chatsListBottomId <- map["list_bottom_id"]
        sendContent <- map["content"]
        type <- map["type"]
        review <- map["grade"]
        remark <- map["banker_remark"]
    }
    
}

class AppointParameter: Model {
    var page: Int?
    var perPage: Int? = 20
    var appointID: String?
    var keyword: String?
    var location: CLLocationCoordinate2D? {
        didSet {
            if let loc = location {
                lat = loc.latitude
                lon = loc.longitude
            }
        }
    }
    fileprivate var lat: Double?
    fileprivate var lon: Double?
    var amount: Float?
    var appointTime: Date?
    var branchId: String?
    var mobile: String?
    // TODO: loan type
    var loanType: String?
    var verifyCode: String?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        appointID <- map["bespeak_id"]
        keyword <- map["keyword"]
        lat <- (map["lat"], DoubleStringTransform())
        lon <- (map["lng"], DoubleStringTransform())
        amount <- (map["money"], FloatStringTransform())
        appointTime <- (map["time"], dateFormatter)
        branchId <- map["branch_id"]
        mobile <- map["mobile"]
        loanType <- map["loan_type"]
        verifyCode <- map["code"]
    }
}

class CollectionParameter: Model {
    var page: Int?
    var perPage: Int?
    var goodsArray: [Collectable]?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        // FIXME: 测试可收集类型
        goodsArray <- map["items"]
    }
}

class InvestParameter: Model {
    var page: Int?
    var perPage: Int?
    var productID: String?
    var butlerNo: String?
    var amount: Float?
    var paymentType: PaymentType?
    /// 充值时付款账号
    var payAccountID: String?
    /// 提现时收款银行卡号
    var bankID: String?
    /// 信用商品
    var creditGoodsID: String?
    var startTime: Date?
    var endTime: Date?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        productID <- map["product_id"]
        butlerNo <- map["banker_jobno"]
        amount <- (map["money"], FloatStringTransform())
        paymentType <- map["pay_type"]
        payAccountID <- map["pay_account"]
        bankID <- map["bank_account_id"]
        creditGoodsID <- map["goods_id"]
        startTime <- (map["start_time"], dateFormatter)
        endTime <- (map["end_time"], dateFormatter)
    }
}

class ServiceParameter: Model {
    var mobile: String?
    var rechargeID: String?
    var paymentType: ServicePaymentType?
    var payAccountID: String?
    var gasNo: String?
    var waterNo: String?
    var page: Int?
    var perPage: Int?
    
    override func mapping(map: Map) {
        mobile <- map["mobile"]
        rechargeID <- map["recharge_id"]
        paymentType <- map["pay_type"]
        payAccountID <- map["pay_account"]
        gasNo <- map["gas_no"]
        waterNo <- map["water_no"]
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
    }
}

class HomeBasicParameter: Model {
    var bannerCount: Int?
    var bannerPosition: BannerPosition?
    var mobile: String?
    var verifyType: MobileVerifyType?
    var captcha: String?
    
    override func mapping(map: Map) {
        bannerCount <- (map["num"], IntStringTransform())
        bannerPosition <- map["position"]
        mobile <- map["mobile"]
        verifyType <- map["type"]
        captcha <- map["img_captcha"]
    }
}

class MallParameter: Model {
    var page: Int?
    var perPage: Int?
    var startTime: Date?
    var endTime: Date?
    var point: Int?
    var taskID: String?
    var pages: String?
    var sTime: String?
    var eTime: String?
    var payPass: String?
    var redeemID: String?
    
    override func mapping(map: Map) {
        point <- (map["point"], IntStringTransform())
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        startTime <- (map["start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        endTime <- (map["end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        taskID <- map["task_id"]
        sTime <- map["start_time"]
        eTime <- map["end_time"]
        payPass <- map["pay_password"]
        redeemID <- map["redeem_id"]
    }
}

class MemberParameter: Model {
    var mobile: String?
    /// 成员备注
    var remark: String?
    var memberID: String?
    /// 管家备注
    var bankerJobno: String?
    var bankerRemark: String?
    
    override func mapping(map: Map) {
        mobile <- map["mobile"]
        remark <- map["remark"]
        memberID <- map["member_id"]
        bankerJobno <- (map["banker_jobno"])
        bankerRemark <- (map["banker_remark"])
    }
}

class BankCardParameter: Model {
    /// 银行类型
    var bankType: PaymentType?
    /// 银行卡 ID
    var cardID: String?
    /// 银行卡卡号
    var cardNo: String?
    /// 持卡人姓名
    var holderName: String?
    /// 持卡人手机号码
    var holderMobile: String?
    /// 短信验证码
    var verifyCode: String?
    /// 支付密码
    var payPass: String?
    /// 合作银行 ID
    var bankID: String?
    var startTime: Date?
    var endTime: Date?
    var page: Int?
    var perPage: Int?
    var amount: Double?
    /// 是否跨行
    var crossTrans: Bool?
    /// 收款人姓名
    var receiverName: String?
    /// 收款人卡号
    var receiverCardNo: String?
    /// 收款人银行 ID
    var receiverBankID: String?
    var receiverBankName: String?
    /// 收款人电话
    var receiverMobile: String?
    /// 备注
    var remark: String?
    var idNumber: String?
    var step: Int?
    
    override func mapping(map: Map) {
        bankType <- map["bank_type"]
        cardID <- map["card_id"]
        cardNo <- map["number"]
        holderName <- map["name"]
        holderMobile <- map["mobile"]
        verifyCode <- map["verify_code"]
        bankID <- map["bank_id"]
        startTime <- (map["start_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        endTime <- (map["end_time"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        amount <- (map["money"], DoubleStringTransform())
        crossTrans <- (map["is_other"], BoolStringTransform())
        receiverName <- map["to_name"]
        receiverCardNo <- map["to_number"]
        receiverBankID <- map["to_bank_id"]
        receiverMobile <- map["to_mobile"]
        remark <- map["remark"]
        payPass <- map["pay_password"]
        idNumber <- map["idnumber"]
        step <- map["step"]
    }
}

class UserParameter: Model {
    var mobile: String?
    var smsCode: String?
    var password: String?
    var findPassword: FindLoginPassStep?
    
    /// 支付密码
    var payPassword: String?
    var idCardNo: String?
    
    var captcha: String?
    var userName: String?
    var nickName: String?
    var identifier: String?
    var shieldToken: String?
    var butlerNo: String?
    var avatar: String?
    var gender: Gender?
    var birthday: Date?
    var menuIDs: [String]?
    
    /// feedback
    var feedbackCatID: String?
    var feedbackReasonID: String?
    var feedbackContent: String?
    /// 联系方式
    var feedbackContact: String?
    var feedbackImages: [URL]?
    /// 消息中心分类
    var noticeCategory: NoticeCategory?
    var page: Int?
    var perPage: Int?
    //处理邀请信息
    var messageID: String?
    /// 系统消息ID
    var noticeID: String?
    var isAccept: Bool?
    //删除消息
    var messageIDs: [String]?
    
    var oldPassword: String?
    
    var oldPayPassword: String?
    
    /// 修改密码的步骤
    var step: UpdatePasswordType?
    
    var point: Int?
    var job: String?
    /// 积分还款
    var integral: Int?
    /// 现金还款
    var cardID: String?
    var money: String?
    var platfrom: PlatformType?
    var deviceToken: String?
    var deviceMode: String?
    var token: String?
    var verifyCode: String?
    
    var registrationID: String?
    
    override func mapping(map: Map) {
        mobile <- map["mobile"]
        password <- map["password"]
        findPassword <- map["step"]
        payPassword <- map["pay_password"]
        oldPayPassword <- map["old_pay_password"]
        idCardNo <- map["id_card"]
        smsCode <- map["code"]
        captcha <- map["img_captcha"]
        userName <- map["name"]
        nickName <- map["nickname"]
        identifier <- map["idnumber"]
        shieldToken <- map["shield_token"]
        butlerNo <- map["banker_jobno"]
        avatar <- map["avatar"]
        gender <- map["sex"]
        birthday <- (map["birthday"], dateFormatter)
        noticeCategory <- map["tab"]
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        menuIDs <- map["menu_ids"]
        feedbackCatID <- map["top_cat_id"]
        feedbackReasonID <- map["child_cat_id"]
        feedbackContent <- map["content"]
        feedbackContact <- map["contact"]
        feedbackImages <- (map["images"], URLTransform())
        oldPassword <- map["old_password"]
        step <- map["step"]
        point <- map["point"]
        messageID <- map["msg_id"]
        noticeID <- map["notice_id"]
        isAccept <- (map["is_accept"], BoolStringTransform())
        messageIDs <- map["msg_ids"]
        job <- map["job"]
        integral <- (map["integral"], IntStringTransform())
        cardID <- (map["card_id"])
        money <- (map["money"])
        platfrom <- map["platfrom"]
        deviceToken <- map["dt"]
        deviceMode <- map["dm"]
        registrationID <- map["registration_id"]
        token <- map["token"]
        verifyCode <- map["verify_code"]
    }
}

class InvestProductParameter: Model {
    var page: Int?
    var perPage: Int? = 20
    var isTop: Bool?
    var productID: String?
    
    override func mapping(map: Map) {
        productID <- map["product_id"]
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        isTop <- (map["is_top"], BoolStringTransform())
    }
}

class NewsParameter: Model {
    var newsID: String?
    var type: String?
    var isTopOnly: Bool?
    var isHotOnly: Bool?
    var page: Int?
    var perPage: Int?
    var parentKey: String?
    var position: NewsPosition?
    
    override func mapping(map: Map) {
        newsID <- map["id"]
        type <- map["type_key"]
        isTopOnly <- (map["is_top_only"], BoolStringTransform())
        isHotOnly <- (map["is_hot_only"], BoolStringTransform())
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        parentKey <- map["parent_key"]
        position <- map["position"]
    }
}

class AdvertiseParameter: Model {
    var page: Int?
    var perPage: Int?
    var adID: String?
    var answer: [String]?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        adID <- map["ad_id"]
        answer <- map["answer"]
    }
}

class OfflineEventParameter: Model {
    var page: Int?
    var perPage: Int?
    var eventID: String?
    var isSigned: Bool?
    var joinID: String?
    var sort: String?
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        eventID <- map["event_id"]
        isSigned <- (map["is_join"], BoolStringTransform())
        joinID <- map["id"]
        sort <- map["sort"]
    }
}

class OnlineEventParameter: Model {
    var page: Int?
    var perPage: Int?
    var eventID: String?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        eventID <- map["event_id"]
    }
}

class GiftParameter: Model {
    var poolID: Int?
    var giftID: Int?
    var userListID: Int?
    var page: Int?
    var perPage: Int?
    
    override func mapping(map: Map) {
        poolID <- (map["pool_id"], IntStringTransform())
        giftID <- (map["gift_id"], IntStringTransform())
        userListID <- (map["user_list_id"], IntStringTransform())
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        
    }
}

class GoodsParameter: Model {
    var page: Int?
    var perPage: Int?
    var tagID: GoodsTag?
    var catID: String?
    var district: String?
    var sortType: String?
    var sort: Int?
    var merchantID: String?
    var storeCategoryID: String?
    var keyword: String?
    var goodsIDs: [String]?
    var goodsID: String?
    // 货号ID
    var goodsConfigID: String?
    var goodsType: GoodsType?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        tagID <- map["tag_id"]
        catID <- map["cat_id"]
        district <- map["district"]
        sortType <- map["sort"]
        sort <- (map["sort"], IntStringTransform())
        merchantID <- map["merchant_id"]
        storeCategoryID <- map["store_cat_id"]
        keyword <- map["keyword"]
        goodsIDs <- map["goods"]
        goodsID <- map["goods_id"]
        goodsConfigID <- map["goods_config_id"]
        goodsType <- map["type"]
    }
}

/// 商品评分
class GoodsReview: Model {
    var goodsID: String?
    var score: Float?
    
    override func mapping(map: Map) {
        goodsID <- map["goods_id"]
        score <- map["score"]
    }
}

typealias AddressParameter = Address

class CartParameter: Model {
    var goods: [TheGoods]?
    var goodsIDs: [String]?
    var goodsID: String?
    var num: Int?
    var eventID: String?
    var merchantID: String?
    var isChecked: Bool?
    var addressID: String?
    var price: Float?
    
    override func mapping(map: Map) {
        goods <- map["goods"]
        goodsID <- map["goods_id"]
        goodsIDs <- map["goods"]
        num <- map["num"]
        eventID <- map["event_id"]
        merchantID <- map["merchant_id"]
        isChecked <- map["is_checked"]
        addressID <- map ["address_id"]
        price <- (map["price"], FloatStringTransform())
    }
}

class OrderParameter: Model {
    var page: Int?
    var perPage: Int?
    var goods: [TheGoods]?
    var goodsID: String?
    var goodsIDs: [String]?
    var num: Int?
    var price: Float?
    var eventID: String?
    var merchantID: String?
    var isChecked: Bool?
    var wholeOrderID: String?
    var addressID: String?
    var orderIDs: [String]?
    
    var subOrderIDs: [String]?
    var payment: PaymentType?
    /// 绑定银行卡的ID
    var payAccount: String?
    var payPassword: String?
    var outTradeNo: String?
    var keyword: String?
    var status: OrderStatus?
    var orderID: String?
    var refundID: String?
    var couponID: String?
    var isRefunding: Bool?
    var refundStatus: RefundStatus?
    /// 退款类型
    var refundType: String?
    /// 退款金额
    var refundAmount: Float?
    /// 退款原因
    var reason: String?
    /// 补充说明
    var remark: String?
    var imageURLs: [URL]?
    var goodsReviews: [GoodsReview]?
    
    override func mapping(map: Map) {
        page <- (map["page"], IntStringTransform())
        perPage <- (map["perpage"], IntStringTransform())
        goods <- map["goods"]
        goodsID <- map["goods_id"]
        goodsIDs <- map["goods"]
        price <- (map["price"], FloatStringTransform())
        num <- map["num"]
        eventID <- map["event_id"]
        merchantID <- map["merchant_id"]
        isChecked <- map["is_checked"]
        wholeOrderID <- map["whole_order_id"]
        addressID <- map ["address_id"]
        orderIDs <- map["order_ids"]
        subOrderIDs <- map["sub_order_ids"]
        payPassword <- map["pay_password"]
        payment <- map["pay_type"]
        payAccount <- map["pay_account"]
        outTradeNo <- map["out_trade_no"]
        keyword <- map["keyword"]
        isRefunding <- (map["is_refounding"], BoolStringTransform())
        status <- map["status"]
        orderID <- map["order_id"]
        refundID <- map["refund_id"]
        couponID <- map["coupon_id"]
        refundStatus <- map["refund_status"]
        refundType <- map["type"]
        refundAmount <- map["amount"]
        reason <- map["reason"]
        remark <- map["remark"]
        imageURLs <- (map["img"], URLTransform())
        goodsReviews <- map["goods_score"]
    }
}

/// 用户支付参数
class UserPayParameter: Model {
    var payPass: String?
    var cardID: String?
    var token: String?
    var subOrderIDs: [String]?
    var smsCode: String?
    var orderID: String?
    var money: String?
    
    override func mapping(map: Map) {
        payPass <- map["pay_password"]
        cardID <- map["card_id"]
        token <- map["token"]
        subOrderIDs <- map["sub_order_ids"]
        smsCode <- map["sms_code"]
        orderID <- map["order_id"]
        money <- map["money"]
    }
}

/// 锁定订单参数
class LockOrderParameter: Model {
    var subOrderIds: [String]?
    var lockTime: Int?
    
    override func mapping(map: Map) {
        lockTime <- (map["lock_time"], IntStringTransform())
        subOrderIds <- map["sub_order_ids"]
    }
}

class LogisticsParameter: Model {
    var orderID: Int?
    
    override func mapping(map: Map) {
        orderID <- map["order_id"]
    }
}

class BulterEvaluateParamter: Model {
    /// 评价
    var grade: Int?
    /// 结束消息ID
    var chatEndMessageID: String = ""
    
    override func mapping(map: Map) {
        grade <- (map["grade"], IntStringTransform())
        chatEndMessageID <- map["chat_detail_id"]
        
    }
}

class UpdateVersionParameter: Model {
    var currentVersionNum: String = ""
    
    override func mapping(map: Map) {
        currentVersionNum <- map["version_no"]
    }
    
}

public enum SharedPage: String {
    case productDetail = "1"
    case adAnswer = "2"
    case offlineEventDetail = "3"
    case onlineEventDetail = "4"
    case goodsDetail = "5"
    case shopDetail = "6"
    case headlineDetail = "7"
    case lottery = "8"
    case inviteFriends = "9"
    case reward = "10"
}

class ShareCallbackParameter: Model {
    var channel: String?
    var page: SharedPage?
    var `id`: String?
    
    override func mapping(map: Map) {
        channel <- map["share_way"]
        page <- map["share_page"]
        id <- map["thing_id"]
    }
}

/// 指纹
class FingerParameter: Model {
    var loginPass: String?
    var fingerPass: String?
    var deviceUUID: String?
    var mobile: String?
    
    override func mapping(map: Map) {
        loginPass <- map["login_password"]
        fingerPass <- map["fprint_password"]
        deviceUUID <- map["device_uuid"]
        mobile <- map["mobile"]
    }
}

/// 优惠买单
class DiscountParameter: Model {
    var page: Int?
    var perpage: Int?
    var code: String?
    var scanType: Int?
    var orderId: Int?
    var merchantID: Int?
    var payAccount: Int?
    var payPassword: String?
    
    override func mapping(map: Map) {
        page <- map["page"]
        perpage <- map["perpage"]
        code <- map["code"]
        scanType <- map["scan_type"]
        orderId <- map["order_id"]
        merchantID <- map["merchant_id"]
        payAccount <- map["pay_account"]
        payPassword <- map["pay_password"]
    }
}

/// 打赏
class AwardParameter: Model {
    /// 打赏码
    var code: String?
    var awardID: String?
    var page: Int?
    var pageSize: Int?
    var type: RankListType?
    var date: Date?
    
    override func mapping(map: Map) {
        code <- map["code"]
        awardID <- map["award_id"]
        page <- (map["page"], IntStringTransform())
        pageSize <- (map["pageSize"], IntStringTransform())
        type <- map["type"]
        date <- (map["date"], CustomDateFormatTransform(formatString: "yyyy-MM"))
    }
}

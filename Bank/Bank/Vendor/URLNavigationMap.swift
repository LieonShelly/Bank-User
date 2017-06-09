//
//  URLNavigationMap.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/21.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation
import URLNavigator
import Alamofire
import ObjectMapper

extension URLNavigator {
    func showAlertWithoutAction(_ title: String?, message: String, cancelButton: String = R.string.localizable.alertTitle_okay()) {
        let str = "mshuser://alert?title=\(title ?? "")&message=\(message)&button=\(cancelButton)"
        open(str)
    }
}

extension URLNavigator {
    func openInnerURL(_ url: Foundation.URL) {
        if url.scheme == Const.URLScheme {
            guard let string = url.host?.removingPercentEncoding else { return }
            guard let baseModel = Mapper<BaseInnerURLData>().map(JSONString: string), let action = baseModel.action else { return }
            var verifyLogin = false
            var urlComponents = URLComponents()
            urlComponents.scheme = url.scheme
            urlComponents.host = action.path
            switch action {
            case .gotoPage:
                // goto_page?page_id=
                if let model = Mapper<GotoPageData>().map(JSONString: string),
                    let pageID = model.extra?.pageID {
                    verifyLogin = pageID.verifyLogin
                    let item = URLQueryItem(name: "page_id", value: pageID.rawValue)
                    urlComponents.queryItems = [item]
                }
            case .showDetail:
                // show_detail?type=1&id=1
                if let model = Mapper<ShowDetailData>().map(JSONString: string),
                    let type = model.extra?.contentType.rawValue,
                    let value = model.extra?.contentID {
                    let item = URLQueryItem(name: "type", value: type)
                    let item2 = URLQueryItem(name: "id", value: value)
                    urlComponents.queryItems = [item, item2]
                }
            case .showGoodsAddress:
                // show_goods_address?goods_id=
                if let model = Mapper<ShowGoodsAddressData>().map(JSONString: string),
                    let value = model.extra?.goodsID {
                    let item = URLQueryItem(name: "goods_id", value: value)
                    urlComponents.queryItems = [item]
                }
            case .showGoodsPromos:
                // show_goods_promo?goods_id=
                if let model = Mapper<ShowGoodsPromoData>().map(JSONString: string),
                    let value = model.extra?.goodsID {
                    let item = URLQueryItem(name: "goods_id", value: value)
                    urlComponents.queryItems = [item]
                }
            case .showEventIntro:
                // show_event_introduce?type=1&id=1
                if let model = Mapper<ShowDetailData>().map(JSONString: string),
                    let type = model.extra?.contentType.rawValue,
                    let value = model.extra?.contentID {
                    let item = URLQueryItem(name: "type", value: type)
                    let item2 = URLQueryItem(name: "id", value: value)
                    urlComponents.queryItems = [item, item2]
                }
            case .showPlayVideo:
                // play_video?url=
                if let model = Mapper<PlayVideoData>().map(JSONString: string),
                    let value = model.extra?.url {
                    let item = URLQueryItem(name: "url", value: value)
                    urlComponents.queryItems = [item]
                }
            case .openURL:
                if let model = Mapper<OpenURLData>().map(JSONString: string),
                    let value = model.extra?.url {
                    let item = URLQueryItem(name: "url", value: value)
                    urlComponents.queryItems = [item]
                }
            case .alternativeGoods:
                if let model = Mapper<AlternativeGoodsData>().map(JSONString: string),
                    let value = model.extra?.goodsConfigID {
                    let item = URLQueryItem(name: "goods_config_id", value: value)
                    urlComponents.queryItems = [item]
                }
            case .showUserInvitation:
                if let model = Mapper<ShowUserInvitationData>().map(JSONString: string),
                    let mobile = model.extra?.mobile, let nickName = model.extra?.nickname, let userID = model.extra?.userID, let msgID = baseModel.msgID, let isProcessed = baseModel.isProcessed?.rawValue {
                    let item1 = URLQueryItem(name: "mobile", value: mobile)
                    let item2 = URLQueryItem(name: "nickname", value: nickName)
                    let item3 = URLQueryItem(name: "user_id", value: userID)
                    let item4 = URLQueryItem(name: "msg_id", value: msgID)
                    let item5 = URLQueryItem(name: "is_processed", value: isProcessed)
                    urlComponents.queryItems = [item1, item2, item3, item4, item5]
                }
            case .addStaff:
                if let model = Mapper<AddMerchantStaffData>().map(JSONString: string),
                    let merchantID = model.extra?.merchantID, let userName = model.extra?.username, let storeName = model.extra?.storeName, let msgID = baseModel.msgID, let isProcessed = baseModel.isProcessed?.rawValue {
                    let item1 = URLQueryItem(name: "merchant_id", value: merchantID)
                    let item2 = URLQueryItem(name: "user_name", value: userName)
                    let item3 = URLQueryItem(name: "store_name", value: storeName)
                    let item4 = URLQueryItem(name: "msg_id", value: msgID)
                    let item5 = URLQueryItem(name: "is_processed", value: isProcessed)
                    urlComponents.queryItems = [item1, item2, item3, item4, item5]
                }
            case .refreshOrderInfo:
                if let model = Mapper<RefreshOrderInfoData>().map(JSONString: string),
                    let orderID = model.extra?.orderID {
                    let item1 = URLQueryItem(name: "order_id", value: orderID)
                    urlComponents.queryItems = [item1]
                }
            default:
                break
            }
            if let compiledURL = urlComponents.url {
                if !AppConfig.shared.isLoginFlag && verifyLogin {
                    // login
                    if let app = UIApplication.shared.delegate as? AppDelegate {
                        app.containerVC?.needLogin()
                    }
                    return
                } else {
                    debugPrint(Navigator.open(compiledURL))
                }
            }
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
}

struct URLNavigationMap {
    
    static func initialize() {
        Navigator.scheme = Const.URLScheme
        // goto_page?page_id=
        Navigator.map("/goto_page") { (URL, values) -> Bool in
            guard let pageID = URL.queryParameters["page_id"],
                let page = PageID(rawValue: pageID) else { return false }
            var vc: UIViewController?
            switch page {
            case .lifeService:
                break
            case .pointMall:
                vc = R.storyboard.point.integralDetailViewController()
            case .eAccount:
                break
            case .coupon:
                vc = R.storyboard.myLife.myCouponViewController()
            case .withdraw:
                break
            case .bankCards:
                vc = R.storyboard.bank.cardsListViewController()
//            case .bankTransfer:
//                vc = R.storyboard.bank.transPickViewController()
//            case .butlerContact:
//                vc = ChatWithButlerViewController()
//                break
            case .loan:
                break
            case .shoppingCart:
                vc = R.storyboard.myLife.shoppingCartViewController()
            case .appoint:
                break
            case .member:
                vc = R.storyboard.myMember.myMemberViewController()
            case .collection:
                vc = R.storyboard.myLife.myCollectionViewController()
            case .myOrder:
                vc = R.storyboard.myOrder.myOrderViewController()
            case .recommendToBF:
                // 推荐好友
                vc = R.storyboard.main.shareViewController()
            case .repayList:
                /// TODO: 还款明细
                /// 详情页需要 信用商品等参数,
                break
            case .offlineEvent:
                vc = R.storyboard.point.offlineEventViewController()
            case .dailyTask:
                vc = R.storyboard.point.dailyTaskViewController()
            case .advertise:
                vc = R.storyboard.point.advertViewController()
            case .myCredit:
                vc = R.storyboard.credit.myCreditViewController()
            case .headline:
                vc = R.storyboard.news.newsHomeVC()
            case .myTask:
                vc = R.storyboard.point.myTaskViewController()
            case .myEvent:
                vc = R.storyboard.point.myEventViewController()
            case .shortcutSetting:
                vc = R.storyboard.setting.quickMenuViewController()
            case .scanQR:
                vc = R.storyboard.discount.scanQRViewController()
            case .privilegeList:
                vc = R.storyboard.discount.discountViewController()
//            case .index:
                // 被挤下线
//                if let app = UIApplication.shared.delegate as? AppDelegate {
//                    app.containerVC?.logout()
//                }
            default:
                break
            }
            if let vc = vc {
                Navigator.push(vc)
            }
            return true
        }
        // show_detail?type=1&id=1
        Navigator.map("/show_detail") { (URL, values) -> Bool in
            guard let type = URL.queryParameters["type"],
                let contentType = DetailContentType(rawValue: type),
                let contentID = URL.queryParameters["id"] else { return false }
            var vc: UIViewController?
            switch contentType {
            case .advertise:
                let detail = R.storyboard.point.advertDetailViewController()
                detail?.advertID = contentID
                vc = detail
//            case .butler:
//                let detail = R.storyboard.bank.myBulterTableViewController()
//                vc = detail
            case .coupon:
                let detail = R.storyboard.myLife.couponDetailViewController()
                detail?.couponID = contentID
                vc = detail
            case .goods:
                let detail = R.storyboard.mall.goodsDetailViewController()
                detail?.goodsID = contentID
                vc = detail
            case .goodsRefund:
                let detail = R.storyboard.myOrder.refundDetailTableViewController()
                detail?.refundID = contentID
                vc = detail
            case .headline:
                let detail = R.storyboard.news.newsDetailsViewController()
                detail?.newsID = contentID
                vc = detail
            case .invest:
                vc = nil
            case .offlineEvent:
                let detail = R.storyboard.point.offlineEventDetailViewController()
                detail?.eventID = contentID
                vc = detail
            case .onlineEvent:
                let detail = R.storyboard.mall.salesGoodsViewController()
                detail?.eventID = contentID
                vc = detail
            case .order:
                let detail = R.storyboard.myOrder.orderDetailsViewController()
                detail?.orderID = contentID
                vc = detail
            case .serviceGoods:
                let detail = R.storyboard.mall.goodsDetailViewController()
                detail?.goodsID = contentID
                vc = detail
            case .serviceRefund:
                let detail = R.storyboard.myOrder.serviceRefundDetailViewController()
                detail?.couponID = contentID
                vc = detail
            case .shop:
                // 跳转到品牌详情
                let detail = R.storyboard.mall.brandDetailViewController()
                detail?.merchantID = contentID
                vc = detail
            case .system:
                let detail = HelpViewController()
                detail.loadSystemNotice(messageID: contentID)
                vc = detail
            case .goodsCats:
                let detail = R.storyboard.mall.goodsListViewController()
                detail?.catID = contentID
                vc = detail
            case .staff:
                // TODO: what
                break
            case .dailyTask:
                let detail = R.storyboard.point.dailyTaskDetailViewController()
                detail?.taskID = contentID
                vc = detail
            default:
                break
            }
            if let vc = vc {
                Navigator.push(vc)
            }
            return true
        }
        // show_goods_address?goods_id=
        Navigator.map("/show_goods_address") { (URL, values) -> Bool in
            guard let goodsID = URL.queryParameters["goods_id"] else { return false }
            guard let vc = R.storyboard.mall.shopListViewController() else {
                return false
            }
            vc.goodsID = goodsID
            Navigator.push(vc)
            return true
        }
        // show_goods_promos?goods_id=
        Navigator.map("/show_goods_promos") { (URL, values) -> Bool in
            guard let _ = URL.queryParameters["goods_id"] else { return false }
            return true
        }
        // show_event_introduce?goods_id=
        Navigator.map("/show_event_introduce") { (URL, values) -> Bool in
            guard let type = URL.queryParameters["type"],
                let contentType = DetailContentType(rawValue: type),
                let contentID = URL.queryParameters["id"] else { return false }
            if contentType == .onlineEvent {
                guard let vc = R.storyboard.mall.eventDescribeViewController() else {
                    return false
                }
                vc.eventID = contentID
                Navigator.present(vc)
                return true
            }
            return false
        }
        
        // playVideo?url=
        Navigator.map("/play_video") { (URL, values) -> Bool in
            guard let url = URL.queryParameters["url"] else { return false }
            guard let vc = R.storyboard.point.webAdvertViewController() else {
                return false
            }
            vc.url = NSURL(string: url) as URL?
            Navigator.push(vc)
            return true
        }
        
        // openUrl?url=
        Navigator.map("/open_url") { (URL, values) -> Bool in
            guard let url = URL.queryParameters["url"] else { return false }
            guard let vc = R.storyboard.point.webAdvertViewController() else {
                return false
            }
            vc.url = NSURL(string: url) as URL?
            Navigator.push(vc)
            return true
        }
        
        // show_alternative_goods?goods_config_id=
        Navigator.map("/show_alternative_goods") { (URL, values) -> Bool in
            guard let goodsConfigID = URL.queryParameters["goods_config_id"] else { return false }
            guard let vc = R.storyboard.mall.chooseGoodsParamViewController() else {
                return false
            }
            vc.goodsConfigID = goodsConfigID
            Navigator.present(vc)
            return true
        }
        
        // 信用会员邀请成员
        Navigator.map("/show_user_invitation") { (URL, values) -> Bool in
            guard let mobile = URL.queryParameters["mobile"], let nickName = URL.queryParameters["nickname"], let userID = URL.queryParameters["user_id"], let msgID = URL.queryParameters["msg_id"], let isPrcossed = URL.queryParameters["is_processed"] else { return false }
            guard let vc = R.storyboard.main.inviteFromMemberViewController() else {
                return false
            }
            vc.mobile = mobile
            vc.nickName = nickName
            vc.userID = userID
            vc.msgID = msgID
            vc.isProcessed = NotificationProcessStatus(rawValue: isPrcossed)
            Navigator.push(vc)
            return true
        }
        
        // 邀请店员
        Navigator.map("/add_merchant_staff") { (URL, values) -> Bool in
            guard let _ = URL.queryParameters["merchant_id"], let userName = URL.queryParameters["user_name"], let storeName = URL.queryParameters["store_name"], let msgID = URL.queryParameters["msg_id"], let isPrcossed = URL.queryParameters["is_processed"] else { return false }
            guard let vc = R.storyboard.main.inviteFromWaiterViewController() else {
                return false
            }
            vc.userName = userName
            vc.storeName = storeName
            vc.messageID = msgID
            vc.isProcessed = NotificationProcessStatus(rawValue: isPrcossed)
            Navigator.push(vc)
            return true
        }
        
        // 刷新订单详情
        Navigator.map("/refresh_order_info") { (URL, values) -> Bool in
            guard let orderID = URL.queryParameters["order_id"] else { return false }
            guard let vc = R.storyboard.myOrder.orderDetailsViewController() else {
                return false
            }
            vc.orderID = orderID
            Navigator.push(vc)
            return true
        }

        Navigator.map("/alert") { (url, values) -> Bool in
            guard let urlValue = url.urlValue else { return false }
            let query = urlValue.queryDictionary()
            showAlert(query["title"], message: query["message"], button: query["button"])
            return true
        }
    }
    
    fileprivate static func showAlert(_ title: String?, message: String?, button: String? = R.string.localizable.alertTitle_okay()) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: button, style: .cancel, handler: nil))
        Navigator.present(alertVC)
    }
    
}

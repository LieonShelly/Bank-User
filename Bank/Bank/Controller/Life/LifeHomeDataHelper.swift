//
//  LifeHomeDataHelper.swift
//  Bank
//
//  Created by lieon on 2016/10/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import SwiftDate
import PINCache

class LifeHomeDataHelper {
    typealias EventAD = Banner
    var cityEvents: [CityEvent]?
    var merchantAds: [Advert]?
    lazy var banners: [Banner] = []
    lazy var topBaners: [Banner] = []
    var hotEventsBaners: [Banner]?
    var midleBanner: Banner?
    
    lazy var shortcuts: [QuickMenu] = []
    lazy var products: [Product] = []
    lazy var middleEvent: EventAD = EventAD()
    lazy var events: [EventAD] = []
    lazy var goods: [Goods] = []
    lazy var cats: [Banner] = []
    var unreadMessageCount: Int = 0
    
    func loadCityEvntsAndAds(finishCallBack: @escaping () -> Void) {
        let req: Promise<UserLifeHomeData> = handleRequest(Router.endpoint( UserHomePath.homeEvent, param: nil), needToken: .default)
        _ =  req.then { (value) -> Void in
            self.cityEvents = value.data?.cityEvents
            self.merchantAds = value.data?.merchantAds
            finishCallBack()
        }
    }
    
    func requestMiddleBaner(successCallBack: @escaping () -> Void) {
        requestBanner(1, position: BannerPosition.homeMiddleAd).then { (value) -> Void in
            if let arr = value.data?.banners, arr.count == 1 {
                self.midleBanner = arr[0]
                successCallBack()
            }
            }.catch { _ in
        }
    }
    
    /// banner
    func requestBanner(_ count: Int? = nil, position: BannerPosition) -> Promise<BannerListData> {
        let param = HomeBasicParameter()
        param.bannerCount = count
        param.bannerPosition = position
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        return req
    }
    
    /// 轮播数据
    func requestTopBanner(finishCallBack: @escaping () -> Void) {
        requestBanner(position: BannerPosition.homeBanner).then { (value) -> Void in
            if let arr = value.data?.banners {
                self.topBaners = arr
                finishCallBack()
            }
            }.catch { _ in }
    }
    
    /// 未读消息数
    func requestUnreadCount(finishCallBack: @escaping (_ unreadCount: Int) -> Void) {
        let req: Promise<NotificationUnreadData> = handleRequest(Router.endpoint(UserPath.unreadNoticeCount, param: nil))
        req.then { (value) -> Void in
            if let unread = value.data?.unreadCount {
                self.unreadMessageCount = unread
                finishCallBack(unread)
            }
            }.catch { _ in }
    }
    
    /// 精选促销数据
    func requestHotEventsBaners(finishCallBack: @escaping () -> Void) {
        requestBanner(2, position: BannerPosition.homeEvents).then { (value) -> Void in
            if let arr = value.data?.banners, !arr.isEmpty {
                self.hotEventsBaners = arr
            }
            finishCallBack()
            }.catch { _ in }
    }
    
    /// 商品分类数据
    func requestGoodsCats(finishCallBack: @escaping () -> Void) {
        requestBanner(nil, position: BannerPosition.homeGoodsCats).then { (value) -> Void in
            if let arr = value.data?.banners {
                self.cats = arr
                finishCallBack()
            }
            }.catch { _ in }
    }
    
    /// 快捷键
    func requestShortcuts(finishCallBack: @escaping () -> Void) {
        let req: Promise<GetQuickMenuData> = handleRequest(Router.endpoint( UserPath.getShortcuts, param: nil), needToken: .default)
        req.then { (value) -> Void in
            if var array = value.data?.menuList, !array.isEmpty {
                array = array.filter { return $0.isSelected }
                let add = QuickMenu.addNewMenu()
                array.append(add)
                if self.shortcuts.count != array.count || !self.shortcuts.containsArray(array: array) {
                    self.shortcuts = array
                    finishCallBack()
                }
            }
            }.catch { (error) in
                if let err = error as? AppError {
                    if let window = UIApplication.shared.keyWindow {
                        MBProgressHUD.errorMessage(view: window, message: err.toError().localizedDescription)
                    }
                }
        }
    }
    
    func requestGoods(finishCallBack: @escaping () -> Void) {
        let requestBody: Promise<LifeHomeData> = handleRequest(Router.endpoint( HomeBasicPath.homeData, param: nil), needToken: .default)
        requestBody.then { (value) -> Void in
            if let goods = value.data?.goodsList, !goods.isEmpty {
                self.goods = goods
                finishCallBack()
            }
            }.catch { (error) in
                finishCallBack()
                if let err = error as? AppError {
                    if let window = UIApplication.shared.keyWindow {
                        MBProgressHUD.errorMessage(view: window, message: err.toError().localizedDescription)
                    }
                }
        }
    }
    
    func initBaseData() {
        let req: Promise<BaseDataListData> = handleRequest(Router.endpoint(HomeBasicPath.basicData, param: nil), needToken: .default)
        req.then { (value) -> Void in
            AppConfig.shared.baseData = value.data
            if let data = value.data {
                data.saveToCache(key: CustomKey.CacheKey.baseDataKey)
            }
            }.catch { _ in
                BaseData.getFromCache(key: CustomKey.CacheKey.baseDataKey, block: { (data) in
                    AppConfig.shared.baseData = data
                })
        }
    }
    
}

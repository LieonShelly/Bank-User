//
//  Config.swift
//
//
//  Created by Koh Ryu on 11/16/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable identifier_name
import UIKit

extension NSNotification.Name {
    static let changeCategory = NSNotification.Name("ChangeCategory")
    static let changeCategoryUserInfoKey = NSNotification.Name("ChangeCategoryUserInfoKey")
    static let reviewModeDidChanged = NSNotification.Name("ReviewModeDidChanged")
    static let newNotification = NSNotification.Name("NewNotification")
    static let nextBtnClickNotifacation = NSNotification.Name("NextBtnClickNotifacation")
    static let needGetLatestVersion = NSNotification.Name("NeedGetLatestVersion")
    static let couponAwardStaff = NSNotification.Name("CouponAwardStaff")
    static let couponAwardStaffSuccess = NSNotification.Name("CouponAwardStaffSuccess")
    static let qrCodeEventSuccess = NSNotification.Name("QRCodeEventSuccess")
    static let loginSuccess = NSNotification.Name("LoginSuccess")
    static let refreshOrderInfo = NSNotification.Name("RefreshOrderInfo")
}

struct CustomKey {
    struct CacheKey {
        static let baseDataKey = "baseDataKey"
        static let regionKey = "regionKey"
    }
    struct Color {
        static let mainBlueColor: UInt32 = 0x00a8fe
        static let tabBackgroundColor: UInt32 = 0xf9f9f9
        static let viewBackgroundColor: UInt32 = 0xf2f2f2
        static let redDotColor: UInt32 = 0xFF3824
        static let lineColor: UInt32 = 0xe5e5e5
        static let greyColor: UInt32 = 0xa0a0a0
    }
    struct UserDefaultsKey {
        static let curVersion = "CurVersion"
        static let cfbundleShortVersionString = "CFBundleShortVersionString"
        static let isLogined = "isLogined"
        /// 是否设置了指纹
        static let isOpenFinger = "isOpenFinger"
        /// 是否需要引导开启指纹
        static let isNeedFinger = "isNeedFinger"
        static let sessionsKey = "sessionsKey"
        static let mobilesKeys = "mobilesKeys"
        static let staffID = "staffIDKey"
        static let loginDate = "loginDate"
        static let firstLaunchAfterColdInstall = "firstLaunchAfterColdInstall"
        /// 是否设置了支付密码
        static let isPaypassSet = "isPaypassSet"
        static let isSigned = "isSigned"
    }
    
    struct ObserverKeyPath {
        static let title = "title"
        static let estimatedProgress = "estimatedProgress"
    }
}

struct Const {
    struct TableView {
        struct SectionHeight {
            /// 有标题时的头部高度
            static let header40: CGFloat = 40.0
            /// 没有标题的头或者脚时的高度
            static let header17: CGFloat = 17.0
            static let header10: CGFloat = 10.0
            static let header25: CGFloat = 25.0
            /// 高度为0
            static let header0: CGFloat = 0.1
        }

        static let logoFooterGap: CGFloat = 25.0
    }
    
    struct Wechat {
        static let appID = (Bundle.main.infoDictionary?["WXAPPID"] as? String) ?? ""
        static let appSecret = (Bundle.main.infoDictionary?["WXAPPKEY"] as? String) ?? ""
    }
    struct Tencent {
        static let appID = (Bundle.main.infoDictionary?["QQAPPID"] as? String) ?? ""
    }
    struct Push {
        static let appKey: String = (Bundle.main.infoDictionary?["PUSHAPPKEY"] as? String) ?? ""
        static let appSecret: String = (Bundle.main.infoDictionary?["PUSHAPPSECRET"] as? String) ?? ""
    }
    
    static let appStatusFilePath = "appStatus".cacheDir()
    static let URLScheme = (Bundle.main.infoDictionary?["BANKURLSCHEME"] as? String) ?? ""

}

/**
 *  Keys for Keychain
 */
struct KeychainStore {
    static let account = Bundle.main.bundleIdentifier ?? "cn.chcts.bank.demo_preview_oauth"
}

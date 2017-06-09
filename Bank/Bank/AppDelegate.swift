//
//  AppDelegate.swift
//  Bank
//
//  Created by Koh Ryu on 11/16/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import MonkeyKing
import ObjectMapper
import URLNavigator
import Eureka
import PromiseKit
import CHPushSocket
import Fabric
import Whisper
import Crashlytics
import AudioUnit
import SwiftyBeaver

/// Global log instance
let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var containerVC: ContainerViewController?
    //后台任务
    var backgroundTask: UIBackgroundTaskIdentifier! = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configLog()
        Fabric.with([Crashlytics.self])
        UIApplication.shared.isIdleTimerDisabled = false
        UIApplication.shared.applicationIconBadgeNumber = 0
        do {
            try R.validate()
        } catch {}
        if let vc = window?.rootViewController as? ContainerViewController {
            containerVC = vc
        }
        configUI()
        configFormTable()
        CHService.registerRemoteNotification()
        URLNavigationMap.initialize()
        setupPush()
        
        if let splash = R.storyboard.container.splashViewController(), let window = window {
            splash.view.frame = CGRect(origin: .zero, size: window.bounds.size)
            window.rootViewController = splash
            self.perform(#selector(self.removeSplash), with: nil, afterDelay: 1.5)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLoginViewController), name: .nextBtnClickNotifacation, object: nil)
        
        if let options = launchOptions, let shortcutItem = options[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            AppConfig.shared.launchShortcutItemURL = handleShortItem(shortcutItem)
            return false
        }
        
        // remote notification 处理
        if let options = launchOptions, let notification = options[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
            guard let json = notification["aps"] as? [String: Any] else { return false }
            log.debug("APNs-payload [\(json)]")
            NSLog("APNs-payload [\(json)]")
            guard let extras = json["extras"] as? [String: Any] else { return false }
            var url = URLComponents()
            url.scheme = Const.URLScheme
            do {
                let data: Data = try JSONSerialization.data(withJSONObject: extras, options: [])
                guard let str = String(data:data, encoding: .utf8) else { return false }
                url.host = str
                if let url = url.url {
                    AppConfig.shared.launchShortcutItemURL = url
                }
            } catch {}
            if let messageID = extras["msg_id"] as? String {
                AppConfig.shared.requestToggleRead(messageID)
            }
            AppConfig.shared.unreadCount -= 1
        }
        
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .nextBtnClickNotifacation, object: nil)
    }
    
    private func configLog() {
        let format = "$Dyyyy-MM-dd HH:mm:ss$d $C$L$c $N.$F:$l - $M"
        
        let console = ConsoleDestination()
        console.format = format
        let file = FileDestination()
        file.minLevel = .verbose
        file.format = format
        let cloud = SBPlatformDestination(appID: "89AdzB", appSecret: "oaEhLCfl8fomAub2cyq6xgW9rjmsg2JO", encryptionKey: "1s2xPiEqDioYTwdfbx5inGbzqnsse1i2") // to cloud
        cloud.minLevel = .verbose
        
        log.addDestination(console)
        log.addDestination(file)
        log.addDestination(cloud)
        
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            log.debug("UserDefaults--key [\(key)], value [\(value)]")
        }
        log.debug("Device--UUID [\(AppConfig.shared.keychainData.deviceUUID)]")
        NSLog("Device--UUID [\(AppConfig.shared.keychainData.deviceUUID)]")
        log.debug("Session--token [\(AppConfig.shared.keychainData.sessionToken ?? "null")]")
        NSLog("Session--token [\(AppConfig.shared.keychainData.sessionToken ?? "null")]")
        log.debug("Session--mobile [\(AppConfig.shared.keychainData.mobile ?? "null")]")
        NSLog("Session--mobile [\(AppConfig.shared.keychainData.mobile ?? "null")]")
        log.debug("Session--login session [\(AppConfig.shared.keychainData.loginSession ?? "null")]")
        NSLog("Session--login session [\(AppConfig.shared.keychainData.loginSession ?? "null")]")
    }
    
    func showLoginViewController() {
        let anim = CATransition()
        anim.subtype = kCATransitionFromLeft
        self.window?.layer.add(anim, forKey: nil)
        self.window?.rootViewController = self.containerVC
    }
    
    @objc fileprivate func removeSplash() {
        self.window?.rootViewController = self.chooseRootViewController()
    }
    
    fileprivate func configUI() {
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        
        if let font = UIFont(name: "PingFangSC-Medium", size: 18) {
            UINavigationBar.appearance().titleTextAttributes =
                [NSForegroundColorAttributeName: UIColor.white,
                 NSFontAttributeName: font]
        }
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], for: .normal)
        //        UINavigationBar.appearance().backIndicatorImage = R.image.btn_left_arrow()
        UITabBar.appearance().barTintColor = UIColor(hex: CustomKey.Color.tabBackgroundColor)
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().tintColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        UITableView.appearance().separatorColor = UIColor(hex: CustomKey.Color.lineColor)
        UITableView.appearance().cellLayoutMarginsFollowReadableWidth = false
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = .systemFont(ofSize: 15)
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = UIColor(hex: CustomKey.Color.greyColor)
    }
    
    fileprivate func configFormTable() {
        TextRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textField.textAlignment = .left
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = UIColor(hex: 0x1c1c1c)
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(hex: 0x666666)
        }
        TextRow.defaultRowInitializer = { row in
            row.textFieldLeftConst = 110
        }
        PhoneRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textField.keyboardType = .numberPad
            cell.textField.textAlignment = .left
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = UIColor(hex: 0x1c1c1c)
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(hex: 0x666666)
        }
        PhoneRow.defaultCellSetup = { cell, row in
            row.textFieldLeftConst = 110
        }
        IntRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textField.textAlignment = .left
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = UIColor(hex: 0x1c1c1c)
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(hex: 0x666666)
        }
        IntRow.defaultCellSetup = { cell, row in
            row.textFieldLeftConst = 110
        }
        DateRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(hex: 0x666666)
            cell.detailTextLabel?.textColor = UIColor(hex: 0x1C1C1C)
        }
        PasswordRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textField.textAlignment = .left
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = UIColor(hex: 0x1c1c1c)
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(hex: 0x666666)
        }
        PasswordRow.defaultRowInitializer = { row in
            row.textFieldLeftConst = 110
        }
        DecimalRow.defaultCellUpdate = { cell, row in
            cell.height = { return 50 }
            cell.textField.textAlignment = .left
            cell.textField.font = .systemFont(ofSize: 17)
            cell.textField.textColor = UIColor(hex: 0x1c1c1c)
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor(hex: 0x666666)
        }
        DecimalRow.defaultRowInitializer = { row in
            row.textFieldLeftConst = 110
        }
        
    }
    
    /// 根据版本号返回控制器
     func chooseRootViewController() -> UIViewController {
        let flowLout = UICollectionViewFlowLayout()
        flowLout.itemSize = UIScreen.main.bounds.size
        flowLout.minimumLineSpacing = 0
        flowLout.minimumInteritemSpacing = 0
        flowLout.scrollDirection = .horizontal
        let guideVC = GuideCollectionViewController(collectionViewLayout: flowLout)
        
        let preV = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.curVersion) as? String == nil ? "0.0" : UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.curVersion) as? String
        guard let dic = Bundle.main.infoDictionary else {return guideVC}
        guard let curV = dic[CustomKey.UserDefaultsKey.cfbundleShortVersionString] as? String else {return guideVC}
        guard let container = self.containerVC else {return guideVC}
        if preV == curV {
            return container
        } else {
            UserDefaults.standard.set(curV, forKey: CustomKey.UserDefaultsKey.curVersion)
            return guideVC
        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        log.debug("APNs-token [\(tokenString)]")
        NSLog("APNs-token [\(tokenString)]")
        AppConfig.shared.pushToken = tokenString
        if !tokenString.isEmpty {
            CHWebSocket.shared.updateAPNsToken(tokenString)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        guard let json = userInfo["aps"] as? [String: Any] else { return }
        log.debug("APNs-payload [\(json)]")
        NSLog("APNs-payload [\(json)]")
        if application.applicationState == .background || application.applicationState == .inactive {
            guard let extras = json["extras"] as? [String: Any] else { return }
            var url = URLComponents()
            url.scheme = Const.URLScheme
            do {
                let data: Data = try JSONSerialization.data(withJSONObject: extras, options: [])
                guard let str = String(data:data, encoding: .utf8) else { return }
                url.host = str
                if let url = url.url {
                    Navigator.openInnerURL(url)
                }
            } catch {}
            if let messageID = extras["msg_id"] as? String {
                AppConfig.shared.requestToggleRead(messageID)
            }
            AppConfig.shared.unreadCount -= 1
        } else { }
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    private func handleShortItem(_ item: UIApplicationShortcutItem) -> URL? {
        guard let type = SystemShortcutType(rawValue: item.type) else { return nil }
        let urlObject = GotoPageData()
        switch type {
        case .cart:
            urlObject.extra?.pageID = .shoppingCart
        case .coupon:
            urlObject.extra?.pageID = .coupon
        case .point:
            urlObject.extra?.pageID = .pointMall
        case .scan:
            urlObject.extra?.pageID = .scanQR
        }
        var url = URLComponents()
        url.scheme = Const.URLScheme
        url.host = urlObject.toJSONString()
        return url.url
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let URL = handleShortItem(shortcutItem) {
            Navigator.openInnerURL(URL)
            completionHandler(true)
        }
        completionHandler(false)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        sendControlSum(1)
        if self.backgroundTask != nil {
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
        self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
            () -> Void in
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        sendControlSum(0)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
//        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: CustomKey.NotificationKey.NeedGetLatestVersion), object: self)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        AppConfig.shared.rememberAccountStatus = RememberAccountType.forcedTerminateApp
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return self.application(application, open: url, sourceApplication: nil, annotation: [])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if MonkeyKing.handleOpenURL(url) {
            return true
        }
        
        // URLNavigator Handler
        if Navigator.open(url) {
            return true
        }
        
        // URLNavigator View Controller
        if Navigator.present(url, wrap: true) != nil {
            return true
        }
        
        return false
    }
    
}

extension AppDelegate {
    fileprivate func setupPush(pushToken: String? = nil) {
        CHService.setupSocket(appKey: Const.Push.appKey, appSecret: Const.Push.appSecret, deviceToken: AppConfig.shared.keychainData.deviceUUID, applePushToken: pushToken)
        
        CHWebSocket.shared.connect()
        
        CHWebSocket.shared.didLoginCallBack = { registerID in
            log.debug("Socket-register id [\(registerID)]")
            NSLog("Socket-register id [\(registerID)]")
            AppConfig.shared.registrationID = registerID
            if let token = AppConfig.shared.pushToken {
                CHWebSocket.shared.updateAPNsToken(token)
            }
        }
        CHWebSocket.shared.didReceiveMessageCompletionHandler = { _, message in
            log.verbose("Socket-receive [\(message)]")
            guard let msg = message as? [String: Any] else { return }
            if UIApplication.shared.applicationState == .active  || UIApplication.shared.applicationState == .background {
                if let jsn = msg["notification"] as?  [String: Any] {
                    self.notificationHandle(json: jsn)
                } else if let jsn = msg["message"] as?  [String: Any] {
                    self.messageHandle(json: jsn)
                } else { }
            }
        }
    }
    
    /// 通知
    fileprivate func notificationHandle(json: [String: Any]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        guard let extras = json["extras"] as? [String: Any] else { return  }
        guard let alert = json["alert"] as? [String: Any] else {
            return
        }
        let announcement = Announcement(title: alert["title"] as? String ?? "", subtitle: alert["body"] as? String ?? "", image: nil, duration: 4, action: {
            guard let _ = extras["action"] as? String else { return }
            var url = URLComponents()
            url.scheme = Const.URLScheme
            do {
                let data: Data = try JSONSerialization.data(withJSONObject: extras, options: [])
                guard let str = String(data:data, encoding: .utf8) else { return }
                url.host = str
                if let url = url.url {
                    Navigator.openInnerURL(url)
                }
            } catch {}
            if let messageID = extras["msg_id"] as? String {
                AppConfig.shared.requestToggleRead(messageID)
            }
            AppConfig.shared.unreadCount -= 1
        })
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return }
        show(shout: announcement, to: vc, completion: nil)
        AppConfig.shared.unreadCount += 1
    }
    
    /// 站内信
    fileprivate func messageHandle(json: [String: Any]) {
        guard let extras = json["extras"] as? [String: Any] else { return  }
        guard let actionString = extras["action"] as? String, let action = URLAction(rawValue: actionString) else { return  }
        
        guard let extraDic = extras["extra"] else { return  }
        switch action {
        case .giftInfo:
             guard let model = Mapper<GiftInfoData>().map(JSON: extras), let vc = R.storyboard.lottery.prizeDetailViewController() else { return  }
             vc.giftID = model.extra?.giftID
             Navigator.push(vc)
        case .getFreeAwardChance:
            
            NotificationCenter.default.post(name: .couponAwardStaff, object: extraDic)
        case .staffGetTipsSuccess:
            NotificationCenter.default.post(name: .couponAwardStaffSuccess, object: extraDic)
        case .qrcodeEventSuccess:
            NotificationCenter.default.post(name: .qrCodeEventSuccess, object: extraDic)
        case .refreshOrderInfo:
            NotificationCenter.default.post(name: .refreshOrderInfo, object: extraDic)
        default:
            break
        }
    }
    
    func sendControlSum(_ isSum: Int) {
        guard let registrationID = AppConfig.shared.registrationID else { return }
        let param = ["registration_id": registrationID,
                     "is_sum": isSum,
                     "type": "control_sum"] as [String : Any]
        CHWebSocket.shared.send(param.toJSONString())
        print("***** control sum param [\(param.toJSONString())]******")
    }
}

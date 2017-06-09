//
//  ContainerViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/16.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire
import ObjectMapper
import URLNavigator

class ContainerViewController: UIViewController {
    
    fileprivate var mainVC: TabBarController!
    fileprivate var sessionNaviVC: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let main = R.storyboard.main.instantiateInitialViewController() else {
            return
        }
        mainVC = main
        mainVC.containerController = self
        addChildViewController(mainVC)
        self.view.addSubview(mainVC.view)
        self.mainVC.didMove(toParentViewController: self)
        
        guard let navVC = R.storyboard.session.instantiateInitialViewController() else { return }
        sessionNaviVC = navVC
        
//        fingerprintLogin()
//        _ = requestPublicKey()
//        registerNotification()
        getLatestVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
//    func fingerprintLogin() {
//        if let isOpenFinger = UserDefaults.standard.object(forKey: CustomKey.UserDefaultsKey.isOpenFinger) as? Bool {
//            if isOpenFinger == true {
//                if let vc = R.storyboard.session.fingerLoginViewController() {
//                    sessionNaviVC.viewControllers = [vc]
//                }
//                fingerSessionValid()
//            } else {
//                if let vc = R.storyboard.session.loginViewController() {
//                    sessionNaviVC.viewControllers = [vc]
//                }
//                sessionValid()
//            }
//        } else {
//            if let vc = R.storyboard.session.loginViewController() {
//                sessionNaviVC.viewControllers = [vc]
//            }
//            sessionValid()
//        }
//    }
    
    fileprivate func registerNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.needGetLatestVersion), name:NSNotification.Name(rawValue: CustomKey.NotificationKey.NeedGetLatestVersion), object: nil)
    }
    
    func needGetLatestVersion() {
        getLatestVersion()
    }
    
    deinit {
//         NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: CustomKey.NotificationKey.NeedGetLatestVersion), object: nil)
    }
    
    fileprivate  func getLatestVersion() {
        guard let dic = Bundle.main.infoDictionary else {return }
        guard let currentVersion = dic["CFBundleShortVersionString"] as? String else {return  }
       guard let buildNum = dic["CFBundleVersion"] as? String else { return  }
        let param = UpdateVersionParameter()
        param.currentVersionNum = buildNum
        let req: Promise<VerionData> = handleRequest(Router.endpoint( VersionPath.getLatestVersion, param: param), needToken: .default)
        req.then { (version) -> Void in
            guard  let newVersion = version.data else { return }
            let currentVersionStr = "v" + currentVersion
            let result =  currentVersionStr.compare(newVersion.versionName)
            var title: String = ""
            var msg: String = ""
            if result == .orderedAscending {
                title = R.string.localizable.alertTitle_found_new_version() + newVersion.versionName
                msg = newVersion.desc
                let alter = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                let actionEnter = UIAlertAction(title: R.string.localizable.alertTitle_update_now(), style: UIAlertActionStyle.default, handler: { (_) in
                    if let url = NSURL(string: newVersion.downloadUrl) {
                        UIApplication.shared.openURL(url as URL)
                    }
                })
                let actionCancel = UIAlertAction(title: R.string.localizable.alertTitle_update_later(), style: UIAlertActionStyle.cancel, handler: { (_) in
                    if newVersion.isForcrUpdate {
                        guard let window = UIApplication.shared.delegate?.window else { return }
                        UIView.animate(withDuration: 0.5, animations: {
                           guard let x = window?.frame.size.width else { return }
                            guard let y = window?.frame.size.width else { return }
                            window?.frame = CGRect(x: x / 2.0, y: y, width: 0, height: 0)
                            }, completion: { (_) in
                                exit(0)
                        })
                    }
                })
               
                alter.addAction(actionCancel)
                alter.addAction(actionEnter)
                Navigator.present(alter)
            }
           
            }.catch { _ in }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func requestPublicKey() -> Promise<String> {
        return Promise { fulfill, reject in
            if let key = AppConfig.shared.keychainData.publicKey {
                fulfill(key)
            } else {
                request(Router.endpoint( SSHPath.publicKey, param: nil))
                    .validate()
                    .responseJSON(completionHandler: { (response) in
                        switch response.result {
                        case .success(let value):
                            if let object = Mapper<SSHResponse>().map(JSONObject: value), object.isValid, let key = object.data?.publicKey, !key.isEmpty {
                                fulfill(key)
                            } else {
                                let error = AppError(code: RequestErrorCode.invalidSSHKey)
                                reject(error)
                            }
                        case .failure(let error):
                            reject(error)
                        }
                    })
            }
        }
        
    }
    
    /// 判断是否有效登录(密码登录) Token
    fileprivate func sessionValid() {
        guard let login = self.sessionNaviVC.topViewController as? LoginViewController else {
            return
        }
        requestPublicKey().then { (sshKey) -> Void in
            AppConfig.shared.keychainData.publicKey = sshKey
            login.containerController = self
            self.view.addSubview(self.sessionNaviVC.view)
            self.sessionNaviVC.didMove(toParentViewController: self)
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 判断是否有效登录(指纹登录) Token
//    fileprivate func fingerSessionValid() {
//        guard let login = self.sessionNaviVC.topViewController as? FingerLoginViewController else {
//            return
//        }
//        requestPublicKey().then { (sshKey) -> Void in
//            AppConfig.shared.keychainData.publicKey = sshKey
//            login.containerController = self
//            self.view.addSubview(self.sessionNaviVC.view)
//            self.sessionNaviVC.didMove(toParentViewController: self)
//            }.always {
//                
//            }.catch { (error) in
//                if let err = error as? AppError {
//                    Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
//                }
//        }
//    }
    
    fileprivate func showLoginView(_ animated: Bool = true, isFromLogout: Bool = false) {
        
        if let vc = R.storyboard.session.loginViewController() {
            vc.dismissHandle = { success in
                if isFromLogout {
                    self.mainVC.selectedIndex = 0
                }
            }
            vc.containerController = self
            sessionNaviVC.viewControllers = [vc]
        }
        present(sessionNaviVC, animated: true, completion: nil)
    }
    
    fileprivate func showMainView(_ animated: Bool = true) {
        mainVC.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func requestSaveToken() {
        let param = UserParameter()
        param.registrationID = AppConfig.shared.registrationID
        param.deviceToken = AppConfig.shared.pushToken
        param.deviceMode = "1"
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.savePushToken, param: param))
        req.then { (value) -> Void in
        }.catch { error in
            print(error.localizedDescription)
            self.requestSaveToken()
        }

    }

    func needLogin() {
        showLoginView()
    }
    
    private func clearSessionInfo() {
        AppConfig.shared.isLoginFlag = false
        AppConfig.shared.keychainData.removeSession()
        UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isPaypassSet)
        UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isSigned)
    }
    
    func logout(isNeedLogin: Bool = false, manual: Bool = false) {
        clearSessionInfo()
        if isNeedLogin {
            self.showLoginView(isFromLogout: true)
        } else {
            if !manual {
                let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_force_logout(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .cancel, handler: { _ in
                    self.mainVC.selectedIndex = 0
                }))
                mainVC.present(alert, animated: true, completion: nil)
            } else {
                self.mainVC.selectedIndex = 0
            }
        }
    }
    
    func successLogin() {
        AppConfig.shared.isLoginFlag = true
        requestSaveToken()
    }
    
    func successRegister() {
        AppConfig.shared.isLoginFlag = true
        sessionNaviVC.popToRootViewController(animated: false)
        requestSaveToken()
        showMainView()
    }
}

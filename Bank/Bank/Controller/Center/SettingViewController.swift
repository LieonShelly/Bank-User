//
//  SettingViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/24/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class SettingViewController: BaseTableViewController {

    @IBOutlet fileprivate weak var footView: UIView!
    @IBOutlet fileprivate weak var setTableView: UITableView!
    @IBOutlet weak var cacheData: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    var isSigned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView.tableFooterView = footView
        tableView.configBackgroundView()
        self.isSigned = AppConfig.shared.isUserSigned
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cacheData.text = getWipeCacheInfo()
        phoneLabel.text = AppConfig.shared.keychainData.getMobile().replaceWith(range: NSRange(location: 3, length: 4))

    }
    
    /// 开始摇动
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
    }
    
    /// 结束摇动
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        //shakeWipeCache()
    }

    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromPayPass(_ segue: UIStoryboardSegue) {
        
    }
    
    // 用户登出
    @IBAction func safeLogoutAction(_ sender: UIButton) {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.logout, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let delegate = UIApplication.shared.delegate as? AppDelegate, let containerVC = delegate.containerVC {
                    containerVC.logout(manual: true)
                }
                // 用户登出，将指纹是否开启标志置为false
//                UserDefaults.standard.set(false, forKey: CustomKey.UserDefaultsKey.isOpenFinger)
            }
        }.always {
            // 手动退出
            AppConfig.shared.rememberAccountStatus = RememberAccountType.manualQuitAccount
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    @IBAction func unwindFromPass(_ segue: UIStoryboardSegue) {
        
    }

}

extension SettingViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 17
        }
        return CGFloat.leastNormalMagnitude
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 10.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == 0 {
            cleanCache()
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            // 首先验证支付密码
            checkPayPass()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingViewController {
    
    func getWipeCacheInfo() -> String {
        // 取出cache文件夹路径
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {return ""}
        guard let files = FileManager.default.subpaths(atPath: cachePath) else {return ""}
        
        var big = Int()
        for p in files {
            let path = cachePath.appendingFormat("/\(p)")
            guard let floder = try? FileManager.default.attributesOfItem(atPath: path) else {return ""}
            for (abc, bcd) in floder where abc == FileAttributeKey.size {
                big += (bcd as AnyObject).intValue
            }
        }
        
        // 提示框
        let message = "\(big/(1024*1024))M"
        return message
    }
    
    func cleanCache() {
        // 取出cache文件夹路径
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {return}
        guard let files = FileManager.default.subpaths(atPath: cachePath) else {return}
        
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_is_clean_cache(), preferredStyle: UIAlertControllerStyle.alert)
        let alertConfirm = UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: UIAlertActionStyle.default) { (alertConfirm) -> Void in
            // 点击确定时开始删除
            for p in files {
                let path = cachePath.appendingFormat("/\(p)")
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch {
                        
                    }
                }
            }
            MBProgressHUD.loading(view: self.view)
            let time: TimeInterval = 2.0
            let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                MBProgressHUD.hide(for: self.view, animated: true)
                MBProgressHUD.errorMessage(view: self.view, message: R.string.localizable.alertTitle_clean_success())
                self.cacheData.text = "0M"
                self.tableView.reloadData()
            }
        }
        alert.addAction(alertConfirm)
        let cancle = UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: UIAlertActionStyle.cancel) { (cancle) -> Void in
        }
        alert.addAction(cancle)
        present(alert, animated: true) { () -> Void in
        }
    }
    
    func shakeWipeCache() {
        // 取出cache文件夹路径
        guard let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {return}
        guard let files = FileManager.default.subpaths(atPath: cachePath) else {return}
        
        var big = Int()
        for p in files {
            let path = cachePath.appendingFormat("/\(p)")
            guard let floder = try? FileManager.default.attributesOfItem(atPath: path) else {return}
            for (abc, bcd) in floder where abc == FileAttributeKey.size {
                big += (bcd as AnyObject).intValue
            }
        }
        
        // 提示框
        let message = "\(big/(1024*1024))MB"
        let alert = UIAlertController(title: R.string.localizable.alertTitle_clean_cache(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let alertConfirm = UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: UIAlertActionStyle.default) { (alertConfirm) -> Void in
            // 点击确定时开始删除
            for p in files {
                let path = cachePath.appendingFormat("/\(p)")
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch {
                        
                    }
                }
            }
            MBProgressHUD.loading(view: self.view)
            let time: TimeInterval = 2.0
            let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                MBProgressHUD.hide(for: self.view, animated: true)
                MBProgressHUD.errorMessage(view: self.view, message: R.string.localizable.alertTitle_clean_success())
            }
        }
        alert.addAction(alertConfirm)
        let cancle = UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: UIAlertActionStyle.cancel) { (cancle) -> Void in
            
        }
        alert.addAction(cancle)
        present(alert, animated: true) { () -> Void in
        }
    }
    
    /// 验证支付密码
    func checkPayPass() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.resultHandle = { [weak self] (result, pass) in
                
                switch result {
                case .passed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: { 
                        guard let mobileVC = R.storyboard.setting.checkOldMobileTableViewController() else {
                            return
                        }
                        mobileVC.title = R.string.localizable.controller_title_update_mobile()
                        self?.navigationController?.pushViewController(mobileVC, animated: true)
                    })
                case .failed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.setFundPassAlertController()
                default:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                }
            }
            self.dim(.in, coverNavigationBar: true)
            self.present(vc, animated: true, completion: nil)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                guard let err = error as? AppError else {
                    return
                }
                if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    self.setFundPassAlertController(message: err.toError().localizedDescription)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

extension SettingViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (section, row) = (indexPath.section, indexPath.row)
        switch (section, row) {
        case(1, 0):
            return self.isSigned ? CGFloat.leastNonzeroMagnitude : 50
        default:
            return 50
        }
    }
}

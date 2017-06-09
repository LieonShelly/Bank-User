//
//  RewardViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class RewardViewController: BaseViewController {
    
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    fileprivate var timer: Timer!
    fileprivate var time = 5 * 60
    var awardID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tabBarController?.tabBar.isHidden = true
        title = R.string.localizable.center_myaward_reward_title()
        requestCodeData()
        configLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(couponAwardStaffSuccess), name: .couponAwardStaffSuccess, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .couponAwardStaffSuccess, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 接收到打赏成功的通知，跳转到打赏详情页
    ///
    /// - Parameter notification: 通知
    func couponAwardStaffSuccess(_ notification: NSNotification) {
        guard let vc = R.storyboard.myAward.rewardDetailViewController() else {
            return
        }
        if let extra = notification.object as? [String: Any], let awardID = extra["award_id"] as? String {
            vc.awardID = awardID
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 设置“扫一扫”字体高亮带下划线
    fileprivate func configLabel() {
        let string = R.string.localizable.center_myward_messagelabel_string()
        let str = NSString(string: string)
        let range = str.range(of: "扫一扫")
        let attributString = NSMutableAttributedString(string: string)
        _ = NSMutableAttributedString(attributedString: attributString.attributedSubstring(from: range))
        attributString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x00a8fe), range: range)
        attributString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: range)
        let paraStyle = NSParagraphStyle()
        paraStyle.setValue(5, forKey: "lineSpacing")
        attributString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0, length: attributString.length))
        messageLabel.attributedText = attributString
    }
    
    /// 请求二维码
    fileprivate func requestCodeData() {
        let param = AwardParameter()
        param.awardID = awardID
        MBProgressHUD.loading(view: view)
        let req: Promise<AwardData> = handleRequest(Router.endpoint(AwardPath.code, param: param))
        req.then { (value) -> Void in
            if let code = value.data?.code {
                if let data = Data(base64Encoded: code, options: .ignoreUnknownCharacters) {
                    self.codeImageView.image = UIImage(data: data)
                }
                self.timerStart()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    /// 更新二维码
    @IBAction func updateCodeAction(_ sender: UIButton) {
        timerEnd()
    }
    
    /// 帮助
    @IBAction func helpAction(_ sender: UIButton) {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {
            return
        }
        vc.tag = HelpCenterTag.award
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func timerStart() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func timerAction() {
        time -= 1
        if time == 0 {
            timerEnd()
        }
    }
    
    func timerEnd() {
        if timer != nil {
            timer.invalidate()
        }
        timer = nil
        time = 5 * 60
        requestCodeData()
    }
    
}

//
//  InviteFromMemberViewController.swift
//  Bank
//
//  Created by 王虹翔 on 16/6/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import ObjectMapper
import Alamofire
import URLNavigator
import MBProgressHUD

class InviteFromMemberViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet fileprivate weak var memberName: UILabel!
    @IBOutlet fileprivate weak var acceptInviteButton: UIButton!
    @IBOutlet fileprivate weak var refuseInviteButton: UIButton!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet var headerView: UIView!
    
//    var data: Notification?
    var mobile: String?
    var nickName: String?
    var userID: String?
    var msgID: String?
    var isProcessed: NotificationProcessStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        tableView.backgroundColor = UIColor(hex: 0xfff2c8)
        headerView.frame = tableView.bounds
        tableView.tableFooterView = headerView
        setupNavigationbar()
        setBlackLeftBarButton()
        memberName.numberOfLines = 0
        navigationController?.navigationBar.backgroundColor = UIColor(hex: 0xfff2c8)
        if let name = nickName, let phone = mobile {
            var string = "您的好友"
            string.append(name)
            string.append(",")
            string.append("手机号")
            string.append(phone)
            string.append(",")
            string.append("邀请你成为他的成员, 一起赚积分, 赢好礼")
            let contentAttributString = NSMutableAttributedString(string: "        \(string)。")
            contentAttributString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x00a8fe), range: NSRange(location: 12, length: name.characters.count))
            let paraStyle = NSParagraphStyle()
            paraStyle.setValue(10, forKey: "lineSpacing")
            contentAttributString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0, length: contentAttributString.length))
            memberName.attributedText = contentAttributString
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        processeStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        getbackNaigationbar()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        getbackNaigationbar()
    }
    // 处理邀请信息
    func dealNotification(_ click: Bool) {
        let hud = MBProgressHUD.loading(view: view)
        let dealParam = UserParameter()
        dealParam.messageID = msgID
        dealParam.isAccept = click
        let req: Promise<NullDataResponse> =
            handleRequest(Router.endpoint(UserPath.dealWithInviteMessage, param: dealParam))
        req.then { (value) -> Void in

            if let view = self.navigationController?.view {
                if !click {
                    MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_refuse_success())
                } else {
                    MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_accept_success())
                }
            }
            _ = self.navigationController?.popViewController(animated: true)
            }.always {
                hud.hide(animated: true)

            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    func processeStatus() {
        guard let isProcessed = isProcessed else { return }
        switch isProcessed {
        case .accepted:
            buttonHidden()
            typeImageView.image = UIImage(named: "pic_postmark01")
        case .expired:
            buttonHidden()
            typeImageView.image = UIImage(named: "pic_lose")
        case .refuse:
            buttonHidden()
            typeImageView.image = UIImage(named: "pic_postmark02")
            break
        case .unDeal:
            break
        }
        if AppConfig.shared.isUserSigned {
            typeImageView.image = UIImage(named: "pic_lose")
            buttonHidden()
        }

    }
    
    func buttonHidden() {
        refuseInviteButton.backgroundColor = UIColor(hex: 0xe5e5e5)
        acceptInviteButton.backgroundColor = UIColor(hex: 0xe5e5e5)
        refuseInviteButton.setTitleColor(UIColor(hex: 0xA1A1A1), for: UIControlState())
        acceptInviteButton.setTitleColor(UIColor(hex: 0xA1A1A1), for: UIControlState())
        refuseInviteButton.isEnabled = false
        acceptInviteButton.isEnabled = false
    }
    
    @IBAction func acceptInviteButton(_ sender: AnyObject) {
        dealNotification(true)
        self.acceptInviteButton.isUserInteractionEnabled = false
    }
    @IBAction func refuseInviteButton(_ sender: AnyObject) {
        dealNotification(false)
        self.refuseInviteButton.isUserInteractionEnabled = false
    }
}

extension InviteFromMemberViewController {
    func setupNavigationbar() {
        self.title = "消息中心"
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0xfff2c8)
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.black]
        UIApplication.shared.statusBarStyle = .default
    }
    func getbackNaigationbar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func leftAction() {
        _ = self.navigationController?.popViewController(animated: true)
//        guard let vc = self.navigationController?.viewControllers[1] as? NotificationViewController else {return}
//        vc.setLeftBarButton()
    }
}

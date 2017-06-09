//
//  InviteFromWaiterViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import ObjectMapper
import MBProgressHUD

class InviteFromWaiterViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var refuseButton: UIButton!
    @IBOutlet fileprivate weak var acceptButton: UIButton!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet var headerView: UIView!
    
    var messageID: String?
    var userName: String?
    var storeName: String?
    var isProcessed: NotificationProcessStatus?
    
//    var data: Notification?
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        tableView.backgroundColor = UIColor(hex: 0xfff2c8)
        headerView.frame = tableView.bounds
        tableView.tableFooterView = headerView
        setBlackLeftBarButton()
        setupNavigationbar()
        view.backgroundColor = UIColor.white
        setUI()
        processeStatus()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        getbackNaigationbar()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        getbackNaigationbar()
    }
    
    func setUI() {
        // 设置消息开头
        guard let name = userName else {
            return
        }
        let text =  "\(name)您好:"
        let nameAttributString = NSMutableAttributedString(string: text)
        nameAttributString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: text.characters.count - 3))
        nameLabel.attributedText = nameAttributString
        guard let storeName = storeName else {
            return
        }
        // 设置消息内容
        var content: String = "\(storeName)"
        content.append("的老板邀请您成为他的员工，绑定后可享店员福利。")
        let contentAttributString = NSMutableAttributedString(string: content)

       contentAttributString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: 0x00a8fe), range: NSRange(location: 0, length: storeName.characters.count))
        let paraStyle = NSParagraphStyle()
        paraStyle.setValue(10, forKey: "lineSpacing")
        contentAttributString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0, length: contentAttributString.length))
        contentLabel.attributedText = contentAttributString
        
    }
    
    func processeStatus() {
        guard let progress = isProcessed else { return }
        switch progress {
        case .accepted:
            buttonHidden()
            typeImageView.image = UIImage(named: "pic_postmark01")
        case .expired:
            buttonHidden()
            typeImageView.image = UIImage(named: "pic_postmark")
        case .refuse:
            buttonHidden()
            typeImageView.image = UIImage(named: "pic_postmark02")
        case .unDeal:
            break
        }
    }
    
    func buttonHidden() {
        refuseButton.backgroundColor = UIColor(hex: 0xe5e5e5)
        acceptButton.backgroundColor = UIColor(hex: 0xe5e5e5)
        refuseButton.setTitleColor(UIColor(hex: 0xA1A1A1), for: UIControlState())
        acceptButton.setTitleColor(UIColor(hex: 0xA1A1A1), for: UIControlState())
        refuseButton.isEnabled = false
        acceptButton.isEnabled = false
    }
}

extension InviteFromWaiterViewController {
    /// 拒绝
    @IBAction func accpetHandle(_ sender: AnyObject) {
        dealNotification(true)
        buttonHidden()
    }
    /// 接收
    @IBAction func cancleHandle(_ sender: AnyObject) {
        dealNotification(false)
        buttonHidden()
    }
    
    func dealNotification(_ click: Bool) {
        MBProgressHUD.loading(view: view)
        let dealParam = UserParameter()
        dealParam.messageID = messageID
        dealParam.isAccept = click
        let req: Promise<NullDataResponse> =
            handleRequest(Router.endpoint(UserPath.dealWithInviteMessage, param: dealParam))
        req.then { (value) -> Void in
            if let view = self.navigationController?.view {
                let message: String = click ? "成功接受邀请" : "成功拒绝该邀请"
                MBProgressHUD.errorMessage(view: view, message: message)
            }
            _ = self.navigationController?.popViewController(animated: true)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

extension InviteFromWaiterViewController {
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

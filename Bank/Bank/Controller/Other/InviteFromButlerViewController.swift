//
//  InviteFromButlerViewController.swift
//  Bank
//
//  Created by Tzzzzz on 16/9/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.

import UIKit
import PromiseKit
import URLNavigator
import ObjectMapper
import MBProgressHUD

class InviteFromButlerViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var refuseButton: UIButton!
    @IBOutlet fileprivate weak var acceptButton: UIButton!
    @IBOutlet fileprivate weak var tipImageView: UIImageView!
    @IBOutlet var headerView: UIView!
    var messageID: String?
    var data: Notification?
    
    override func viewDidLoad() {
        tableView.backgroundColor = UIColor(hex: 0xfff2c8)
        headerView.frame = tableView.bounds
        tableView.tableFooterView = headerView
        view.backgroundColor = UIColor.white
        setBlackLeftBarButton()
        setupNavigationbar()
        guard let content = data?.content else {return}
        
        let contentAttributString = NSMutableAttributedString(string: content)
        let paraStyle = NSParagraphStyle()
        paraStyle.setValue(10, forKey: "lineSpacing")
        contentAttributString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0, length: contentAttributString.length))
        contentLabel.attributedText = contentAttributString
        processeStatus()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        getbackNaigationbar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        getbackNaigationbar()
    }
    
    func processeStatus() {
        guard let progress = data?.processProgress else { return }
        switch progress {
        case .accepted:
            buttonHidden()
            tipImageView.image = UIImage(named: "pic_postmark01")
            break
        case .expired:
            buttonHidden()
            tipImageView.image = UIImage(named: "pic_postmark")
        case .refuse:
            buttonHidden()
            tipImageView.image = UIImage(named: "pic_postmark02")
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

extension InviteFromButlerViewController {
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
        dealParam.messageID = data?.messageID
        dealParam.isAccept = click
        let req: Promise<NullDataResponse> =
            handleRequest(Router.endpoint(UserPath.dealWithInviteMessage, param: dealParam))
        req.then { (value) -> Void in
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

extension InviteFromButlerViewController {
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
        guard let vc = self.navigationController?.viewControllers[1] as? NotificationViewController else {return}
        vc.setLeftBarButton()
        _ = self.navigationController?.popToViewController(vc, animated: true)
    }    
}

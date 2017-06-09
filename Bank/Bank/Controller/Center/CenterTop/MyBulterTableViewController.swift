//
//  MyBulterTableViewController.swift
//  Bank
//
//  Created by yang on 16/3/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
//  swiftlint:disable private_outlet

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import MBProgressHUD

private let takePone = "是否拨打"
private let changeBulter = "更换管家"

class MyBulterTableViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var starViews: UIStackView!
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet fileprivate weak var headerImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var phoneLabel: UILabel!
    @IBOutlet fileprivate weak var gradeLabel: UILabel!
    @IBOutlet fileprivate weak var remarkLabel: UILabel!
    @IBOutlet fileprivate weak var bulterNumberLabel: UILabel!
    
    fileprivate lazy var hud: MBProgressHUD = {
        let hud = MBProgressHUD()
        hud.center = CGPoint(x: UIScreen.main.bounds.width*0.5, y: UIScreen.main.bounds.height*0.5)
        hud.backgroundColor = UIColor.white
        self.view.addSubview(hud)
        return hud
    }()
    
    var butler: Butler?
    var starImageViews: [UIImageView] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = headerView
        tableView.configBackgroundView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestBulterData()
    }
    
    override func viewDidLayoutSubviews() {
        headerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 108)
    }
    ///请求管家信息
    func requestBulterData() {
        self.hud.show(animated: true)
        let req: Promise<ButlerInfoData> = handleRequest(Router.endpoint(endpoint: ButlerPath.info, param: nil))
        req.then { value -> Void in
            self.butler = value.data
            self.configUI(value.isValid)
            }.always {
                self.hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    func configUI(_ isBinded: Bool) {
        if isBinded == false {
            guard let bindBulterVC = R.storyboard.bank.bindBulterViewController() else { return }
            addChildViewController(bindBulterVC)
            tableView.addSubview((bindBulterVC.view))
            title = "绑定管家"
            navigationItem.rightBarButtonItem?.image = nil
        } else {
            configInfo(butler)
        }
    }
    
    /// 设置管家信息
    func configInfo(_ data: Butler?) {
        guard let data = data else {return}
        //headerImageView
        nameLabel.text = data.name
        phoneLabel.text = data.mobile
        gradeLabel.text = data.rate
        remarkLabel.text = data.remark
        bulterNumberLabel.text = data.jobID
        headerImageView.setImageWithURL(data.imageURL, placeholderImage: R.image.head_default())

        guard let countFloat = Float(data.rate) else {return}
        let countInt = Int(countFloat)
        for i in 0..<countInt {
            if  let starImageView = starViews.subviews[i] as? UIImageView {
                starImageView.image = R.image.ico_stars_o()
            }
        }
    }
    
    /// 更多
    @IBAction func moreAction(_ sender: UIBarButtonItem) {
        showAlertTitle(changeBulter)
    }
    
    /// 给管家留言
    @IBAction func gotoContactAction(_ sender: UIButton) {
        self.navigationController?.pushViewController(ChatWithButlerViewController(), animated: true)
    }
    
    /// 给管家打电话
    @IBAction func callAction(_ sender: UIButton) {
        guard let phoneNumber = self.phoneLabel.text else {return}
        showAlertTitle("\(takePone)\(phoneNumber)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MyBulterTableViewController {
    fileprivate func showAlertTitle(_ title: String) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: title, style: .destructive, handler: { (action) in
            if title == changeBulter {
            self.performSegue(withIdentifier: R.segue.myBulterTableViewController.showBindBulterVC, sender: nil)
            } else {
                if let text = self.phoneLabel.text {
                    let callString = NSString(format: "tel:%@", text)
                    if let url = URL(string: callString as String) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }))
        vc.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler:nil ))
        self.present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MemberEditViewController {
                vc.butler = self.butler
        }
    }
}

extension MyBulterTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else if section == 1 {
            return 17
        } else if section == 2 {
            return 8
        } else {
            return CGFloat.leastNormalMagnitude
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

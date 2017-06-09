//
//  MemberDetailTableViewController.swift
//  Bank
//
//  Created by yang on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import URLNavigator
import PromiseKit
import MBProgressHUD

class MemberDetailTableViewController: UITableViewController {

    @IBOutlet fileprivate weak var remarkLabel: UILabel!
    @IBOutlet fileprivate weak var headImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var phoneLabel: UILabel!
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    @IBOutlet fileprivate weak var footView: UIView!
    @IBOutlet fileprivate weak var deleteButton: UIButton!
    
    var selectedMember: Member?
    fileprivate var sectionCount: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = footView
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMemberData()
    }

    /**
     请求成员详情
     */
    func requestMemberData() {
        MBProgressHUD.loading(view: view)
        let param = MemberParameter()
        param.memberID = selectedMember?.memberID
        let req: Promise<MemberDetailData> = handleRequest(Router.endpoint( MemberPath.detail, param: param))
        req.then { value -> Void in
            if value.isValid {
                if let data = value.data {
                    self.selectedMember = data
                    self.setMemberData(data)
                }
            }
        }.always {
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)

            }
        }
    }
    
    /// 设置详细信息
    func setMemberData(_ data: Member) {
        if let avatarURL = data.imageURL {
            headImageView.kf.setImage(with: avatarURL)
        }
        if let status = data.status {
            if status == .activated {
                titleLabel.text = "\(data.nickName)"
            } else if status == .invited {
                // 邀请中
                titleLabel.text = "\(data.nickName)"
                deleteButton.setTitleColor(UIColor.black, for: UIControlState())
                deleteButton.backgroundColor = UIColor.white
            }
        }
        phoneLabel.text = data.mobile.replaceWith(range: NSRange(location: 3, length: 4))
//        let point = Int(data.point)
        var point = data.point.numberToString()
        point.append("积分")
        pointLabel.text = point
        remarkLabel.text = data.remark
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editVC = segue.destination as? MemberEditViewController else {
            return
        }
        editVC.member = selectedMember
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MemberDetailTableViewController {
    
    /// 邀请激活
    @IBAction func activeAction(_ sender: UIButton) {
        sender.isEnabled = false
        let param = MemberParameter()
        if let selectedMember = selectedMember {
            param.memberID = selectedMember.memberID
        }
        let req: Promise<BaseResponseData> = handleRequest(Router.endpoint( MemberPath.reInvite, param: param))
        req.then { value -> Void in
            if value.isValid {
                Navigator.showAlertWithoutAction(R.string.localizable.alertTitle_tip(), message: "邀请发送成功", cancelButton: R.string.localizable.alertTitle_cancel())
            }
            }.always {
                sender.isEnabled = true
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    ///删除成员
    @IBAction func deleteAction(_ sender: UIButton) {
        sender.isEnabled = false
        let alert = UIAlertController(title: "是否删除该成员", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.requestPayPassData()
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        sender.isEnabled = true
    }
    
    /// 输入支付密码
    func requestPayPassData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.resultHandle = { [weak self] (result, pass) in
                switch result {
                case .passed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.requestDeleteData()
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
    
    /// 删除成员
    func requestDeleteData() {
        let hud = MBProgressHUD.loading(view: view)
        let param = MemberParameter()
        if let selectedMember = selectedMember {
            param.memberID = selectedMember.memberID
        }
        let req: Promise<BaseResponseData> = handleRequest(Router.endpoint( MemberPath.delete, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let view = self.navigationController?.view {
                    MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_delete_sucess())
                }
                _ = self.navigationController?.popViewController(animated: true)
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

extension MemberDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if selectedMember?.status == .activated {
                return 0.001
            } else {
                return 50
            }
        } else if indexPath.section == 2 {
            if selectedMember?.status == .invited || selectedMember?.status == .refused {
                return 0.001
            } else {
                return 100
            }
        }
        return 100
    }
}

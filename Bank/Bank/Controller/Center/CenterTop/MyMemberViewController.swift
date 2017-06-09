//
//  MyMemberViewController.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import URLNavigator
import PromiseKit
import MBProgressHUD

class MyMemberViewController: BaseViewController {

    @IBOutlet weak fileprivate var footerView: UIView!
    @IBOutlet weak fileprivate var bannerImageView: UIImageView!
    @IBOutlet weak fileprivate var myMemberTable: UITableView!
    @IBOutlet weak fileprivate var pointLabel: UILabel!
    @IBOutlet weak fileprivate var numberLabel: UILabel!
    fileprivate var memberList = [Member]()
    fileprivate var selectedMember: Member?
    fileprivate var point: Float = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        myMemberTable.dataSource = self
        myMemberTable.delegate = self
        myMemberTable.rowHeight = UITableViewAutomaticDimension
        myMemberTable.register(R.nib.myMemberTableViewCell)
        myMemberTable.tableFooterView = footerView
        myMemberTable.configBackgroundView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMemberData()
    }
    
    func requestMemberData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<MemberListData> = handleRequest(Router.endpoint( MemberPath.list, param: nil))
        req.then { value -> Void in
            if value.isValid {
                self.configUI(value)
            }
        }.always {
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
        
    }
    
    func configUI(_ value: MemberListData) {
        if let items = value.data?.items {
            self.memberList = items
            myMemberTable.reloadData()
        }
        if let members = value.data?.totalItems {
            self.numberLabel.text = "现有成员数：\(members)名"
        }
        if let point = value.data?.totalPoint {
            self.pointLabel.amountWithUnit(Float(point), color: UIColor.white, amountFontSize: 20, unitFontSize: 15, unit: "积分")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlerTitle() {
        let alertVC = UIAlertController(title: nil, message: "您的邀请人数已达上限！您可以删除成员后继续操作", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
   
    @IBAction func memberDescriptions(_ sender: AnyObject) {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {return}
        vc.tag = HelpCenterTag.member
        Navigator.push(vc)
    }
    @IBAction func addMemberHandle(_ sender: AnyObject) {
        if memberList.count >= 3 {
            showAlerTitle()
        } else {
            self.performSegue(withIdentifier: R.segue.myMemberViewController.showAddNewMembeVC, sender: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension MyMemberViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell: MyMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.myMemberTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        if !memberList.isEmpty {
            cell.conforInfo(memberList[indexPath.row])
        }
        
        //邀请激活
        cell.activeActionHandleBlock = {
            let param = MemberParameter()
            param.memberID = self.memberList[indexPath.row].memberID
            let req: Promise<BaseResponseData> = handleRequest(Router.endpoint( MemberPath.reInvite, param: param))
            req.then { value -> Void in
                if value.isValid {
                    Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_invite_success())
                }
                }.catch { error in
                    if let err = error as? AppError {
                         MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyMemberViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      selectedMember = memberList[indexPath.row]
      self.performSegue(withIdentifier: R.segue.myMemberViewController.memberDetailsSegueID, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            guard let memberDetailVC = segue.destination as? MemberDetailTableViewController else {return}
            memberDetailVC.selectedMember = self.selectedMember
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

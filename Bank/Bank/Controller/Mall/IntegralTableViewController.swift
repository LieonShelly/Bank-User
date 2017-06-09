//
//  IntegralTableViewController.swift
//  Bank
//
//  Created by yang on 16/1/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import Device

class IntegralTableViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var headView: UIView!
    @IBOutlet fileprivate weak var exchangeIntegralButton: UIButton!
    @IBOutlet fileprivate weak var totalIntTipLabel: UILabel!
    @IBOutlet fileprivate weak var totalIntegralLabel: UILabel!
    @IBOutlet weak fileprivate var myEventButton: TagButton!
    @IBOutlet weak fileprivate var myTaskButton: TagButton!
    @IBOutlet weak fileprivate var adverstButton: UIButton!
    @IBOutlet weak fileprivate var offlineEventButton: UIButton!
    @IBOutlet weak fileprivate var dailyTaskButton: UIButton!
    @IBOutlet weak fileprivate var lotteryButton: UIButton!
    @IBOutlet weak fileprivate var buyGoodsButton: UIButton!
    @IBOutlet weak fileprivate var addMemberButton: UIButton!
    @IBOutlet weak var checkInBarButtonItem: UIBarButtonItem!
    
    fileprivate var checkinView: MallHomeCheckInView?
    fileprivate var integerHomeData: IntegerHome?
    fileprivate var checkIn: Bool = false {
        didSet {
            self.checkInBarButtonItem.title = self.checkIn == true ? "已签到" : "签到"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
        adverstButton.imageView?.contentMode = .scaleAspectFill
        offlineEventButton.imageView?.contentMode = .scaleAspectFill
        dailyTaskButton.imageView?.contentMode = .scaleAspectFill
        lotteryButton.imageView?.contentMode = .scaleAspectFill
        buyGoodsButton.imageView?.contentMode = .scaleAspectFill
        addMemberButton.imageView?.contentMode = .scaleAspectFill
        setTableView()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ExchangeViewController {
            vc.totalPoint = integerHomeData?.totalPoint ?? 0
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == R.segue.integralTableViewController.showMyTaskVC.identifier ||
            identifier == R.segue.integralTableViewController.showMyEventVC.identifier ||
            identifier == R.segue.integralTableViewController.showIntegralDetailVC.identifier ||
            identifier == R.segue.integralTableViewController.showLotteryVC.identifier) &&
            !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return false
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
        let value = AppConfig.shared.isUserSigned
        // 只有信用会员才显示添加成员的banner
        if value == false {
            addMemberButton.isHidden = true
        } else {
            addMemberButton.isHidden = false
        }
        totalIntegralLabel.isHidden = !AppConfig.shared.isLoginFlag
        totalIntTipLabel.isHidden = totalIntegralLabel.isHidden
        if AppConfig.shared.isLoginFlag {
            exchangeIntegralButton.setTitle(R.string.localizable.point_home_button_exchange())
        } else {
            exchangeIntegralButton.setTitle(R.string.localizable.point_home_button_login())
        }
    }
    
    /// 设置表
    fileprivate func setTableView() {
        headView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 150)
        tableView.tableHeaderView = headView
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
    }
    
    /// 请求积分宝数据
    fileprivate func requestData() {
//        MBProgressHUD.loading(view: view)
        let req: Promise<IntegerHomeData> = handleRequest(Router.endpoint( MallPath.pointEarnHome, param: nil))
        req.then { (value) -> Void in
            self.integerHomeData = value.data
            if let checkin = value.data?.isCheckedIn {
                self.checkIn = checkin
            }
            self.setUI(value.data)
        }.always {
//            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
//            if let err = error as? AppError {
//                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
//            }
        }
    }
    
    func setUI(_ data: IntegerHome?) {
        guard let data = data else {
            return
        }
        totalIntegralLabel.text = String(data.totalPoint)
        if data.taskNumber != 0 {
            let number = data.taskNumber > 99 ? 99 : data.taskNumber
            myTaskButton.tagView?.isHidden = false
            myTaskButton.tagView?.setTitle(String(number), for: UIControlState())
        } else {
            myTaskButton.tagView?.isHidden = true
        }
        if data.eventNumber != 0 {
            let number = data.eventNumber > 99 ? 99 : data.eventNumber
            myEventButton.tagView?.isHidden = false
            myEventButton.tagView?.setTitle(String(number), for: UIControlState())
        } else {
            myEventButton.tagView?.isHidden = true
        }
    }
    
    /// 购买商品
    ///
    /// - Parameter sender: 按钮
    @IBAction func gotoMallAction(_ sender: UIButton) {
        if let tab = self.tabBarController, let controllers = tab.viewControllers {
            guard let nav = controllers[2] as? UINavigationController else {
                return
            }
            nav.popToRootViewController(animated: false)
            self.tabBarController?.selectedViewController = nav
        }
    }
    
    /// 跳转兑换积分页面
    ///
    /// - Parameter sender: 按钮
    @IBAction func gotoExchangeAction(_ sender: UIButton) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        if integerHomeData?.isExchange == true {
            performSegue(withIdentifier: R.segue.integralTableViewController.showExchangeVC, sender: nil)
        } else {
            showAlertController(R.string.localizable.alertTitle_cant_rerlect())
        }
    }
    
    /// 添加成员
    ///
    /// - Parameter sender: 按钮
    @IBAction func addMemberAction(_ sender: UIButton) {
        guard let vc = R.storyboard.myMember.addMemberViewController() else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showAlertController(_ message: String) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            //跳转到我的信用页面
            guard let vc = R.storyboard.credit.myCreditViewController() else {
                return
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// 签到
    @IBAction func checkInAction(_ sender: UIBarButtonItem) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        sender.isEnabled = false
        if self.checkIn == true {
            MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_register_today_success())
            sender.isEnabled = true
        } else {
            MBProgressHUD.loading(view: view)
            let req: Promise<CheckInData> = handleRequest(Router.endpoint( MallPath.checkIn, param: nil))
            req.then {(value) -> Void in
                sender.isEnabled = true
                if self.checkinView == nil {
                    self.checkinView = R.nib.mallHomeCheckInView.firstView(owner: nil)
                    self.checkinView?.frame = UIScreen.main.bounds
                    if let checkView = self.checkinView {
                        self.tabBarController?.view.addSubview(checkView)
                    }
                }
                self.checkinView?.configInfo(value.data?.point)
                self.checkinView?.deleteHandleBlock = {
                    self.checkinView?.removeFromSuperview()
                }
                self.checkIn = true
                }.always {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }.catch { (error) in
                    if let err = error as? AppError {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if Device.size() == .screen5_5Inch && section == 0 {
            return 9.0
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 9.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

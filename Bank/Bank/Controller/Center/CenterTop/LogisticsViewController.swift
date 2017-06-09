//
//  LogisticsViewController.swift
//  Bank
//
//  Created by 杨锐 on 16/8/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class LogisticsViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var logisticsNameLabel: UILabel!
    @IBOutlet fileprivate weak var logisticsNumLabel: UILabel!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate var headerView: UIView!
    fileprivate var trackArray: [Track] = []
    fileprivate var logistics: Logistics?
    fileprivate var protorypeCell: LogisticsTableViewCell?
    var orderID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.center_myorder_logistics_title()
        requestLogisticsData()
        setTableView()
        protorypeCell = tableView.dequeueReusableCell(withIdentifier: R.nib.logisticsTableViewCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.logisticsTableViewCell)
        tableView.tableHeaderView = headerView
    }
    
    fileprivate func requestLogisticsData() {
        MBProgressHUD.loading(view: view)
        let param = LogisticsParameter()
        guard let orderID = orderID else {return}
        param.orderID = Int(orderID)
        let req: Promise<LogisticsData> = handleRequest(Router.endpoint( LogisticsPath.tracks, param: param))
        req.then { (value) -> Void in
            self.logistics = value.data
            self.logisticsNameLabel.text = self.logistics?.company
            self.logisticsNumLabel.text = self.logistics?.logisticsNo
            if let array = value.data?.tracks {
                self.trackArray = array
                self.tableView.reloadData()            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

}

// MARK: - UITableViewDataSource
extension LogisticsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: LogisticsTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.logisticsTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            if trackArray.count == 1 {
                cell.position = .one
            } else {
                cell.position = .top
            }
            
        } else {
            if indexPath.row == trackArray.count - 1 {
                cell.position = .bottom
            } else {
                cell.position = .center
            }
        }
        cell.configInfo(trackArray[indexPath.row])
        cell.clickHanleBlock = { [weak self] tel in
            self?.setTelAlertViewController(tel)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LogisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf7f7f7)
        let label = UILabel()
        label.text = R.string.localizable.label_title_logistics_tracking()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(hex: 0x4d4d4d)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-9)
            make.left.equalTo(view).offset(17)
        }
        let topLineView = UIView()
        view.addSubview(topLineView)
        topLineView.backgroundColor = UIColor(hex: 0xe5e5e5)
        topLineView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(0)
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.height.equalTo(0.7)
        }
        let buttomLineView = UIView()
        view.addSubview(buttomLineView)
        buttomLineView.backgroundColor = UIColor(hex: 0xe5e5e5)
        buttomLineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(0)
            make.left.equalTo(view).offset(0)
            make.right.equalTo(view).offset(0)
            make.height.equalTo(0.7)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

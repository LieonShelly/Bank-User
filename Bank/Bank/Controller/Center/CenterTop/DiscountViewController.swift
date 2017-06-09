//
//  DiscountViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/13.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class DiscountViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var merchantID: String?
    var dismissHandleBlock: (() -> Void)?
    
    fileprivate var discountList: [Discount] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        setTableView()
        requestRuleList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 设置UITableView
    private func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(R.nib.discountTableViewCell)
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        if let block = dismissHandleBlock {
            block()
        }
    }

}

// MARK: - Request
extension DiscountViewController {
    
    /// 请求优惠列表
    func requestRuleList() {
        MBProgressHUD.loading(view: view)
        let param = DiscountParameter()
        if let id = merchantID {
            param.merchantID = Int(id)
        }
        let req: Promise<DiscountRuleListData> = handleRequest(Router.endpoint( DiscountPath.ruleList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.ruleList {
                self.discountList = items
            }
            self.tableView.reloadData()
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
extension DiscountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.discountTableViewCell) else {
            return UITableViewCell()
        }
        cell.configInfo(discount: discountList[indexPath.row])
        cell.openHandleBlock = { isOpen in
            self.discountList[indexPath.row].isOpen = isOpen
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        return cell
        
    }
}

// MARK: - UITableViewDelegate
extension DiscountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

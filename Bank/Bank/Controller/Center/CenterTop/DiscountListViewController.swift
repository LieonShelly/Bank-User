//
//  DiscountListViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import PullToRefresh
import MBProgressHUD

class DiscountListViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    var pushSourceIsPay = false
    fileprivate var discountList: [[Discount]] = []
    fileprivate var itemsArray: [Discount] = []
    fileprivate var currentPage: Int = 1
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .discount)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        title = R.string.localizable.center_discount_list_title()
        setTableView()
        requestListData()
        addPullToRefresh()
        setLeftBarButton()
    }
    
    deinit {
        if let tableView = tableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestListData(page: (self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestListData()
        }
    }

    override func leftAction() {
        if pushSourceIsPay {
            _ = navigationController?.popToRootViewController(animated: false)
            self.tabBarController?.selectedIndex = 3
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.rowHeight = 150
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.discountListTableViewCell)
        tableView.separatorStyle = .none
    }
    
    /// 按照月份重新设置数组
    fileprivate func resetArray(array: [Discount]) {
        discountList.removeAll()
        var date: String?
        var monthData: [Discount] = []
        if !array.isEmpty {
            date = array[0].payTime?.toString("yyyy-MM")
        }
        for index in 0..<array.count {
            let discount = array[index]
            let payDate = discount.payTime?.toString("yyyy-MM")
            if date == payDate {
                monthData.append(discount)
                if index == array.count - 1 {
                    discountList.append(monthData)
                }
            } else {
                date = payDate
                discountList.append(monthData)
                monthData.removeAll()
                monthData.append(discount)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - Request
extension DiscountListViewController {
    
    /// 请求列表数据
    fileprivate func requestListData(page: Int = 1) {
        MBProgressHUD.loading(view: view)
        let param = DiscountParameter()
        param.page = page
        param.perpage = 20
        let req: Promise<DiscountListData> = handleRequest(Router.endpoint( DiscountPath.orderList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.itemsArray = items
                } else {
                    self.itemsArray.append(contentsOf: items)
                }
                if self.itemsArray.isEmpty {
                    self.tableView.addSubview(self.noneView)
                } else {
                    self.noneView.removeFromSuperview()
                    self.resetArray(array: self.itemsArray)
                }
            }
            }.always {
                self.tableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: - UITableViewDataSource
extension DiscountListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return discountList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = discountList[section]
        return item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.discountListTableViewCell) else {
            return UITableViewCell()
        }
        let items = discountList[indexPath.section]
        let item = items[indexPath.row]
        if items.count == indexPath.row + 1 {
            cell.bottomHeight.constant = 0
        } else {
            cell.bottomHeight.constant = 10
        }
        cell.configInfo(discount: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let items = discountList[section]
        if !items.isEmpty {
            return items[0].payTime?.toString("yyyy年MM月")
        } else {
            return nil
        }
    }

}

// MARK: - UITableViewDelegate
extension DiscountListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
}

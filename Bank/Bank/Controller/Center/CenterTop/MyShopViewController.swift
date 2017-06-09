//
//  MyShopViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class MyShopViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeInfoLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!
    
    fileprivate var myStore: MyStore?
    fileprivate var awardList: [Award] = []
    fileprivate var currentPage: Int = 1
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.center_myshop_title()
        setTableView()
        requestMyShopData()
        addPullToRefresh()
        // Do any additional setup after loading the view.
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
            self?.requestMyShopData(page: (self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestMyShopData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headerView
        tableView.rowHeight = 70
        tableView.register(R.nib.awardRecordTableViewCell)
    }
    
    fileprivate func setHeaderView() {
        logoImageView.setImage(with: myStore?.storeLogo, placeholderImage: R.image.image_default_small())
        storeNameLabel.text = myStore?.storeName
        storeInfoLabel.text = myStore?.storeDetail
        staffLabel.text = myStore?.permissionLevel.name
    }
    
    /// 店员解绑
    @IBAction func unwrapAction(_ sender: UIButton) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_myshop_unwrap(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { [weak self] (action) in
            self?.requestUnwrapData()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension MyShopViewController {
    
    /// 请求我的店铺数据
    fileprivate func requestMyShopData(page: Int = 1) {
        let param = UserParameter()
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<MyShopData> = handleRequest(Router.endpoint(UserPath.myStore, param: param))
        req.then { (value) -> Void in
            self.myStore = value.data
            if let items = value.data?.awardList?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.awardList = items
                } else {
                    self.awardList.append(contentsOf: items)
                }
            }
            self.setHeaderView()
            self.tableView.reloadData()
            if self.awardList.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
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
    
    /// 请求店员解绑
    fileprivate func requestUnwrapData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.unwrap, param: nil))
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

// MARK: - UITableViewDataSource
extension MyShopViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return awardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.awardRecordTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(award: awardList[indexPath.row])
        return cell
    }

}

// MARK: - UITableViewDelegate
extension MyShopViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 35))
        label.text = "我的打赏记录"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = UIColor(hex: 0x666666)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}

//
//  ShopListViewController.swift
//  Bank
//
//  Created by yang on 16/5/31.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class ShopListViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    var goodsID: String?
    fileprivate var storeList: [Store] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        requestList()
        setTableView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTableView() {
        tableView.configBackgroundView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.shopAddressTableViewCell)
    }
    
    /**
     请求分店列表
     */
    func requestList() {
        MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.goodsID = goodsID
        let req: Promise<StoreListData> = handleRequest(Router.endpoint( GoodsPath.storeList, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let array = value.data?.storeList {
                    self.storeList = array
                    self.tableView.reloadData()
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
}

extension ShopListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ShopAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.shopAddressTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(storeList[indexPath.row])
        cell.telHandleBlock = { [weak self] tel in
            self?.setTelAlertViewController(tel)
        }
        return cell
    }
}

extension ShopListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}

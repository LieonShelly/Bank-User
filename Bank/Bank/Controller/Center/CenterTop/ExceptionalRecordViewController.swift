//
//  exceptionalRecordViewController.swift
//  Bank
//
//  Created by 糖otk on 2017/1/11.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class ExceptionalRecordViewController: BaseViewController {

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = UIScreen.main.bounds
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.register(R.nib.awardRecordTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()

        return tableView
    }()
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    fileprivate var awardList: [Award] = []
    fileprivate var currentPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.tableView)
        title = "打赏记录"
        addPullToRefresh()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        requestMyShopData(page: 1)
    }
    
    deinit {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
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
}

extension ExceptionalRecordViewController {
    /// 请求我的店铺数据
    fileprivate func requestMyShopData(page: Int = 1) {
        let param = UserParameter()
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<MyShopData> = handleRequest(Router.endpoint(UserPath.myStore, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.awardList?.items, !items.isEmpty {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.awardList = items
                } else {
                    self.awardList.append(contentsOf: items)
                }
            }
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
    
}

extension ExceptionalRecordViewController: UITableViewDataSource {
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

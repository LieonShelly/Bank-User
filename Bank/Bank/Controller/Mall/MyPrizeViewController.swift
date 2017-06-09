//
//  MyPrizeViewController.swift
//  Bank
//
//  Created by yang on 16/7/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PullToRefresh
import URLNavigator
import PromiseKit
import MBProgressHUD

class MyPrizeViewController: BaseViewController {

    @IBOutlet weak fileprivate var tableView: UITableView!
    
    fileprivate lazy var nonePrizeView: NoneView = { return NoneView(frame: self.view.bounds, type: .prize) }()
    fileprivate var currentPage: Int = 1
    fileprivate var prizeList: [Prize] = []
    fileprivate var lastPrizeList: [Prize] = []
    fileprivate var selectedPrize: Prize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        addPullToRefresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MyPrizeDetailViewController {
            vc.userListID = self.selectedPrize?.userListID
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isReload = currentPage == 1 ? false : true
        requestListData(currentPage, isReload: isReload)
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
            self?.requestListData((self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestListData()
        }
    }
    
    /// 设置UITableView的相关属性
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.rowHeight = 160
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.myPrizeTableViewCell)
        tableView.separatorStyle = .none
    }
    
    /// 请求我的奖品数据
    fileprivate func requestListData(_ page: Int = 1, isReload: Bool = false) {
        let param = GiftParameter()
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<PrizeListData> = handleRequest(Router.endpoint( GiftPath.myGiftList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.prizeList = items
                } else {
                    if isReload == false {
                        self.lastPrizeList = self.prizeList
                    } else {
                        self.prizeList = self.lastPrizeList
                    }
                    self.prizeList.append(contentsOf: items)
                }
                if self.prizeList.isEmpty {
                    self.tableView.addSubview(self.nonePrizeView)
                } else {
                    self.nonePrizeView.removeFromSuperview()
                    self.tableView.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: UITableViewDataSource
extension MyPrizeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prizeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyPrizeTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.myPrizeTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(prizeList[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension MyPrizeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPrize = prizeList[indexPath.row]
        if selectedPrize?.type == .point {
            _ = self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.performSegue(withIdentifier: R.segue.myPrizeViewController.showMyPrizeDetailVC, sender: nil)
        }
        
    }
}

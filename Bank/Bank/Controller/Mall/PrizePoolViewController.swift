//
//  PrizePoolViewController.swift
//  Bank
//
//  Created by yang on 16/6/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PullToRefresh
import URLNavigator
import PromiseKit
import MBProgressHUD

class PrizePoolViewController: BaseViewController {

    @IBOutlet weak fileprivate var tableView: UITableView!
    fileprivate var currentPage: Int = 0
    fileprivate var prizeList: [Prize] = []
    fileprivate var selectedPrize: Prize?
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestListData()
        setTableView()
        addPullToRefresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PrizeDetailViewController {
            vc.giftID = selectedPrize?.prizeID
        }
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
 
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 100
        tableView.register(R.nib.prizeTableViewCell)
    }
    
    fileprivate func requestListData(_ page: Int = 1) {
        let param = GiftParameter()
        param.page = page
        param.perPage = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<PrizeListData> = handleRequest(Router.endpoint( GiftPath.poolList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.prizeList = items
                } else {
                    self.prizeList.append(contentsOf: items)
                }
                self.tableView.reloadData()
            }
            if self.prizeList.isEmpty {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: UITableViewDataSource
extension PrizePoolViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prizeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PrizeTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.prizeTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(prizeList[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension PrizePoolViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPrize = prizeList[indexPath.row]
        self.performSegue(withIdentifier: R.segue.prizePoolViewController.showPrizeDetailVC, sender: nil)
    }
}

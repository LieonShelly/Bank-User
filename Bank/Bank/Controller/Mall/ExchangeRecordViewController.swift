//
//  ExchangeRecordViewController.swift
//  Bank
//
//  Created by kilrae on 2017/4/27.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import MBProgressHUD
import PullToRefresh

class ExchangeRecordViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataSoruce: [PointObject] = []
    fileprivate var selectedRecord: PointObject?
    fileprivate var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        requestRecordData()
        addPullToRefresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ExchangeDetailTableViewController {
            vc.redeemID = selectedRecord?.redeemID
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        if let tableView = tableView {
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.register(R.nib.exchangeRecordTableViewCell)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func addPullToRefresh() {
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestRecordData(page: (self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
    }

}

// MARK: - Request

extension ExchangeRecordViewController {
    fileprivate func requestRecordData(page: Int = 1) {
        let hud = MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.page = page
        param.perPage = 20
        let req: Promise<PointObjectListData> = handleRequest(Router.endpoint( MallPath.pointRedeemList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.dataSoruce = items
                } else {
                    self.dataSoruce.append(contentsOf: items)
                }
                self.tableView.reloadData()
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ExchangeRecordViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSoruce.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.exchangeRecordTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(data: dataSoruce[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRecord = dataSoruce[indexPath.row]
        self.performSegue(withIdentifier: R.segue.exchangeRecordViewController.showExchangeDetailVC, sender: nil)
    }
}

//
//  MyAwardViewController.swift
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

class MyAwardViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var currentPage: Int = 1
    fileprivate var awardList: [Award] = []
    fileprivate var lastAwardList: [Award] = []
    fileprivate var selectedAward: Award?
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .reward)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        title = R.string.localizable.center_myaward_title()
        setTableView()
        addPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isReload = currentPage == 1 ? false : true
        requesetMyAwardData(page: currentPage, isReload: isReload)
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
            self?.requesetMyAwardData(page: (self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requesetMyAwardData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RewardDetailViewController {
            vc.awardID = selectedAward?.awardID
        }
        if let vc = segue.destination as? RewardViewController {
            vc.awardID = selectedAward?.awardID
        }
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.rowHeight = 165
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.myAwardTableViewCell)
        tableView.separatorStyle = .none
    }
    
    /// 请求打赏列表
    fileprivate func requesetMyAwardData(page: Int = 1, isReload: Bool = false) {
        let param = AwardParameter()
        param.page = page
        param.pageSize = 20
        MBProgressHUD.loading(view: view)
        let req: Promise<AwardListData> = handleRequest(Router.endpoint( AwardPath.userList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.awardList = items
                } else {
                    if isReload == false {
                        self.lastAwardList = self.awardList
                    } else {
                        self.awardList = self.lastAwardList
                    }
                    self.awardList.append(contentsOf: items)
                }
                if self.awardList.isEmpty {
                    self.tableView.tableFooterView = self.noneView
                } else {
                    self.tableView.tableFooterView = UIView()
                }
            }
            self.tableView.reloadData()
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
extension MyAwardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return awardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.myAwardTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(award: awardList[indexPath.row])
        cell.buttonHandleBlock = { [weak self] in
            self?.selectedAward = self?.awardList[indexPath.row]
            if self?.awardList[indexPath.row].awardStatus == .notAward {
                self?.performSegue(withIdentifier: R.segue.myAwardViewController.showRewardVC, sender: nil)
            }
            if self?.awardList[indexPath.row].awardStatus == .awarded {
                self?.performSegue(withIdentifier: R.segue.myAwardViewController.showRewardDetailVC, sender: nil)
            }
        }
        return cell
    }
}

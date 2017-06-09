//
//  BankAnnounceViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import PullToRefresh
import MBProgressHUD

class BankAnnounceViewController: BaseTableViewController {
    
    fileprivate var currentPage: Int = 0
    fileprivate var topRefresh = PullToRefresh(position: .top)
    fileprivate var bottomRefresh = PullToRefresh(position: .bottom)
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    fileprivate var datas: [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
        tableView.register(R.nib.bankAnnounceCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestData()
        }
        requestData()
    }
    
    deinit {
        if let tableView = tableView {
            if let refresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(refresh)
            }
            if let refresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(refresh)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate func addInfinite() {
        tableView.addPullToRefresh(bottomRefresh) { [weak self] (_) -> Void in
            self?.requestData(self?.currentPage ?? 1 + 1)
        }
    }
    
    func requestData(_ page: Int = 1) {
        let param = NewsParameter()
        param.type = NewsType.bankHeadline.rawValue
        param.page = page
        param.isHotOnly = false
        let req: Promise<NewsListData> = handleRequest(Router.endpoint(endpoint: NewsPath.list, param: param))
        req.then { value -> Void in
            if let items = value.data?.items, !items.isEmpty {
                self.currentPage = page
                if self.currentPage == 1 {
                    self.datas = items
                    self.tableView.endRefreshing(at: .top)
                } else {
                    self.datas.append(contentsOf: items)
                    self.tableView.endRefreshing(at: .bottom)
                }
                if self.datas.count > 20 {
                    self.addInfinite()
                } else {
                    self.tableView.removePullToRefresh(self.bottomRefresh)
                }
                self.tableView.reloadData()
            }
            if self.datas.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { _ in }
    }
    
}

extension BankAnnounceViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.bankAnnounceCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configData(datas[indexPath.section])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
}

extension BankAnnounceViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section < datas.count {
            let news = datas[indexPath.section]
            if let vc = R.storyboard.news.newsDetailsViewController() {
                vc.newsID = news.newsID
                vc.title = R.string.localizable.controller_title_public_details()
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

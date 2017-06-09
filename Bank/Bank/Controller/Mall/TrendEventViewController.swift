//
//  TrendEventViewController.swift
//  Bank
//
//  Created by yang on 16/1/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class TrendEventViewController: BaseViewController {

    @IBOutlet weak fileprivate var trendEventTableView: UITableView!
    fileprivate var onlineEvents: [OnlineEvent] = []
    fileprivate var selectedEvent: OnlineEvent?
    fileprivate var currentPage: Int = 1
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.trendEventTableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setTableView()
        requestData()
        addPullToRefresh()
    }
    
    deinit {
        if let tableView = trendEventTableView {
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
        trendEventTableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestData((self?.currentPage ?? 1) + 1)
            self?.trendEventTableView.endRefreshing(at: .bottom)
        }
        trendEventTableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestData()
        }
    }
    
    func setTableView() {
        trendEventTableView.register(R.nib.trendEventGoodsTableViewCell)
        trendEventTableView.configBackgroundView()
        trendEventTableView.tableFooterView = UIView()
    }
    
    func requestData(_ page: Int = 1) {
        MBProgressHUD.loading(view: view)
        let param = OnlineEventParameter()
        param.page = page
        param.perPage = 20
        let req: Promise<EventListData> = handleRequest(Router.endpoint( OnlineEventPath.list, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let events = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.onlineEvents = events
                    } else {
                        self.onlineEvents.append(contentsOf: events)
                    }
                    self.trendEventTableView.reloadData()
                }
            }
            if self.onlineEvents.isEmpty {
                self.trendEventTableView.tableFooterView = self.noneView
            } else {
                self.trendEventTableView.tableFooterView = UIView()
            }
        }.always {
            self.trendEventTableView.endRefreshing(at: .top)
            MBProgressHUD.hide(for: self.view, animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SalesGoodsViewController {
            vc.eventID = self.selectedEvent?.eventID
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TrendEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return onlineEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.trendEventGoodsTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(onlineEvents[indexPath.section])
        return cell
    }

}

extension TrendEventViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = onlineEvents[indexPath.section]
        self.performSegue(withIdentifier: R.segue.trendEventViewController.showSalesVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 9
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}

//
//  IntegralDetailViewController.swift
//  Bank
//
//  Created by yang on 16/1/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class IntegralDetailViewController: BaseViewController {
    
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var titleView: UIView!
    @IBOutlet fileprivate var titleButtons: [UIButton]!
    @IBOutlet weak fileprivate var lineView: UIView!
    
    fileprivate var selectedButton: UIButton?
    fileprivate var titleArray: [String] = ["本周", "本月", "近三月"]
    fileprivate var nowTime: Date = Date()
    fileprivate var startTime: Date?
    fileprivate let totalTime = Date().timeIntervalSince1970
    fileprivate var currentPage: Int = 1
    fileprivate var pointList: [PointObject] = []
    fileprivate var lastPointList: [PointObject] = []
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleButtons()
        setTableView()
        addPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? RecordFilterViewController else {
            return
        }
        vc.dataType = .point
        vc.title = R.string.localizable.controller_title_point_detail()
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
            _ = self?.getStartTime()
            self?.requestData((self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            _ = self?.getStartTime()
            self?.requestData()
        }
    }

    fileprivate func setTitleButtons() {
        for button in titleButtons {
            button.setTitleColor(UIColor(hex: 0x00a8fe), for: .selected)
            button.setTitleColor(UIColor(hex: 0x666666), for: UIControlState())
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            if button.tag == 0 {
                selectedButton = button
                selectedButton?.isSelected = true
                _ = getStartTime()
                requestData()
            }
        }
    }
    
    @objc fileprivate func buttonAction(_ sender: UIButton) {
        if sender.tag != selectedButton?.tag {
            selectedButton?.isSelected = false
            selectedButton = sender
            selectedButton?.isSelected = true
            _ = getStartTime()
            requestData()
            UIView.animate(withDuration: 0.3, animations: {
                self.lineView.frame = CGRect(x: sender.frame.origin.x, y: self.lineView.frame.origin.y, width: self.lineView.frame.width, height: self.lineView.frame.height)
            })
        }
    }
    
    //获取开始的时间
    fileprivate func getStartTime() -> Date? {
        if let tag = selectedButton?.tag {
            switch tag {
            case 0:
                startTime = Date(timeIntervalSince1970: totalTime - 60 * 60 * 24 * 7)
            case 1:
                startTime = Date(timeIntervalSince1970: totalTime - 60 * 60 * 24 * 30)
            case 2:
                startTime = Date(timeIntervalSince1970: totalTime - 60 * 60 * 24 * 90)
            default:
                break
            }
            
        }
        return startTime
    }
    
    fileprivate func setTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.integralDetailMenuTableViewCell)
        tableView.configBackgroundView()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //请求数据
    fileprivate func requestData(_ page: Int = 1) {
        let hud = MBProgressHUD.loading(view: view)
        let param = MallParameter()
        param.page = page
        param.startTime = startTime
        param.endTime = nowTime
        param.perPage = 20
        let req: Promise<PointObjectListData> = handleRequest(Router.endpoint( MallPath.pointEarnList, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.pointList = items
                    } else {
                        self.pointList.append(contentsOf: items)
                    }
                    self.tableView.reloadData()
                }
            }
            if self.pointList.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            }.always {
                self.tableView.endRefreshing(at: .top)
                self.tableView.endRefreshing(at: .bottom)
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: - UITableViewDataSource
extension IntegralDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: IntegralDetailMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.integralDetailMenuTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.conforInfo(pointList[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension IntegralDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

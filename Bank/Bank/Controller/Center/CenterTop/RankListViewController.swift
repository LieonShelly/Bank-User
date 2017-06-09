//
//  RankListViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class RankListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet var buttons: [UIButton]!
    
    fileprivate var selectedButton: UIButton?
    fileprivate var rankList: [AwardRank] = []
    fileprivate var rankListType: RankListType = .rich
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .other)}()
    
    fileprivate lazy var date: Date = {
        let today = Date()
        let day = today.add(components: DateComponents(month: -1))
        return day
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        title = R.string.localizable.center_myaward_ranklist_title()
        setTableView()
        setTitleButton()
        requestRankListData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.register(R.nib.rankListTableViewCell)
    }
    
    fileprivate func setTitleButton() {
        for button in buttons {
            button.setTitleColor(UIColor(hex: 0x666666), for: .normal)
            button.setTitleColor(UIColor(hex: 0x00a8fe), for: .selected)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            if button.tag == 0 {
                selectedButton = button
                selectedButton?.isSelected = true
            }
        }
    }
    
    @objc fileprivate func buttonAction(_ sender: UIButton) {
        if sender.tag != selectedButton?.tag {
            selectedButton?.isSelected = false
            selectedButton = sender
            selectedButton?.isSelected = true
            UIView.animate(withDuration: 0.3) {
                self.lineView.frame = CGRect(x: sender.frame.origin.x, y: self.lineView.frame.origin.y, width: self.lineView.frame.width, height: 2)
            }
            if sender.tag == 0 {
                rankListType = .rich
            } else {
                rankListType = .bee
            }
            requestRankListData()
        }
    }

}

// MARK: - Request
extension RankListViewController {
    
    fileprivate func requestRankListData() {
        let param = AwardParameter()
        param.type = rankListType
        param.date = date
        MBProgressHUD.loading(view: view)
        let req: Promise<AwardRankListData> = handleRequest(Router.endpoint( AwardPath.rankList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.items {
                self.rankList = items
            }
            if self.rankList.isEmpty {
                self.tableView.tableFooterView = self.noneView
            } else {
                self.tableView.tableFooterView = UIView()
            }
            self.tableView.reloadData()
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
extension RankListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.rankListTableViewCell) else {
            return UITableViewCell()
        }
        cell.configInfo(data: rankList[indexPath.row])
        cell.noImageView.isHidden = false
        cell.noLabel.isHidden = true
        if indexPath.row == 0 {
            cell.noImageView.image = R.image.icon_no1()
        } else if indexPath.row == 1 {
            cell.noImageView.image = R.image.icon_no2()
        } else if indexPath.row == 2 {
            cell.noImageView.image = R.image.icon_no3()
        } else {
            cell.noImageView.isHidden = true
            cell.noLabel.isHidden = false
            cell.noLabel.text = String(indexPath.row + 1)
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension RankListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        titleLabel.text = date.toString("yyyy年MM月")
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = UIColor(hex: 0x666666)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor(hex: 0xf7f7f7)
        return titleLabel
    }
}

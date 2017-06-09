//
//  ChangeGoodsEventView.swift
//  Bank
//
//  Created by yang on 16/7/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

enum EventMode {
        /// 查看优惠
    case checkEvent
        /// 修改优惠
    case alertEvent
}
class ChangeGoodsEventView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var selectedEvent: OnlineEvent?
    var events: [OnlineEvent] = []
    var selectedEventID: String?
    var selectedHandleBlock: ((_ eventID: String) -> Void)?
    var eventMode: EventMode?
    override func awakeFromNib() {
        setTablView()
    }
    
    func setTablView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.shoppingGoodsEventTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
}

extension ChangeGoodsEventView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ShoppingGoodsEventTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.shoppingGoodsEventTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.eventMode = eventMode
        cell.configInfo(events[indexPath.row])
        if selectedEventID == events[indexPath.row].eventID {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
}

extension ChangeGoodsEventView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = events[indexPath.row]
        if let block = selectedHandleBlock {
            if let eventID = selectedEvent?.eventID {
                block(eventID)
            }
        }
    }
}

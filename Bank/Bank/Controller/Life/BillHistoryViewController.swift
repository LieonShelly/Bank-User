//
//  BillHistoryViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/23/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class BillHistoryViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
//    private var datas: [BillHistory] = BillHistory.popFakeData()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(R.nib.billHistoryTableViewCell)
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Table View Delegate
extension BillHistoryViewController: UITableViewDelegate {

}

// MARK: - Table View Data Source
extension BillHistoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.billHistoryTableViewCell)
//        cell.configBillHistory(datas[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//datas.count
    }
}

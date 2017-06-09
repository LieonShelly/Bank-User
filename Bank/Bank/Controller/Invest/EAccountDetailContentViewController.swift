//
//  EAccountDetailContentViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class EAccountDetailContentViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var datas: [AccountStatement] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(R.nib.accountDetailTableViewCell)
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension EAccountDetailContentViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.accountDetailTableViewCell, forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        cell.configData(datas[indexPath.row])
        
        return cell
    }
}

extension EAccountDetailContentViewController: UITableViewDelegate {
    
}

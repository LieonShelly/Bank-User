//
//  SetPayPasswordTableViewController.swift
//  Bank
//
//  Created by yang on 16/4/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class SetPayPasswordTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SetPayPasswordTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17.0
    }
}

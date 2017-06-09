//
//  MyLifeTableViewController.swift
//  Bank
//
//  Created by 糖otk on 2017/1/10.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MyLifeTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的生活"
        tableView.configBackgroundView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MyLifeTableViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 2 {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 9.0
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

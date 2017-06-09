//
//  AboutUsTableViewController.swift
//  Bank
//
//  Created by Mac on 15/11/25.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AboutUsTableViewController: BaseTableViewController {
    
    @IBOutlet private weak var pushTokenLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        pushTokenLabel.text = AppConfig.shared.pushToken
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AboutUsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 {
            var string = WebViewURL.doc.URL()
            string.append("?type=101")
            guard let vc = R.storyboard.main.helpViewController(),
                let aboutURL = URL(string: string) else { return }
            vc.title = R.string.localizable.controller_title_about_us()
            vc.loadURL(aboutURL)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

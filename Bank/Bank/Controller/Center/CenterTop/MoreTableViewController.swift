//
//  MoreTableViewController.swift
//  Bank
//
//  Created by yang on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit

class MoreTableViewController: BaseTableViewController {
    
    fileprivate var shareContent: ShareAppContent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        tableView.configBackgroundView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHelpVC" {
            var string = WebViewURL.doc.URL()
            string.append("?type=102")
            if let vc = segue.destination as? HelpViewController, let aboutURL = URL(string: string) {
                vc.title = "服务条款"
                vc.loadURL(aboutURL)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 17.0
        } else {
            return 10.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            guard let vc = R.storyboard.main.shareViewController() else {return}
            vc.sharePage = .inviteFriends
            vc.completeHandle = { [weak self] result in
                self?.dim(.out)
                self?.dismiss(animated: true, completion: nil)
            }
            dim(.in)
            present(vc, animated: true, completion: nil)
  
        }
    }
    
}

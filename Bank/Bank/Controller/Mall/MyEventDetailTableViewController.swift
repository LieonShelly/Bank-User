//
//  MyTaskDetailTableViewController.swift
//  Bank
//
//  Created by yang on 16/5/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class MyEventDetailTableViewController: BaseTableViewController {
    
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var codeImageView: UIImageView!
    @IBOutlet weak fileprivate var eventNumberLabel: UILabel!
    @IBOutlet weak fileprivate var startTimeLabel: UILabel!
    @IBOutlet weak fileprivate var appointEndTimeLabel: UILabel!
    @IBOutlet weak fileprivate var addressLabel: UILabel!
    @IBOutlet weak fileprivate var rewardTypeButton: UIButton!
    @IBOutlet weak fileprivate var rewardLabel: UILabel!
    @IBOutlet weak fileprivate var statusLabel: UILabel!
    
    var joinID: String?
    var event: OfflineEvent? {
        didSet {
            self.configUI()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configUI() {
        titleLabel.text = event?.title
        if let code = event?.qrcode {
            eventNumberLabel.text = code.couponString()
        }
        if let string = event?.qrcodeData {
            if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) {
                codeImageView.image = UIImage(data: data)

            }
            
        }
        if let startDate = event?.startTime, let endDate = event?.endTime {
            if startDate.year == endDate.year {
                var string = startDate.toString("MM/dd HH:mm")
                if !startDate.isSameDay(endDate) {
                    string.append(" - ")
                    string.append(endDate.toString("MM/dd HH:mm"))
                }
                startTimeLabel.text = string
            } else {
                var string = startDate.toString("yyyy/MM/dd HH:mm")
                string.append(" - ")
                string.append(endDate.toString("yyyy/MM/dd HH:mm"))
                startTimeLabel.text = string
            }
        }
        if let startDate = event?.appointmentStartTime, let endDate = event?.appointmentEndTime {
            if startDate.year == endDate.year {
                var string = startDate.toString("MM/dd HH:mm")
                if !startDate.isSameDay(endDate) {
                    string.append(" - ")
                    string.append(endDate.toString("MM/dd HH:mm"))
                }
                appointEndTimeLabel.text = string
            } else {
                var string = startDate.toString("yyyy/MM/dd HH:mm")
                string.append(" - ")
                string.append(endDate.toString("yyyy/MM/dd HH:mm"))
                appointEndTimeLabel.text = string
            }
        }
        
        if let store = event?.store {
            addressLabel.text = store.address
        }
        if let rewards = event?.rewards {
            for reward in rewards {
                rewardTypeButton.setTitle(reward.type?.title, for: UIControlState())
                if let amount = reward.amount {
                    rewardLabel.text = "完成任务得\(amount)积分"
                }
            }
            
        }
        if let status = event?.status {
            if status == .finished {
                statusLabel.isHidden = false
                codeImageView.alpha = 0.2
                eventNumberLabel.alpha = 0.2
            } else {
                statusLabel.isHidden = true
                codeImageView.alpha = 1
                eventNumberLabel.alpha = 1
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            let vc = self.parent
            vc?.performSegue(withIdentifier: R.segue.myEventDetailViewController.showEventDetailVC.identifier, sender: nil)
        }
    }
}

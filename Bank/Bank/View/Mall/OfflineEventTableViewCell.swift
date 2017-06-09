//
//  EventsTableViewCell.swift
//  Bank
//
//  Created by yang on 16/2/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit
import Device

class OfflineEventTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var eventImageView: UIImageView!
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet weak var joinPeopleLabel: UILabel!
    @IBOutlet weak var joinPeopleImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var pointConstraintBottom: NSLayoutConstraint!
    var isHideStatus = false
    
    enum OfflineEventType {
        case offlineEvent
        case myTask
    }
    var offlineEventType: OfflineEventType = .offlineEvent
    var buttonHandleBlock: ((_ event: OfflineEvent) -> Void)?
    var taskButtonHandle: ((_ task: DailyTask?) -> Void)?
    var offlineEvent: OfflineEvent!
    var dailyTask: DailyTask!
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.text = ""
        eventImageView.clipsToBounds = true
        eventImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configData(_ event: OfflineEvent) {
        self.offlineEvent = event
        joinPeopleLabel.isHidden = false
        joinPeopleImageView.isHidden = false
        pointConstraintBottom.constant = 5
        eventImageView.setImage(with: event.cover, placeholderImage: R.image.image_default_large())
        var amountFontSize: CGFloat = 20
        if Device.size() > .screen4Inch {
            amountFontSize = 25
        }
        pointLabel.attributedText = NSAttributedString(amountNumber: Int(event.point), leftString: "", rightString: "积分", color: UIColor(hex: 0xfe8d00), amountFontSize: amountFontSize, leftStringFontSize: 24, rightStringFontSize: 13)
        titleLabel.text = event.title
        joinPeopleLabel.text = "\(event.signedNumber)" + "人参加 "
        guard let startDate = event.startTime else { return }
        guard let endDate = event.endTime else { return }
        if startDate.year == endDate.year {
            if startDate.isSameDay(endDate) {
                dateLabel.text = startDate.toString("MM/dd")
            } else {
                dateLabel.text = startDate.toString("MM/dd") + " - " + endDate.toString("MM/dd")
            }
        } else {
            dateLabel.text = startDate.toString("yyyy/MM/dd") + " - " + endDate.toString("yyyy/MM/dd")
        }
        
        if !isHideStatus {
            guard let status = event.status else {return}
            button.isHidden = false
            button.cornerRadius = 4
            button.backgroundColor = UIColor(hex: 0xB3B3B3)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.borderColor = UIColor.clear.cgColor
            button.layer.borderWidth = 0
            button.setTitle(status.myEventListText, for: UIControlState())
        } else {
            button.isHidden = true
        }
    }
    
    func configInfo(_ data: DailyTask) {
        dailyTask = data
        joinPeopleLabel.isHidden = true
        joinPeopleImageView.isHidden = true
        eventImageView.setImage(with: data.imageURL, placeholderImage: R.image.image_default_large())

        guard let startTime = data.startTime else { return }
        guard let endTime = data.endTime else { return }
        
        var string = ""
        if startTime.year == endTime.year {
            string = startTime.toString("MM/dd")
            if startTime.month != endTime.month {
                string.append(" - ")
                string.append(endTime.toString("MM/dd"))
            }
        } else {
            string = startTime.toString("yyyy/MM/dd")
            string.append(" - ")
            string.append(endTime.toString("yyyy/MM/dd"))
        }
        dateLabel.text = string
        var amountFontSize: CGFloat = 20
        if Device.size() > .screen4Inch {
            amountFontSize = 25
        }
        pointLabel.attributedText = NSAttributedString(amountNumber: data.point, leftString: "", rightString: "积分", color: UIColor(hex: 0xfe8d00), amountFontSize: amountFontSize, leftStringFontSize: 24, rightStringFontSize: 13)
        titleLabel.text = data.title
        guard let status = data.status else { return }
        button.isEnabled = status.enable
        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 1
        button.cornerRadius = 4
        button.layer.borderColor = UIColor(hex: 0x00a8fe).cgColor
     
        // 任务中
        if status == .unfinished {
            button.isHidden = false
            button.backgroundColor = UIColor(hex: 0xef6161)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.borderWidth = 0
            // 领取奖励
        } else if status == .finished || status == .unGet {
            button.isHidden = false
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor(hex: 0x00a8fe), for: .normal)
            button.layer.borderColor = UIColor(hex: 0x00a8fe).cgColor
            button.layer.borderWidth = 1
            // 失效
        } else if status == .invalid {
            button.isHidden = false
            button.backgroundColor = UIColor(hex: 0xB3B3B3)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.borderColor = UIColor.clear.cgColor
            button.layer.borderWidth = 0
        } else if status == .gotAward {
            button.isHidden = false
            button.backgroundColor = UIColor(hex: 0xB3B3B3)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.borderColor = UIColor.clear.cgColor
            button.layer.borderWidth = 0
        } else {
            button.isHidden = true
        }
        
        button.setTitle(status.text, for: UIControlState())
        button.addTarget(self, action: #selector(dailyTaskAction(_:)), for: .touchUpInside)
    }
    
    func offlineEventAction(_ sender: UIButton) {
        if let block = buttonHandleBlock {
            block(offlineEvent)
        }
    }
    
    func dailyTaskAction(_ sender: UIButton) {
        if let block = taskButtonHandle {
            block (dailyTask)
        }
    }
}

//
//  NotifaicationMenuTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/30.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var sourceLabel: UILabel!
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var indicatorImageView: UIImageView!
 
    fileprivate var notification: Notification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        infoLabel.text = nil
        indicatorImageView.isHidden = true
    }

    override  func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func cellDataSetup(_ data: Notification) {
        notification = data
        if data.readStatus == .read {
            sourceLabel.textColor = UIColor.darkGray
            sourceLabel.font = .systemFont(ofSize: 17)
        } else {
            sourceLabel.textColor = UIColor.black
            sourceLabel.font = .boldSystemFont(ofSize: 17)
        }

        dateLabel.text = data.created?.timeAgoSince()
        contentLabel.text = data.content
        sourceLabel.text = data.title
        if let title = data.buttonTitle, !title.isEmpty {
            infoLabel.text = title
            indicatorImageView.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.textColor = UIColor.darkGray
        sourceLabel.font = .systemFont(ofSize: 17)
        infoLabel.text = nil
        indicatorImageView.isHidden = true
    }
}

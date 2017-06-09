//
//  MyReservationTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/27.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MyReservationTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var tagImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ data: Appoint) {
        if let type = data.type {
            switch type {
            case .withdrawAppoint:
                tagImageView.image = R.image.center_myReservation_icon_drawmoney()
                titleLabel.text = "大额取款"
                break
            case .personalLoans:
                tagImageView.image = R.image.center_myReservation_icon_loan()
                titleLabel.text = "个人贷款"
                break
            }
        }
        if let status = data.status {
            statusLabel.text = status.text
            statusLabel.textColor = status.textColor
        }
        dateLabel.text = data.time?.toString("申请日期MM月dd日 HH:mm")
        
    }
}

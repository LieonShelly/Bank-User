//
//  AwardRecordTableViewCell.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AwardRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    func configInfo(award: Award) {
        nameLabel.text = award.goodsTitle
        if let userName = award.userName {
            self.userName.text = R.string.localizable.center_myward_userAward(userName)
        }
        if let date = award.awardTime?.toString("MM-dd-yy HH:mm") {
            dateLabel.text = date
        }
        if let point = award.point {
            pointLabel.text = point
        }
    }
}

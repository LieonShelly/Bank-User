//
//  AccountDetailTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AccountDetailTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(obj: AccountStatement) {
        titleLabel.text = obj.detail
        timeLabel.text = obj.time?.toString("yyyy-MM-dd HH:mm")
        balanceLabel.text = "可用余额：\(obj.balance)元"
        
        stateLabel.amountWithUnit(obj.changeAmount, amountFontSize: 17, unitFontSize: 15)
    }
}

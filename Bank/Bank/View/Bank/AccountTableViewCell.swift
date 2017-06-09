//
//  AccountTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/23.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configBalanceStatement(_ statement: TransactionDetail) {
        titleLabel.text = statement.type?.rawValue
        dateLabel.text = statement.time?.toString("MM-dd HH:mm")
        let color = CustomKey.Color.mainBlueColor
        valueLabel.amountWithUnit(statement.money ?? 0, color: UIColor(hex: color), amountFontSize: 21.0, unitFontSize: 13)
    }
    
}

//
//  CreditBillDetailTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var billLabel: UILabel!
    @IBOutlet fileprivate weak var remainAmountLabel: UILabel!
    @IBOutlet fileprivate weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ repayment: Repayment) {
        billLabel.amountWithUnit(repayment.amount, color: UIColor(hex: 0x00A8FE), amountFontSize: 21, unitFontSize: 13, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
        remainAmountLabel.amountWithUnit(repayment.remainAmount, color: UIColor(hex: 0xB3B3B3), amountFontSize: 13, unitFontSize: 13, unit: "元", decimalPlace: 2)
        detailLabel.text = repayment.detail
        guard let time = repayment.creat else {return}
        timeLabel.text = (time as NSString).substring(to: 16)
        
    }
    
}

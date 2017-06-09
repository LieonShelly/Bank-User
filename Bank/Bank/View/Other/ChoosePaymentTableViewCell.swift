//
//  ChoosePaymentTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/7/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ChoosePaymentTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var radioButton: UIButton!
    @IBOutlet fileprivate weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        radioButton.isSelected = selected
    }
    
    func configCard(_ card: BankCard) {
        var number = (card.number as NSString)
        number = number.substring(from: number.length - 3) as (NSString)
        nameLabel.text = R.string.localizable.bank_payment_name(card.bankName, number as String)
    }
    
}

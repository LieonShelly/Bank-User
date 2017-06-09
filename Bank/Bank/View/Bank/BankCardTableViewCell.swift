//
//  BankCardTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/23.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Device

class BankCardTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var backImageView: UIImageView!
    @IBOutlet fileprivate weak var bankNameLabel: UILabel!
    @IBOutlet fileprivate weak var subTitleLabel: UILabel!
    
    @IBOutlet fileprivate weak var carNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if Device.size() == .screen5_5Inch {
            backImageView.contentMode = .scaleAspectFill
        } else {
            backImageView.contentMode = .scaleAspectFit
        }
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCard(_ card: BankCard) {
        bankNameLabel.text = card.bankName
        guard let backImageURL = card.bankBackground else { return }
        var number = card.number as NSString
        if number.length > 3 {
            number = number.substring(from: number.length - 3) as NSString
        }
        carNumberLabel.text = number as String
        backImageView.setImage(with: backImageURL)
        subTitleLabel.text = card.cardTypeName
    }
    
}

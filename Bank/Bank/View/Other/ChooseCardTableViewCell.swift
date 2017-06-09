//
//  ChooseCardTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/7/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ChooseCardTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var tipLabel: UILabel!
    
    var card: BankCard?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCard(_ card: BankCard) {
        iconImageView.setImage(with: card.bankLogo, placeholderImage: R.image.image_default_small())
        var number = card.number as NSString
        if number.length > 4 {
            number = number.substring(from: number.length - 4) as NSString
        }
        nameLabel.text = card.bankName + "(\(number))"
    }
}

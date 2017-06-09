//
//  AddressManagementTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/27.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AddressManagementTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var phoneNumberLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configInfo(_ data: Address) {
        nameLabel.text = data.name
        phoneNumberLabel.text = data.mobile
        if let string1 = data.region, let string2 = data.address {
            if let isDefault = data.isDefault {
                contentLabel.attributedText = NSAttributedString(unit: string1 + string2, isDefault: isDefault)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

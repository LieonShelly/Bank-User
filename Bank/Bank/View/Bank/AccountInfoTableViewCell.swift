//
//  AccountInfoTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AccountInfoTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var descLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ info: (String, String, Bool)) {
        descLabel.text = info.0
        contentLabel.text = info.1
        if info.2 == true {
            contentLabel.textColor = UIColor.colorFromHex(0xff6400)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.textColor = UIColor.colorFromHex(0x1c1c1c)
    }
}

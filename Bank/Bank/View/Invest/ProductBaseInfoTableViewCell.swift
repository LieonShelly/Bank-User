//
//  ProductBaseInfoTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/8.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ProductBaseInfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var leftLabel: UILabel!
    @IBOutlet private weak var rightLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(data: (String, String)) {
        leftLabel.text = data.0
        rightLabel.text = data.1
    }
}

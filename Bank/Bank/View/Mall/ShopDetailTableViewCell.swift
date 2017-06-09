//
//  ShopDetailTableViewCell.swift
//  Bank
//
//  Created by yang on 16/2/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class ShopDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var describeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

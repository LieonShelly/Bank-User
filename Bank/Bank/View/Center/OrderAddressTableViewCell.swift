//
//  SelectAddressTableViewCell.swift
//  Bank
//
//  Created by yang on 16/5/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderAddressTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var phoneLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ order: Order) {
        nameLabel.text = order.cneeName
        phoneLabel.text = order.mobile
        addressLabel.text = order.address
    }
    
}

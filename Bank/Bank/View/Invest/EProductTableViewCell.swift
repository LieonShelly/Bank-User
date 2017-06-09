//
//  EProductTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class EProductTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var purchasedLabel: UILabel!
    @IBOutlet private weak var profitLabel: UILabel!
    @IBOutlet private weak var tagView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clearColor()
        tagView.tintColor = UIColor.colorFromHex(0xff6400)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configInfo(info: Product) {
        nameLabel.text = info.title
        purchasedLabel.amountWithUnit(info.boughtAmount, color: UIColor.colorFromHex(0x1c1c1c), amountFontSize: 17, unitFontSize: 17)
        profitLabel.amountWithUnit(info.boughtAmount, color: UIColor.colorFromHex(0x1c1c1c), amountFontSize: 17, unitFontSize: 17)
    }
    
}

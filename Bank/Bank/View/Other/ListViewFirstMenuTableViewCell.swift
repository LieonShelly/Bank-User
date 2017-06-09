//
//  ListViewFirstMenuTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ListViewFirstMenuTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
    }
    
    func configInfo(_ goodsCat: GoodsCats) {
        titleLabel.text = goodsCat.catName
        if goodsCat.catID == "0" {
            iconImageView.image = R.image.icon_whole()
        } else {
            iconImageView.setImage(with: goodsCat.catIcon, placeholderImage: R.image.image_default_small())
        }
        if isSelected == true {
            contentView.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor(hex: 0xef6161)
        } else {
            contentView.backgroundColor = UIColor(hex: 0xf2f2f2)
            titleLabel.textColor = UIColor.darkGray
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected == true {
            contentView.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor(hex: 0x00a8fe)
        } else {
            contentView.backgroundColor = UIColor(hex: 0xf7f7f7)
            titleLabel.textColor = UIColor.darkGray
        }

    }
    
}

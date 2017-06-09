//
//  MyPrizeTableViewCell.swift
//  Bank
//
//  Created by yang on 16/7/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MyPrizeTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var coverImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var maskLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configInfo(_ data: Prize) {
        if let date = data.created {
            dateLabel.text = date.toString("yyyy-MM-dd")
        }
        statusLabel.text = data.status?.text
        coverImageView.setImage(with: data.cover, placeholderImage: R.image.image_default_midden())
        titleLabel.text = data.title
        maskLabel.text = data.summary
        if let price = data.marketPrice {
            let priceStr = price.numberToString()
            var str = "市场参考价："
            str.append("\(priceStr)元")
            priceLabel.text = str
        }
        if data.status == .unCash {
            statusLabel.textColor = UIColor.orange
        } else {
            statusLabel.textColor = UIColor.darkGray
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

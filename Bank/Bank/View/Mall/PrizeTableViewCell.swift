//
//  PrizeTableViewCell.swift
//  Bank
//
//  Created by yang on 16/6/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PrizeTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var coverImageView: UIImageView!
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var contentLabel: UILabel!
    @IBOutlet weak fileprivate var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configInfo(_ data: Prize) {
        coverImageView.setImage(with: data.cover, placeholderImage: R.image.image_default_midden())
        titleLabel.text = data.title
        contentLabel.text = data.summary
        if let price = data.marketPrice {
            let priceStr = price.numberToString()
            priceLabel.text = "市场参考价：\(priceStr)元"
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

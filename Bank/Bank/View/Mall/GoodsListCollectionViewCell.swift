//
//  GoodsListCollectionViewCell.swift
//  Bank
//
//  Created by 杨锐 on 2016/12/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class GoodsListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var newPriceLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    var goods: Goods!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configInfo(_ data: Goods) {
        goods = data
        goodsImageView.setImage(with: data.imageURL, placeholderImage: R.image.image_default_midden())
        goodsImageView.layer.cornerRadius = 2
        goodsImageView.contentMode = .scaleAspectFill
        titleLabel.text = data.title
        newPriceLabel.amountWithUnit(data.price, amountFontSize: 17, unitFontSize: 17, unit: "¥", decimalPlace: 2)
        priceLabel.amountWithUnit(data.marketPrice, color: UIColor(hex: 0xa0a0a0), amountFontSize: 13, unitFontSize: 13, strikethrough: true, unit: "¥", decimalPlace: 2)
        numberLabel.text = "已售\(data.sellNum)份"
        infoLabel.text = data.summary
    }

}

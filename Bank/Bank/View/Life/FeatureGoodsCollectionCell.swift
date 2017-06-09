//
//  FeatureGoodsCollectionCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class FeatureGoodsCollectionCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    
    var goods: Goods?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderWidth = 0
    }
    
    func configGoods(_ goods: Goods) {
        self.goods = goods
        if !goods.goodsID.isEmpty {
            imageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
            imageView.layer.borderColor = UIColor(hex: 0xe5e5e5).cgColor
            imageView.layer.borderWidth = 1
            nameLabel.text = goods.title
            priceLabel.amountWithUnit(goods.price, amountFontSize: 14, unitFontSize: 14, unit: "¥", decimalPlace: 2)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        goods = nil
        imageView.image = nil
        imageView.layer.borderWidth = 0
        nameLabel.text = nil
        priceLabel.text = nil
    }
}

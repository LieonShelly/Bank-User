//
//  GoodsCollectionViewCell.swift
//  Bank
//
//  Created by yang on 16/4/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Device

class GoodsCollectionViewCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var orangePriceLabel: UILabel!
    @IBOutlet weak var saleLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    
    fileprivate var systemFont: CGFloat = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if Device.size() == .screen3_5Inch {
            systemFont = 12
        }
        if let image = R.image.mall_offlineEvent_bg_people() {
            bgImageView.image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func configInfo(_ goods: Goods) {
        goodsImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        goodsImageView.contentMode = .scaleAspectFill
        titleLabel.text = goods.title
        priceLabel.amountWithUnit(goods.price, amountFontSize: systemFont, unitFontSize: systemFont, unit: "¥", decimalPlace: 2)
        orangePriceLabel.amountWithUnit(goods.marketPrice, color: UIColor.lightGray, amountFontSize: systemFont - 2, unitFontSize: systemFont - 2, strikethrough: true, unit: "¥", decimalPlace: 2)
        saleLabel.font.withSize(systemFont - 4)
        saleLabel.text = "已售\(goods.sellNum)份"
    }

}

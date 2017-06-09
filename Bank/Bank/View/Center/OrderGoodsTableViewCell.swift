//
//  OrderGoodsTableViewCell.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderGoodsTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    @IBOutlet fileprivate weak var propertyLabel: UILabel!
    
    var goods: Goods!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ goods: Goods) {
        self.goods = goods
        propertyLabel.isHidden = true
        goodsImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        titleLabel.text = goods.title
        priceLabel.text = "¥\(goods.price)"
        priceLabel.amountWithUnit(goods.price, amountFontSize: 19, unitFontSize: 19, unit: "¥", decimalPlace: 2)
        numberLabel.text = "X\(goods.num)"
        if !goods.propertyList.isEmpty {
            propertyLabel.isHidden = false
            let descList = goods.propertyList.flatMap { return $0.desc() }
            propertyLabel.text = descList.joined(separator: ";")
        }
    }
    
}

//
//  MallGoodsTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MallGoodsTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var newPriceLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    var goods: Goods!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        newPriceLabel.textColor = UIColor(hex: 0xff6400)
        lineView.isHidden = true
    }
    
    func configInfo(_ data: Goods) {
        goods = data
        goodsImageView.setImage(with: data.imageURL, placeholderImage: R.image.image_default_midden())
        titleLabel.text = data.title
        newPriceLabel.amountWithUnit(data.price, amountFontSize: 17, unitFontSize: 17, unit: "¥", decimalPlace: 2)
        priceLabel.amountWithUnit(data.marketPrice, color: UIColor(hex: 0xa0a0a0), amountFontSize: 13, unitFontSize: 13, strikethrough: true, unit: "¥", decimalPlace: 2)
        numberLabel.text = "已售\(data.sellNum)份"
        infoLabel.text = data.summary
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

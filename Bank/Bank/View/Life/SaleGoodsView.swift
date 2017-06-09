//
//  SaleGoodsView.swift
//  Bank
//
//  Created by Koh Ryu on 11/18/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class SaleGoodsView: UIView {

    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var saleLabel: UILabel!
    @IBOutlet fileprivate var originalLabel: UILabel!
    
    fileprivate var goods: Goods!
    
    var tapHandle: GoodsTapHandleBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configGoods(_ product: Goods) {
        goods = product
        imageView.setImage(with: product.imageURL, placeholderImage: R.image.image_default_midden())
        titleLabel.text = product.title
        saleLabel.amountWithUnit(product.price, amountFontSize: 20, unitFontSize: 11, decimalPlace: 2)
        originalLabel.amountWithUnit(product.marketPrice, color: UIColor(hex: 0xa0a0a0), amountFontSize: 11, unitFontSize: 11, strikethrough: true, decimalPlace: 2)
    }
    
    @IBAction func imageTapHandle() {
        if let block = tapHandle {
            block(goods)
        }
    }

}

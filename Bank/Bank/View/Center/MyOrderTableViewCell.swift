//
//  MyOrderTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Device

class MyOrderTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var storeImageView: UIImageView!
    @IBOutlet fileprivate weak var goodsNameLabel: UILabel!
    @IBOutlet fileprivate weak var price: UILabel!
    @IBOutlet fileprivate weak var goodsNumberLabel: UILabel!
    @IBOutlet fileprivate weak var propertyLabel: UILabel!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        var systemFont: CGFloat = 13
        imageWidth.constant = 85
        if Device.size() > .screen4Inch {
            systemFont = 15
            imageWidth.constant = 100
        }
        goodsNameLabel.font = UIFont.systemFont(ofSize: systemFont)
        propertyLabel.font = UIFont.systemFont(ofSize: systemFont - 1)
    }
    
    // 设置商品信息
    func configInfo(_ goods: Goods) {
        propertyLabel.isHidden = true
        storeImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        goodsNameLabel.text = goods.title
        price.amountWithUnit(goods.price, color: UIColor(hex: 0x1c1c1c), amountFontSize: 15, unitFontSize: 15, unit: "¥", decimalPlace: 2)
        goodsNumberLabel.text = "X\(goods.num)"
        if !goods.propertyList.isEmpty {
            propertyLabel.isHidden = false
            let descList = goods.propertyList.flatMap { return $0.desc() }
            propertyLabel.text = descList.joined(separator: ";")
        }
    }
    
    // 退款调到退款详情页 TODO
    @IBAction func refundAction(_ sender: UIButton) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

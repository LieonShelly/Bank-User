//
//  SubmitOrderTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class SubmitOrderTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet fileprivate weak var numberTextField: UITextField!
    @IBOutlet weak var propertyLabel: UILabel!
    
    var numberHandleBlock: ((_ number: Int) -> Void)?
    var editNumberHandleBlock: (() -> Void)?
    var number: Int?
    var goods: Goods?
    var submitType: SubmitType?
    var group: Group?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        editView.isHidden = true
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
        priceLabel.amountWithUnit(goods.price, amountFontSize: 16, unitFontSize: 16, unit: "¥", decimalPlace: 2)
        if let num = self.number {
            numberTextField.text = String(num)
        }
        numLabel.text = "×\(goods.num)"
        number = goods.num
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        editView.addGestureRecognizer(tap)
        if submitType == .goodsDetail {
            numLabel.isHidden = true
            editView.isHidden = false
        } else {
            editView.isHidden = true
            numLabel.isHidden = false
        }
        if !goods.propertyList.isEmpty {
            propertyLabel.isHidden = false
            let descList = goods.propertyList.flatMap { return $0.desc() }
            propertyLabel.text = descList.joined(separator: ";")
        }
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        if let block = editNumberHandleBlock {
            block()
        }
    }
}

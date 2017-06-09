//
//  SubmitOrderSectionFooterView.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class SubmitOrderSectionFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet fileprivate weak var expressFeeLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var delivertyNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delivertyNameLabel.textColor = UIColor(hex: 0x1c1c1c)
        expressFeeLabel.textColor = UIColor(hex: 0x1c1c1c)
        priceLabel.textColor = UIColor.orange
    }
    
    func configInfo(_ merchant: Merchant) {
        if merchant.deliveryCost == 0 || merchant.deliveryCost == nil {
            expressFeeLabel.text = "免邮"
        } else {
            expressFeeLabel.amountWithUnit(merchant.deliveryCost ?? 0, color: UIColor.gray, amountFontSize: 17, unitFontSize: 17, unit: "元")
        }
        if let items = merchant.totalItems {
            numberLabel.text = "共\(items)件商品"
        }
        priceLabel.amountWithUnit(Float(merchant.totalPrice), amountFontSize: 16, unitFontSize: 16, unit: "元")
    }
}

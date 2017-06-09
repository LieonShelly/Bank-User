//
//  ProductBaseInfoTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/8.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ProductPurchaseInfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var desc1Label: UILabel!
    @IBOutlet private weak var content1Label: UILabel!
    @IBOutlet private weak var desc2Label: UILabel!
    @IBOutlet private weak var content2Label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(product: Product) {
//        if product.hold == true {
//            content1Label.amountWithUnit(product.purchasedAmount, amountFontSize: 17, unitFontSize: 13, decimalPlace: 2)
//            content2Label.amountWithUnit(product.estimatedProfit, amountFontSize: 17, unitFontSize: 13, decimalPlace: 2)
//            desc1Label.text = "持有金额"
//            desc2Label.text = "预计获得"
//            
//        } else {
//            content1Label.amountWithUnit(product.leastInvestAmount, amountFontSize: 17, unitFontSize: 13, decimalPlace: 2)
//            content2Label.amountWithUnit(product.estimatedProfit, amountFontSize: 17, unitFontSize: 13, decimalPlace: 2)
//            desc1Label.text = "起购金额"
//            desc2Label.text = "停售时间"
//        }
    }
    
}

//
//  OrderGoodsSectionFooterView.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable empty_count

import UIKit

class OrderGoodsSectionFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet fileprivate weak var theView: UIView!
    @IBOutlet fileprivate weak var discountLabel: UILabel!
    @IBOutlet fileprivate weak var deliveryLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var discountNameLabel: UILabel!
    @IBOutlet fileprivate weak var deliveryNameLabel: UILabel!
    @IBOutlet fileprivate weak var priceNameLabel: UILabel!
    @IBOutlet fileprivate weak var merchantPointNameLabel: UILabel!
    @IBOutlet fileprivate weak var merchantPointLabel: UILabel!
    @IBOutlet fileprivate weak var platformPointNameLabel: UILabel!
    @IBOutlet fileprivate weak var platformPointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        discountNameLabel.textColor = UIColor.darkGray
        deliveryNameLabel.textColor = UIColor.darkGray
        priceNameLabel.textColor = UIColor.darkGray
        discountLabel.textColor = UIColor.darkGray
        deliveryLabel.textColor = UIColor.darkGray
        priceLabel.textColor = UIColor.orange
        platformPointLabel.textColor = UIColor.darkGray
        platformPointNameLabel.textColor = UIColor.white
        merchantPointLabel.textColor = UIColor.darkGray
        merchantPointNameLabel.textColor = UIColor.white
    }
    
    func configInfo(_ order: Order) {
        let totalDiscount = order.totalDiscount == 0 ? 0 : -order.totalDiscount
        discountLabel.amountWithUnit(totalDiscount, color: UIColor.darkGray, amountFontSize: 15, unitFontSize: 15, unit: "¥", decimalPlace: 2)
        deliveryLabel.amountWithUnit(order.deliveryCost, color: UIColor.darkGray, amountFontSize: 15, unitFontSize: 15, unit: "¥", decimalPlace: 2)
        priceLabel.amountWithUnit(order.totalPrice, amountFontSize: 15, unitFontSize: 15, unit: "¥", decimalPlace: 2)
        merchantPointLabel.text = "商家返利送\(order.merchantPoint)积分"
        platformPointLabel.text = "平台活动送\(order.platformPoint)积分"
    }
    
}

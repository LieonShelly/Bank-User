//
//  DiscountListTableViewCell.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class DiscountListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var merchantNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var actualPriceLabel: UILabel!
    @IBOutlet private weak var orderPriceLabel: UILabel!
    @IBOutlet private weak var orderNoLabel: UILabel!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configInfo(discount: Discount) {
        merchantNameLabel.text = discount.merchantName
        dateLabel.text = discount.payTime?.toString("MM.dd HH:mm")
        if let actual = discount.actual {
            actualPriceLabel.text = actual.numberToString() + "元"
        }
        if let total = discount.total {
            orderPriceLabel.text = total.numberToString() + "元"
        }
        orderNoLabel.text = discount.orderNO
    }
    
}

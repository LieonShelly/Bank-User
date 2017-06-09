//
//  DiscountTableViewCell.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/13.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class DiscountTableViewCell: UITableViewCell {
    @IBOutlet weak var discountNameLabel: UILabel!
    @IBOutlet weak var discountTypeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    
    var openHandleBlock: ((_ isOpen: Bool) -> Void)?
    
    fileprivate var isOpen: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func openAction(_ sender: UIButton) {
        isOpen = !isOpen
        if let block = openHandleBlock {
            block(isOpen)
        }
    }
    
    func configInfo(discount: Discount) {
        discountNameLabel.text = discount.privilegeName
        discountTypeLabel.text = discount.type?.title
        if discount.type == .discount {
            if let string = discount.discount {
                discountLabel.text = string + "折"
            }
        }
        if discount.type == .fullCut {
            discountLabel.text = "满\(discount.fullSum)减\(discount.minusSum)"
        }
        desLabel.isHidden = true
        if let topPrivilege = discount.topPrivilege {
            desLabel.text = "优惠限额:最高减\(topPrivilege)元"
            desLabel.isHidden = false
        }
        ruleLabel.text = discount.rule
        isOpen = discount.isOpen
        if isOpen == true {
            ruleLabel.numberOfLines = 0
            openButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        } else {
            ruleLabel.numberOfLines = 1
            openButton.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }
    }
}

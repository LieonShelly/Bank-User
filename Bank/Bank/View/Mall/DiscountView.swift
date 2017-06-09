//
//  DiscountView.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class DiscountView: UIView {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    var openHandleBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        if let block = openHandleBlock {
            block()
        }
    }
    
    func configInfo(discounts: [Discount]) {
        typeLabel.text = discounts[0].type?.title
        let discountStrs = discounts.filter { $0.privilegeName != nil }.map { (discount) -> String in
            var string = ""
            if let privilegeName = discount.privilegeName {
                if discount.type == .fullCut {
                    string.append(privilegeName)
                    string.append("满\(String(discount.fullSum))减\(String(discount.minusSum))")
                } else {
                    if let count = discount.discount {
                        string.append(privilegeName)
                        string.append("\(count)折")
                    }
                }
            }
            return string
        }
        nameLabel.text = discountStrs.joined(separator: ",")
        countLabel.text = "(\(discounts.count))"
    }

}

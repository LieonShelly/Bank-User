//
//  OrderConsumeTableViewCell.swift
//  Bank
//
//  Created by yang on 16/5/12.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderConsumeTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    
    var couponDetailHandleBlock: ((_ coupon: Coupon) -> Void)?
    fileprivate var coupon: Coupon!
    
    @IBOutlet fileprivate weak var gotoDetailButton: UIButton!
    @IBOutlet fileprivate weak var trailConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ coupon: Coupon) {
        self.coupon = coupon
        statusLabel.text = coupon.status?.text
        if let code = coupon.code {
            numberLabel.text = "消费码:\(code.couponString())"
        }
        if let status = coupon.status {
            switch status {
            case .unused:
                gotoDetailButton.isHidden = false
                trailConstraint.constant = 40
            case .used:
                gotoDetailButton.isHidden = true
                trailConstraint.constant = 13
            case .refunded:
                gotoDetailButton.isHidden = false
                trailConstraint.constant = 40
            case .refunding:
                gotoDetailButton.isHidden = false
                trailConstraint.constant = 40
            default:
                gotoDetailButton.isHidden = true
                trailConstraint.constant = 13
            }

        }
    }
    
    @IBAction func couponDetailAction(_ sender: UIButton) {
        if let block = couponDetailHandleBlock {
            block(coupon)
        }
    }
}

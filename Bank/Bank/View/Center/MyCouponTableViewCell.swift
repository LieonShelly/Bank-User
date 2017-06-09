//
//  MyCouponTableViewCell.swift
//  Bank
//
//  Created by yang on 16/1/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Device

class MyCouponTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var bgImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var couponNumberLabel: UILabel!
    @IBOutlet fileprivate weak var isUsedLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelTrailingWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgImageView.image = R.image.icon_bg()
    }
    
    func configInfo(_ coupon: Coupon) {
        titleLabel.text = coupon.goodsTitle
        if let code = coupon.code {
            couponNumberLabel.text = code.couponString()
        }
        dateLabel.text = coupon.expireTime?.toString("yyyy-MM-dd")
        isUsedLabel.text = coupon.status?.listTitle
        if coupon.status == .outOfDate {
            bgImageView.image = R.image.icon_bg_outDate()
        }
        if Device.size() == .screen4Inch {
            dateLabelTrailingWidth.constant = 8
        } else if Device.size() == .screen4_7Inch {
            dateLabelTrailingWidth.constant = 15
        } else if Device.size() == .screen5_5Inch {
            dateLabelTrailingWidth.constant = 25
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bgImageView.image = R.image.icon_bg()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

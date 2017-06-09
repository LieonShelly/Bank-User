//
//  SubmitOrderSectionHeaderView.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable private_outlet

import UIKit

class SubmitOrderSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var shopNameLabel: UILabel!
    @IBOutlet fileprivate weak var tapView: UIView!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    var gotoShopHandleBlock: ((_ segueID: String, _ merchantID: String) -> Void)?
    var merchant: Merchant!
    override func awakeFromNib() {
        super.awakeFromNib()
        shopNameLabel.textColor = UIColor(hex: 0x1c1c1c)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapView.addGestureRecognizer(tap)
    }
    
    func configInfo(_ merchant: Merchant) {
        self.merchant = merchant
        shopNameLabel.text = merchant.storeName
    }

    func tapAction(_ sender: UITapGestureRecognizer) {
        if let block = gotoShopHandleBlock {
            block(R.segue.submitOrderViewController.showBrandDetailVC.identifier, merchant.merchantID)
        }
    }
}

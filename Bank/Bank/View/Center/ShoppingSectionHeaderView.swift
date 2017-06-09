//
//  ShoppingSectionHeaderView.swift
//  Bank
//
//  Created by yang on 16/2/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class ShoppingSectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet fileprivate weak var merchantImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var selectHandleBlock: ((_ sender: UIButton) -> Void)?
    var merchant: Merchant?
    var gotoMerchantDetailHandleBlock: ((_ merchantID: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMerchantDetailAction(_:)))
        addGestureRecognizer(tap)
        selectButton.setImage(R.image.btn_choice_yes(), for: .selected)
    }
    
    @objc fileprivate func gotoMerchantDetailAction(_ tap: UITapGestureRecognizer) {
        if let block = gotoMerchantDetailHandleBlock, let merchantID = merchant?.merchantID {
            block(merchantID)
        }
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        if let block = selectHandleBlock {
            block(sender)
        }
    }
    
    func configInfo(_ merchant: Merchant) {
        self.merchant = merchant
        selectButton.isSelected = merchant.isChecked
        titleLabel.text = merchant.storeName
    }
}

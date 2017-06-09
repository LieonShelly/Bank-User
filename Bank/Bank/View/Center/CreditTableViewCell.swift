//
//  CreditTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
typealias ClickCheckBlock = () -> Void
typealias ClickCashPayBlock = () -> Void
typealias ClickStatePayBlock = () -> Void

class CreditTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var restLabel: UILabel!
    @IBOutlet fileprivate weak var billLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var checkButton: UIButton!
    @IBOutlet fileprivate weak var cashPayButton: UIButton!
    @IBOutlet fileprivate weak var integralPayButton: UIButton!
    var checkBlock: ClickCheckBlock?
    var cashPayBlock: ClickCashPayBlock?
    var statePayBlock: ClickStatePayBlock?
    let endTime = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func clickCheckButton(_ sender: UIButton) {
        if let block = checkBlock {
            block()
        }
    }
    @IBAction func clickCashMoneyButton(_ sender: UIButton) {
        if let block = cashPayBlock {
            block()
        }
    }
    @IBAction func clickStagingPayButton(_ sender: UIButton) {
        if let block = statePayBlock {
            block()
        }
    }
    
    func configInfo(_ creditGood: CreditGoods) {
        avatarImageView.image = R.image.ad_pic()
        guard let endTime = creditGood.endTime else {return}
        
        timeLabel.text = endTime.toDateString()
        
        nameLabel.text = creditGood.title
        restLabel.amountWithUnit(creditGood.remain, color: UIColor(hex: 0x00A8FE), amountFontSize: 20, unitFontSize: 12, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
        billLabel.amountWithUnit(creditGood.total, color: UIColor(hex: 0x1C1C1C), amountFontSize: 16, unitFontSize: 12, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
    }
    
    func setupUI() {
        checkButton.layer.cornerRadius = 4.0
        checkButton.layer.borderWidth = 1.0
        checkButton.layer.borderColor = UIColor.lightGray.cgColor
        cashPayButton.layer.borderColor = UIColor(hex: 0x00A8FE).cgColor
        cashPayButton.layer.cornerRadius = 4.0
        cashPayButton.layer.borderWidth = 1.0
        integralPayButton.layer.cornerRadius = 4.0
    }
    
}

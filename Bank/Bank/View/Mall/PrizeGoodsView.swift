//
//  PrizeGoodsView.swift
//  Bank
//
//  Created by yang on 16/7/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PrizeGoodsView: UIView {

    @IBOutlet fileprivate weak var coverImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    var prizeDetailHandleBlock: ((_ prizeID: String, _ SegueID: String) -> Void)?
    fileprivate var prize: Prize?
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func configInfo(_ data: Prize) {
        self.prize = data
        coverImageView.setImage(with: data.cover, placeholderImage: R.image.image_default_midden())
        titleLabel.text = data.title
        if let price = data.marketPrice {
            let priceStr = price.numberToString()
            priceLabel.text = "价值\(priceStr)元"
        }
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        if let block = prizeDetailHandleBlock {
            if let prizeID = prize?.prizeID {
                block(prizeID, R.segue.lotteryViewController.showPrizeDetailVC.identifier)
            }
            
        }
    }
}

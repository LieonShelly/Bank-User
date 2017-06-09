//
//  PrizePoolView.swift
//  Bank
//
//  Created by yang on 16/7/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PrizePoolView: UIView {

    @IBOutlet weak fileprivate var prizeStackView: UIStackView!
    fileprivate var prizes: [Prize]?
    var prizeDetailHandleBlock: ((_ prizeID: String, _ segueID: String) -> Void)?
    override func awakeFromNib() {
        for _ in 0..<3 {
            guard let prizeGoodsView = R.nib.prizeGoodsView.firstView(owner: nil) else {
                return
            }
            prizeStackView.addArrangedSubview(prizeGoodsView)
        }
    }
    
    func configInfo(_ prizes: [Prize]) {
        self.prizes = prizes
        for (prize, view) in zip(prizes, prizeStackView.arrangedSubviews) {
            guard let prizeGoodsView = view as? PrizeGoodsView else { continue }
            prizeGoodsView.configInfo(prize)
            prizeGoodsView.prizeDetailHandleBlock = { [weak self] (prizeID, segueID) in
                if let block = self?.prizeDetailHandleBlock {
                    block(prizeID, segueID)
                }
            }
        }
    }

}

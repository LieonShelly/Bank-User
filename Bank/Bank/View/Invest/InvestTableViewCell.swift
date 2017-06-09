//
//  InvestTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 11/18/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class InvestTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var tagStackView: UIStackView!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var percentLabel: UILabel!
    @IBOutlet private weak var tipLabel: UILabel!
    @IBOutlet private weak var midTopLabel: UILabel!
    @IBOutlet private weak var midBottomLabel: UILabel!
    
    private var tag1: UIImageView!
    private var tag2: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        
        tag1 = UIImageView(image: R.image.tag_01())
        tag1.tintColor = UIColor.colorFromHex(0xff6400)
        tag2 = UIImageView(image: R.image.icon_hot())
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configProduct(product: Product) {
        nameLabel.text = product.title
        if let start = product.saleStart, end = product.saleEnd {
            let today = NSDate()
            let formatter = NSDateComponentsFormatter()
            formatter.zeroFormattingBehavior = .Pad
            formatter.allowedUnits = [.Day, .Hour, .Minute]
            formatter.unitsStyle = .Abbreviated
            let order = start.compare(today)
            switch order {
            case .OrderedAscending, .OrderedSame:
                // already started
                let gap = end.timeIntervalSinceDate(today)
                midTopLabel.text = formatter.stringFromTimeInterval(gap)
                midBottomLabel.text = "剩余时间"
            case .OrderedDescending:
                // coming soon
                let gap = today.timeIntervalSinceDate(start)
                midBottomLabel.text = formatter.stringFromTimeInterval(gap)
                midTopLabel.text = "即将发售"
            }
        }
        amountLabel.text = "\(product.minAmount)元"
        if let profitPercent = product.aer {
            percentLabel.amountWithUnit(profitPercent, amountFontSize: 35, unitFontSize: 11, unit: "%")
        }
        if product.isGuarantee {
            tagStackView.addArrangedSubview(tag1)
        }
        if product.isHot {
            tagStackView.addArrangedSubview(tag2)
        }
        
        // TODO: 已售罄
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

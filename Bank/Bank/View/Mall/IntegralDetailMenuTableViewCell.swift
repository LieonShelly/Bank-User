//
//  IntegralDetailMenuTableViewCell.swift
//  Bank
//
//  Created by yang on 16/1/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class IntegralDetailMenuTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func conforInfo(_ data: PointObject) {
        
        if let typeName = data.typeName, let detail = data.detail {
            titleLabel.text = "【\(typeName)】\(detail)"
        }
        dateLabel.text = data.created?.toString("yyyy-MM-dd HH:mm")
        if let point = data.point {
            if point > 0 {
                pointLabel.attributedText = NSAttributedString(amountNumber: point, leftString: "", rightString: R.string.localizable.label_title_integral(), color: UIColor.orange, amountFontSize: 25, leftStringFontSize: 24, rightStringFontSize: 17)
            } else {
                pointLabel.attributedText = NSAttributedString(amountNumber: point, leftString: "", rightString: R.string.localizable.label_title_integral(), color: UIColor(hex: 0x00a8fe), amountFontSize: 25, leftStringFontSize: 24, rightStringFontSize: 17)
            }
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

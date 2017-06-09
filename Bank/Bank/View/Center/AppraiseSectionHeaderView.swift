//
//  AppraiseSectionHeaderView.swift
//  Bank
//
//  Created by yang on 16/3/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AppraiseSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor(hex: 0x1c1c1c)
    }
    
    func configInfo(_ order: Order) {
        titleLabel.text = order.storeName
    }

}

//
//  MallHomeSectionHeaderView.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MallHomeSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    var sectionTitle: String? {
        didSet {
            titleLabel.text = sectionTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

//
//  ChooseBranchTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ChooseBranchTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var telLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configBranch(_ data: Branch, keyword: String? = nil) {
        if let name = data.name, let keyword = keyword {
            var aName = NSMutableAttributedString(string: name)
            aName = apply(aName, word: keyword)
            nameLabel.attributedText = aName
        } else {
            nameLabel.text = data.name
        }
        telLabel.text = data.tel
        addressLabel.text = data.address
        
    }
    
}

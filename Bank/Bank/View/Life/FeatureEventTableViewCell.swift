//
//  FeatureEventTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class FeatureEventTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.imageView?.contentMode = .scaleAspectFill
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configData(_ data: Banner) {
        if let URL = data.imageURL {
            button.kf.setImage(with: URL, for: .normal)
        }
    }
    
}

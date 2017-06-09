//
//  ShopAuthTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ShopAuthTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var imageStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configInfo(_ data: [URL]) {
        let count = data.count >= 3 ? 3 : data.count
        for i in 0..<count {
            if let imageView = imageStackView.arrangedSubviews[i] as? UIImageView {
                let url = data[i]
                imageView.setImage(with: url, placeholderImage: R.image.image_default_midden())
            }

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

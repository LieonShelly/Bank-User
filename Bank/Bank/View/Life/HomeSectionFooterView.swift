//
//  HomeSectionFooterView.swift
//  Bank
//
//  Created by lieon on 2016/10/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Kingfisher

class HomeSectionFooterView: UITableViewHeaderFooterView {
    @IBOutlet weak var imageView: UIImageView!
    var tapBlock: (() -> Void)?
    func configData(_ data: Banner) {
        if let URL = data.imageURL {
            imageView.kf.setImage(with: URL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hex: 0xf5f5f5)
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
    }
}

extension HomeSectionFooterView {
    @objc fileprivate func tapAction(tap: UITapGestureRecognizer) {
        if let block = tapBlock {
            block()
        }
    }
}

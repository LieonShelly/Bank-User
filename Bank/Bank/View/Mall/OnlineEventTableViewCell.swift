//
//  OnlineEventTableViewCell.swift
//  Bank
//
//  Created by yang on 16/6/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OnlineEventTableViewCell: UITableViewCell {

    @IBOutlet fileprivate var coverImageViews: [UIImageView]!
    var tapHandleBlock: ((_ segueID: String, _ banner: Banner) -> Void)?
    var banners: [Banner]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ banners: [Banner]) {
        self.banners = banners
        for (banner, imageView) in zip(banners, coverImageViews) {
            imageView.setImage(with: banner.imageURL, placeholderImage: R.image.image_default_large())
            imageView.contentMode = .scaleAspectFill
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            imageView.addGestureRecognizer(tap)
        }
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        let view = tap.view
        if let block = tapHandleBlock,
            let tag = view?.tag,
            let banner = banners?[tag] {
            block(R.segue.mallHomeViewController.showTrendEvent.identifier, banner)
        }
    }
    
}

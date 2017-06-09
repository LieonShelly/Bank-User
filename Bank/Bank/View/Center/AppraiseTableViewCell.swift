//
//  AppraiseTableViewCell.swift
//  Bank
//
//  Created by yang on 16/3/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AppraiseTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var startStackView: UIStackView!
    @IBOutlet fileprivate var starImageView: [UIImageView]!
    var goods: Goods?
    fileprivate lazy var tap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    }()
    fileprivate lazy var pan: UIPanGestureRecognizer = {
       return UIPanGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    }()
    var grade: Float = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configInfo(_ goods: Goods) {
        self.goods = goods
        goodsImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        titleLabel.text = goods.title
        if goods.source == 0 {
            startStackView.addGestureRecognizer(tap)
            startStackView.addGestureRecognizer(pan)
        }
        configStars(goods.source)

    }
    
    @objc fileprivate func tapAction(_ tap: UIGestureRecognizer) {
        let point = tap.location(in: startStackView)
        for i in 0..<5 {
            let imageView = starImageView[i]
            if point.x > imageView.frame.origin.x {
                imageView.image = R.image.ico_stars_o()
                grade = Float(imageView.tag + 1)
            } else {
                imageView.image = R.image.ico_stars_g()
            }
            
            let firstImageView = starImageView[0]
            if point.x < firstImageView.frame.origin.x {
                grade = 0
            }
        }
        
    }
    
    fileprivate func configStars(_ source: Float) {
        for imageView in starImageView {
            if Int(source) > imageView.tag {
                imageView.image = R.image.ico_stars_o()
            } else {
                imageView.image = R.image.ico_stars_g()
            }
        }
    }
    
}

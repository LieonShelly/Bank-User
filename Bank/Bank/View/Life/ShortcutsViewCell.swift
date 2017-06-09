//
//  ShortcutsViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/24.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class ShortcutsViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var hotTag: UIImageView!
    
    fileprivate var menu: QuickMenu?
    
    var buttonTapBlock: ((_ menu: QuickMenu?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        hotTag.isHidden = true
        imageView.image = R.image.btn_add()
        imageView.isUserInteractionEnabled = false
    }
    
    func configShortcuts(_ menu: QuickMenu, index: NSIndexPath, isHome: Bool) {
        self.menu = menu
        if index.section == 0 {
            if index.row <= 4 {
                if isHome {
                    imageView.setImage(with: menu.icon, placeholderImage: R.image.image_default_small())
                } else {
                    imageView.setImage(with: menu.editIcon, placeholderImage: R.image.image_default_small())
                }
            } else {
                imageView.setImage(with: menu.icon, placeholderImage: R.image.image_default_small())
            }
        } else {
            imageView.setImage(with: menu.icon, placeholderImage: R.image.image_default_small())
        }
//        if menu.menuName == "日常任务" || menu.menuName == "我的订单" || menu.menuName == "我的信用" || menu.menuName == "消费券" {
//        } else {
//            imageView.setImage(with: menu.icon, placeholderImage: R.image.image_default_small())
//        }
        if let image = menu.image {
            imageView.image = image
        }
        
        nameLabel.text = menu.menuName
        if menu.isHot == true {
            hotTag.isHidden = false
        }
        
        button.addTarget(self, action: #selector(self.buttonTap(_:)), for: .touchUpInside)
    }
    
    func buttonTap(_ sender: UIButton) {
        guard let block = buttonTapBlock else {
            return
        }
        block(menu)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hotTag.isHidden = true
    }

}

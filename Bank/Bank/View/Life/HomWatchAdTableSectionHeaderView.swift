//
//  HomWatchAdTableSectionHeaderView.swift
//  Bank
//
//  Created by lieon on 2016/10/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Kingfisher

class HomWatchAdTableSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var button: UIButton!
    
    var moreHandleBlock: ((_ type: HomeSection) -> Void)?
    var homeSectionType: HomeSection? {
        didSet {
            titleLabel.text = homeSectionType?.name
        }
    }
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var imageButtonHeightCons: NSLayoutConstraint!
    private var constant: CGFloat = 0
    var baner: Banner? {
        didSet {
            if let url = self.baner?.imageURL {
                imageButton.kf.setImage(with: url, for: .normal)
                imageButtonHeightCons.constant = constant
            } else {
                imageButtonHeightCons.constant = 0
            }
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageButton.imageView?.contentMode = .scaleAspectFill
        constant = self.imageButtonHeightCons.constant
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        guard let block = moreHandleBlock, let type = homeSectionType else {
            return
        }
        block(type)
    }
}

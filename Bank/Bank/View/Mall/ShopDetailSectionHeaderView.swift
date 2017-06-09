//
//  ShopDetailSectionHeaderView.swift
//  Bank
//
//  Created by yang on 16/2/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
// swiftlint:disable private_outlet

import UIKit
typealias OpneOrCloseHandleBlock = (_ sender: UIButton?) -> Void
class ShopDetailSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet fileprivate weak var sectionImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var arrawImageView: UIImageView!
    var isOpen: Bool = true {
        didSet {
            if isOpen == true {
                arrawImageView.transform = CGAffineTransform(rotationAngle: 0)
            } else {
                arrawImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        }
    }
    var openOrCloseHandleBlock: OpneOrCloseHandleBlock?
    var sectionTitle: String? {
        didSet {
            titleLabel.text = sectionTitle
        }
    }
    
    var sectionImage: UIImage? {
        didSet {
            sectionImageView.image = sectionImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        if let block = openOrCloseHandleBlock {
            block(nil)
        }

    }

    @IBAction func openOrCloseAction(_ sender: UIButton) {
        if let block = openOrCloseHandleBlock {
            block(sender)
        }
    }

}

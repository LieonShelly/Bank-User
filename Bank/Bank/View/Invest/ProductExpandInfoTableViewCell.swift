//
//  ProductBaseInfoTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/8.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ProductExpandInfoTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    @IBOutlet private weak var contentLabel: UILabel!
    
    @IBOutlet private var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet private var contentBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var contentHeightConstraint: NSLayoutConstraint!
    
    private var isExpand: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        setExpand(false)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configData(data: (String, String)) {
        nameLabel.text = data.0
        contentLabel.text = data.1
    }
    
    private func setExpand(expand: Bool) {
        if expand == true {
            viewBottomConstraint.active = false
            contentTopConstraint.active = true
            contentBottomConstraint.active = true
            isExpand = true
            indicatorImageView.transform = CGAffineTransformIdentity
        } else {
            contentLabel.hidden = true
            contentTopConstraint.active = false
            contentBottomConstraint.active = false
            viewBottomConstraint.constant = 0.0
            viewBottomConstraint.active = true
            isExpand = false
            indicatorImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
    
    func toggleExpand() {
        setExpand(!isExpand)
    }
    
    func toggleContentLabel() {
        if isExpand == true {
            contentLabel.hidden = false
        } else {
            contentLabel.hidden = true
        }
    }
    
}

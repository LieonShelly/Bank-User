//
//  TagButton.swift
//  Bank
//
//  Created by yang on 16/6/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class TagButton: UIButton {

    var tagView: UIButton?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = imageView, let titleLabel = titleLabel else {
            return
        }
        let titleViewFrame = titleLabel.frame
        let imageFrame = imageView.frame
        if tagView == nil {
            tagView = UIButton(type: .custom)
            if let view = tagView {
                addSubview(view)
            }
        }
        tagView?.setBackgroundImage(R.image.mall_integral_icon_point(), for: .normal)
        tagView?.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        if titleViewFrame.origin.x > imageFrame.origin.x {
            tagView?.frame = CGRect(x: titleViewFrame.origin.x + titleViewFrame.width + 5, y: titleViewFrame.origin.y - 5, width: 13, height: 13)
        } else {
            tagView?.frame = CGRect(x: imageFrame.origin.x + imageFrame.width - 8, y: -5, width: 13, height: 13)
        }
        tagView?.isUserInteractionEnabled = false
        tagView?.isHidden = true
    }

}

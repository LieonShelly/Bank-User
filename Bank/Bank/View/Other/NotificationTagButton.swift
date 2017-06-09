//
//  NotificationTagView.swift
//  Bank
//
//  Created by Herb on 16/7/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class NotificationTagButton: UIButton {
    
    var notificationTagView: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = imageView, let titleLabel = titleLabel else {
            return
        }
        let titleViewFrame = titleLabel.frame
        let imageFrame = imageView.frame
        notificationTagView = UIButton(type: .custom)
        addSubview(notificationTagView)
        notificationTagView.setBackgroundImage(R.image.mall_integral_icon_point(), for: .normal)
        notificationTagView.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        if titleViewFrame.origin.x > imageFrame.origin.x {
            notificationTagView?.frame = CGRect(x: titleViewFrame.origin.x + titleViewFrame.width + 12, y: titleViewFrame.origin.y - 5, width: 13, height: 13)
        } else {
            notificationTagView.frame = CGRect(x: imageFrame.origin.x + imageFrame.width, y: -5, width: 6, height: 6)
        }
        notificationTagView.isUserInteractionEnabled = false
        notificationTagView.isHidden = true
    }
    
}

//
//  VerticalButton.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

@IBDesignable
class VerticalButton: UIButton {

    @IBInspectable var topPadding: CGFloat = 9.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = imageView, let titleLabel = titleLabel else {
            return
        }
        var titleLabelFrame = titleLabel.frame
        
        let size = CGSize(width: contentRect(forBounds: bounds).width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = titleLabel.sizeThatFits(size)
        var imageFrame = imageView.frame
        
        let fitBoxSize = CGSize(width: max(imageFrame.size.width, labelSize.width), height: labelSize.height + topPadding + imageFrame.size.height)
        
        let fitBoxRect = bounds.insetBy(dx: (bounds.size.width - fitBoxSize.width) / 2, dy: (bounds.size.height - fitBoxSize.height) / 2)
        
        imageFrame.origin.y = fitBoxRect.origin.y
        imageFrame.origin.x = fitBoxRect.midX - imageFrame.width / 2
        imageView.contentMode = .scaleAspectFit
        imageView.frame = imageFrame
        
        titleLabelFrame.size.width = labelSize.width
        titleLabelFrame.size.height = labelSize.height
        titleLabelFrame.origin.x = (self.frame.size.width / 2) - (labelSize.width / 2)
        titleLabelFrame.origin.y = fitBoxRect.origin.y + imageFrame.size.height + topPadding
        titleLabel.frame = titleLabelFrame
        titleLabel.textAlignment = .center

    }
    
}

extension UIButton {
    
    /**
     初始化一个tag button
     
     - parameter text:  tag 标题
     - parameter color: 颜色
     
     - returns: tag button
     */
    
    convenience init?(text: String, color: UIColor) {
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 17)))
        setTitle(text, for: UIControlState())
        guard var bgImage = R.image.tag_frame() else {
            return nil
        }
        bgImage = bgImage.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        setBackgroundImage(bgImage, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 11)
        titleLabel?.textAlignment = .center
        isUserInteractionEnabled = false
    }
}

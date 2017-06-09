//
//  orderButton.swift
//  Bank
//
//  Created by 糖otk on 2017/1/10.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable force_unwrapping
// swiftlint:disable empty_count
import UIKit

class OrderButton: UIButton {
    
    lazy var tapButton: UIButton = {
       let tapButton = UIButton()
        tapButton.backgroundColor = UIColor.red
        tapButton.frame = CGRect(x: self.frame.width*0.5, y: 7, width: 17, height: 17)
        tapButton.titleLabel?.font = UIFont.systemFont(ofSize: 7)
        tapButton.setTitleColor(UIColor.white, for: .normal)
        tapButton.layer.cornerRadius = 8
        return tapButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        set()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        set()
    }
    
    func set() {
        
        addSubview(self.tapButton)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleLabel?.textAlignment = .center
        tapButton.isHidden = true
        sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = imageView {
            imageView.frame = CGRect(origin: CGPoint(x: (self.frame.width - (imageView.frame.size.width)) * 0.5, y: 17), size: imageView.frame.size)
            titleLabel?.frame = CGRect(x: 0, y: imageView.frame.origin.y + imageView.frame.size.height + 10, width: self.frame.size.width, height: 12)
        }
        var count = 0
        if let text = tapButton.titleLabel?.text, let temp = Int(text) {
            count = temp
        }
        tapButton.isHidden = count == 0
        let title = min(count, 99)
        tapButton.setTitle("\(title)")
        tapButton.frame = count > 9 ? CGRect(x: 39, y: 7, width: 20, height: 17) : CGRect(x: 39, y: 7, width: 17, height: 17)
    }
}

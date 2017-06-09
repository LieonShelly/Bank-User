//
//  StackButtonView.swift
//  Bank
//
//  Created by Koh Ryu on 11/20/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

typealias ButtonHandleBlock = (_ buttonTag: Int) -> Void

class StackButtonView: UIView {
    
    @IBOutlet fileprivate var stackView: UIStackView!
    
    var buttonHandleBlock: ButtonHandleBlock?

    func configWithImages(_ images: [UIImage?]) {
        for idx in 0..<images.count {
            let button = UIButton(type: .custom)
            button.tag = idx
            button.setImage(images[idx], for: UIControlState())
            button.backgroundColor = UIColor.white
            button.addTarget(self, action: #selector(self.buttonHandle(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            
            if images.count >= 2 && idx != images.count - 1 {
                let view = UIView()
                view.backgroundColor = UIColor(hex: CustomKey.Color.lineColor)
                view.frame = CGRect(x: frame.width / CGFloat(images.count) * CGFloat(idx + 1), y: 0, width: 0.5, height: frame.height)
                addSubview(view)
            }
        }
    }
    
    func buttonHandle(_ sender: UIButton) {
        if let block = buttonHandleBlock {
            block(sender.tag)
        }
    }

}

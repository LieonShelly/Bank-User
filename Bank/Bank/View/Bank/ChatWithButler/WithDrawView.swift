//
//  WithDrawView.swift
//  Bank
//
//  Created by lieon on 16/8/15.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class WithDrawView: UIView {
    @IBOutlet fileprivate weak var titleLabelBottomCons: NSLayoutConstraint!

    var titleText: String = String()
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    func configData(_ title: String) {
         titleText = title
        titleLabel.text = title
    }
    
    func viewHeight(_ title: String) -> CGFloat {
        
        print("WithDrawView:\(title)")
        configData(title)
        self.layoutIfNeeded()
        print("WithDrawView\(titleLabel.frame.maxY+10)")
        return titleLabel.frame.maxY + 10

    }

}

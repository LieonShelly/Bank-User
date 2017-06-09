//
//  WinInfoView.swift
//  Bank
//
//  Created by yang on 16/7/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class WinInfoView: UIView {
    
    @IBOutlet weak fileprivate var mobileLabel: UILabel!
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    
    override func awakeFromNib() {
        
    }
    
    func configInfo(_ data: WinInfo) {
        if let mobile = data.mobile {
            mobileLabel.text = "恭喜\(mobile)"
        }
        if let title = data.title {
            titleLabel.text = "获得\(title)"
        }
    }

}

//
//  NoneBindUserView.swift
//  Bank
//
//  Created by yang on 16/6/2.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class NoneBindUserView: UIView {
    var applyUserHandleBlock: (() -> Void)?
    override func awakeFromNib() {
        
    }
    
    @IBAction func applyAction(_ sender: UIButton) {
        if let block = applyUserHandleBlock {
            block()
        }
    }
    
}

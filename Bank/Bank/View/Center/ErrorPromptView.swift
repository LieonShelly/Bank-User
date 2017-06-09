//
//  ErrorPromptView.swift
//  Bank
//
//  Created by 杨锐 on 16/7/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ErrorPromptView: UIView {
    var buttonHandleBlock: (() -> Void)?
    override func awakeFromNib() {
        
    }

    @IBAction func findPassAction(_ sender: UIButton) {
        if let block = buttonHandleBlock {
            block()
        }
    }
}

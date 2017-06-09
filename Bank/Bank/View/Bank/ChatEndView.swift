//
//  ChatEndView.swift
//  Bank
//
//  Created by lieon on 16/8/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

typealias FunctionBlocks = () -> Void

class ChatEndView: UIView {
    
    var btnClickBlock: FunctionBlocks?
    @IBOutlet fileprivate weak var commentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentButton.layer.cornerRadius = 3
        commentButton.layer.masksToBounds = true
        commentButton.layer.borderColor = UIColor.colorFromHex(0x00a8fe).cgColor
        commentButton.layer.borderWidth = 1
    }
    
    func evaluteButtonClick() {
        if let block = btnClickBlock {
            block()
        }
    }
    
    @IBAction func commentButtonClick(_ sender: AnyObject) {
        self.evaluteButtonClick()
    }
    
}

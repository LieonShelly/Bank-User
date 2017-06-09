//
//  MallHomeCheckInView.swift
//  Bank
//
//  Created by yang on 16/6/22.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MallHomeCheckInView: UIView {

    @IBOutlet fileprivate weak var infoLabel: UILabel!
    var deleteHandleBlock: (() -> Void)?
    
    override func awakeFromNib() {
//        infoLabel.attributedText = NSAttributedString(leftString: R.string.localizable.string_title_register(), rightString: "+20积分", leftColor: UIColor(hex: 0x1c1c1c), rightColor: UIColor.orange, leftFontSize: 17, rightFoneSize: 20)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        addGestureRecognizer(tap)
    }
    
    func configInfo(_ point: Int?) {
        if let pointNumber = point {
            infoLabel.attributedText = NSAttributedString(leftString: "+\(pointNumber)", rightString: "积分", leftColor: UIColor.white, rightColor: UIColor.white, leftFontSize: 50, rightFoneSize: 18)
        }
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        if let block = deleteHandleBlock {
            block()
        }
    }
}

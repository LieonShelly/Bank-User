//
//  ChatEndCollectionViewCell.swift
//  Bank
//
//  Created by lieon on 16/8/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

typealias FunctionBlock = () -> Void

class ChatEndCollectionViewCell: UICollectionViewCell {
    var btnClickBlock: FunctionBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(icon)
        contentView.addSubview(textLabel)
        contentView.addSubview(evaluteButton)
        contentView.addSubview(dividerLine)
        icon.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(5)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        evaluteButton.snp.makeConstraints { (make) in
            make.left.equalTo(textLabel.snp.right).offset(5)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(20)
        }
        dividerLine.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
    
    fileprivate lazy var icon: UIImageView = UIImageView(image: R.image.chat_plaint())
    fileprivate lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.text = R.string.localizable.bank_chat_With_Butler_chat_end()
        return label
    }()
    fileprivate lazy var evaluteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(R.string.localizable.button_title_evaluate())
        btn.setTitleColor(UIColor.lightGray, for: UIControlState())
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.addTarget(self, action: #selector(self.evaluteButtonClick), for: UIControlEvents.touchUpInside)
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.borderColor = UIColor.colorFromHex(0x00a8fe)
        btn.borderWidth = 1
        return btn
    }()
    fileprivate lazy var dividerLine: UIImageView = UIImageView(image: R.image.chat_line())
    
    func evaluteButtonClick() {
        if let block = btnClickBlock {
            block()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

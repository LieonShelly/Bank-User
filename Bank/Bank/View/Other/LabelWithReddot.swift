//
//  LableWithReddot.swift
//  Bank
//
//  Created by Koh Ryu on 16/8/31.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class LabelWithReddot: UIView {

    fileprivate var redSize = CGSize(width: 6, height: 6)
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.isUserInteractionEnabled = true
        view.font = .systemFont(ofSize: 15)
        view.textColor = UIColor.gray
        return view
    }()
    
    fileprivate lazy var reddot: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action:#selector(self.tap))
    }()
    
    var index: Int = 0
    var noticeCategory: NoticeCategory?
    var tapHandle: ((_ view: LabelWithReddot) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(reddot)
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(snp.centerX)
            make.centerY.equalTo(snp.centerY)
        }
        reddot.snp.makeConstraints { (make) in
            make.leading.equalTo(label.snp.trailing)
            make.top.equalTo(8)
            make.size.equalTo(redSize)
        }
        reddot.isHidden = true
        addGestureRecognizer(tapGesture)
    }
    
    func showReddot(_ show: Bool) {
        reddot.isHidden = !show
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func tap() {
        setSelected(true)
        if let block = tapHandle {
            block(self)
        }
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            label.textColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        } else {
            label.textColor = UIColor.gray
        }
    }

}

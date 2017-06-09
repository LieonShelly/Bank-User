//
//  GuideCollectionViewCell.swift
//  Bank
//
//  Created by Tzzzzz on 16/8/10.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class GuideCollectionViewCell: UICollectionViewCell {
    
    var containerVC: ContainerViewController?

    lazy var guideImageView: UIImageView = {
        let guideImageView = UIImageView(frame:self.bounds)
        return guideImageView
    }()
    lazy var nextBtn: UIButton = {
        let nextBtn = UIButton()
        nextBtn.setImage(UIImage(named: "btn_next"), for: UIControlState())
        nextBtn.sizeToFit()
        nextBtn.addTarget(self, action: #selector(self.clickNextBtn), for: .touchUpInside)
        nextBtn.center.y = UIScreen.main.bounds.height * 0.8
        nextBtn.center.x = UIScreen.main.bounds.width * 0.5
        return nextBtn
    }()
    
    func congfigImage(_ image: UIImage?) {
        self.contentView.addSubview(guideImageView)
        self.guideImageView.image = image
    }
    
    func setStarBtnHidden(_ indexPath: IndexPath, count: Int) {
        if indexPath.item == count - 1 {
            self.contentView.addSubview(nextBtn)
            nextBtn.isHidden = false
        } else {
            nextBtn.isHidden = true
        }
    }
    
    func clickNextBtn() {
        NotificationCenter.default.post(name: .nextBtnClickNotifacation, object: self)
    }
}

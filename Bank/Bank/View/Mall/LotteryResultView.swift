//
//  LotteryResultView.swift
//  Bank
//
//  Created by yang on 16/7/18.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class LotteryResultView: UIView {

    @IBOutlet fileprivate weak var backButton: UIButton!
    @IBOutlet fileprivate weak var closeButton: UIButton!
    @IBOutlet fileprivate weak var coverImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var shareButton: UIButton!
    var prize: Prize?
    //是否可以通过分享再获得一次抽奖机会
    var isShareGetTime: Bool = false
    var shareHandleBlock: (() -> Void)?
    var cancelHandleBlock: (() -> Void)?
    var backHandleBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /**
     设置弹框的样式
     
     - parameter isStart: 活动是否开始
     */
    func configUI(_ isStart: Bool, isShareGetTime: Bool) {
        self.isShareGetTime = isShareGetTime
        closeButton.isHidden = !isStart
        backButton.isHidden = isStart
        shareButton.isEnabled = isStart
        if isStart {
            // 活动已经开始
            titleLabel.textColor = UIColor(hex: 0x555555)
            shareButton.setTitle(nil, for: UIControlState())
            if isShareGetTime {
                // 分享可再抽一次
                coverImageView.image = R.image.icon_cry9()
                coverImageView.contentMode = .scaleAspectFit
                shareButton.setImage(R.image.lottery_btn_share1(), for: .normal)
                titleLabel.text = R.string.localizable.label_title_share_agin()
            } else {
                // 机会已经用完
                coverImageView.image = R.image.icon_cry1()
                coverImageView.contentMode = .scaleAspectFit
                titleLabel.text = R.string.localizable.label_title_use_chance()
                shareButton.setImage(R.image.lottery_btn_share(), for: .normal)
            }
        } else {
            //活动未开始
            coverImageView.image = R.image.icon_cry9()
            coverImageView.contentMode = .scaleAspectFit
            titleLabel.textColor = UIColor(hex: 0x1c1c1c)
            titleLabel.text = R.string.localizable.label_title_new_lottery()
            shareButton.setTitle(R.string.localizable.label_title_expect(), for: UIControlState())
            shareButton.setImage(nil, for: UIControlState())
            shareButton.setTitleColor(UIColor.orange, for: UIControlState())
            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
            
        }
    }

    func configInfo(_ data: Prize) {
        if data.prizeID == "0" {
            coverImageView.image = R.image.icon_cry()
            coverImageView.contentMode = .scaleAspectFit
            titleLabel.text = R.string.localizable.label_title_sorry()
            if data.shareToGetTime == true {
                shareButton.setImage(R.image.lottery_btn_share1(), for: .normal)
            } else {
                shareButton.setImage(R.image.lottery_btn_share(), for: .normal)
            }
            
        } else {
            coverImageView.contentMode = .scaleAspectFill
            coverImageView.setImage(with: data.cover, placeholderImage: R.image.image_default_midden())
            if let title = data.title {
                titleLabel.text = "恭喜获得\(title)"
            }
            shareButton.setImage(R.image.lottery_btn_share3(), for: .normal)
        }
    }
    
    /**
     分享
     */
    @IBAction func shareAction(_ sender: UIButton) {
        if let block = shareHandleBlock {
            block()
        }
    }
    
    /**
     关闭
    */
    @IBAction func closeAction(_ sender: UIButton) {
        if let block = cancelHandleBlock {
            block()
        }
    }
    
    /**
     返回
    */
    @IBAction func backAction(_ sender: UIButton) {
        if let block = backHandleBlock {
            block()
        }
    }
}

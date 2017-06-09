//
//  AdvertTableViewCell.swift
//  Bank
//
//  Created by yang on 16/1/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AdvertTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var advertImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    @IBOutlet fileprivate weak var joinNumberLabel: UILabel!
    @IBOutlet fileprivate weak var playButton: UIButton!
    @IBOutlet fileprivate weak var endTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ obj: Advert) {
        playButton.isHidden = true
        advertImageView.setImage(with: obj.imageURL, placeholderImage: R.image.image_default_midden())
        titleLabel.text = obj.title
        if let number = obj.joinNumber {
            joinNumberLabel.text = "\(number)人参加"
        }
        if let endTime = obj.endTime {
            endTimeLabel.text = "\(endTime)结束"
        }
        if obj.type == .video {
            playButton.isHidden = false
            playButton.setImage(R.image.btn_play(), for: .normal)
        } else if obj.type == .webPage {
            playButton.isHidden = false
            playButton.setImage(R.image.btn_link(), for: .normal)
        }
        pointLabel.attributedText = NSAttributedString(amountNumber: Int(obj.point), leftString: "", rightString: "积分", color: UIColor(hex: 0xfe8d00), amountFontSize: 25, leftStringFontSize: 24, rightStringFontSize: 13)
        //pointLabel.amountWithUnit(Float(obj.point), amountFontSize: 25, unitFontSize: 13, unit: "积分")
        if obj.isJoin == false {
            statusLabel.isHidden = true
        } else {
            statusLabel.isHidden = false
            statusLabel.text = R.string.localizable.label_title_joined()
        }
    }
    
}

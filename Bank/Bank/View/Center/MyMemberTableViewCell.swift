//
//  MyMemberTableViewCell.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
typealias ActiveActionHandleBlock = () -> Void

class MyMemberTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    @IBOutlet fileprivate weak var phoneNumberLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var headImageView: UIImageView!
    @IBOutlet fileprivate weak var activeButton: UIButton!
    @IBOutlet fileprivate weak var moreImageView: UIImageView!
    @IBOutlet fileprivate weak var contributionLabel: UILabel!
    @IBOutlet fileprivate weak var nicknameLabel: UILabel!
    var activeActionHandleBlock: ActiveActionHandleBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pointLabel.textColor = UIColor(hex: UInt32(0xfe8d00))
        self.selectionStyle = .none
    }

    func conforInfo(_ member: Member) {
        titleLabel.text = member.remark
        if member.name == "" {
            nicknameLabel.text = "(昵称)"
        } else {
            nicknameLabel.text = "(\(member.nickName))"
        }
        headImageView.setImage(with: member.imageURL, placeholderImage: R.image.head_default())
        phoneNumberLabel.text = member.mobile
        if member.status == .invited {
            nicknameLabel.isHidden = true
            pointLabel.isHidden = true
            moreImageView.isHidden = true
            contributionLabel.isHidden = true
            activeButton.isHidden = false
        } else {
            nicknameLabel.isHidden = false
            pointLabel.isHidden = false
            moreImageView.isHidden = false
            contributionLabel.isHidden = false
            activeButton.isHidden = true
            pointLabel.amountWithUnit(Float(member.point), color: UIColor.orange, amountFontSize: 20, unitFontSize: 15, unit: "积分")
        }
    }
    
    //邀请激活
    @IBAction func activeAction(_ sender: UIButton) {
        if let block = activeActionHandleBlock {
            block()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        
    }
    
}

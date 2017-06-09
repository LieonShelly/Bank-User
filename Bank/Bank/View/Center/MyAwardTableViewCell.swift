//
//  MyAwardTableViewCell.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

public enum ActionStatus: String {
    case reward
    case detail
    case outDate
}

class MyAwardTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var buttonHandleBlock: (() -> Void)?
    var actionStatus: ActionStatus?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(award: Award) {
        if let date = award.created?.toString("yyyy-MM-dd HH:mm:ss") {
            dateLabel.text = "\(date)"
        }

        if let code = award.code?.couponString() {
            codeLabel.text = "消费码：\(code)"
        }
        nameLabel.text = award.goodsTitle
        avatarImageView.setImage(with: award.logo, placeholderImage: R.image.image_default_midden())
        if let status = award.awardStatus {
            switch status {
                // 打赏
            case .notAward:
                button.isHidden = false
                button.setTitle(R.string.localizable.butotn_title_ogratuity())
                button.backgroundColor = UIColor(hex: 0xfe8d00)
                button.setTitleColor(UIColor.white, for: .normal)
                button.layer.borderWidth = 0
                button.layer.cornerRadius = 2
                button.layer.borderColor = nil
                statusImageView.image = nil
                // 查看详情
            case .awarded:
                button.isHidden = false
                button.setTitle(R.string.localizable.butotn_title_look_details())
                button.backgroundColor = UIColor.white
                button.setTitleColor(UIColor(hex: 0x1C1C1C), for: .normal)
                button.layer.borderColor = UIColor(hex: 0x666666).cgColor                
                button.layer.borderWidth = 0.5
                button.layer.cornerRadius = 2
                statusImageView.image = R.image.icon_has_been_hit()
                // 国旗
            case .outDate:
                button.isHidden = true
                statusImageView.image = R.image.icon_expired()
            }
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        if let block = buttonHandleBlock {
            block()
        }
    }

}

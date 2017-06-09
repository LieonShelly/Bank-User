//
//  AccountActionTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AccountActionTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var firstStackViews: UIStackView!
    @IBOutlet fileprivate weak var secondStackView: UIStackView!
    
    var buttonBlock: ((_ actionType: DetailActionType) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configButtons(_ titles: [String]) {
        for i in 0..<titles.count {
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor.colorFromHex(0x007EFF)
            button.setTitle(titles[i], for: UIControlState())
            button.cornerRadius = 2.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            button.tag = i
            button.addTarget(self, action: #selector(self.buttonHandle(_:)), for: .touchUpInside)
            if titles[i].characters.isEmpty {
                button.isUserInteractionEnabled = false
                button.backgroundColor = UIColor.clear
            }
            if i < 3 {
                firstStackViews.addArrangedSubview(button)
            } else {
                secondStackView.addArrangedSubview(button)
            }
        }
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        guard let actionType = DetailActionType(rawValue: sender.tag), let delegate = buttonBlock else {
            return
        }
        delegate(actionType)
    }
    
}

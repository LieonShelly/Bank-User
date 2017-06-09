//
//  ShoppingGoodsEventTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ShoppingGoodsEventTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var choiceImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var typeLabel: UILabel!
    @IBOutlet fileprivate weak var leadConstraint: NSLayoutConstraint!
    
    var openHandleBlock: (() -> Void)?
    var selectedEventID: String?
    var eventMode: EventMode?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            choiceImageView.image = R.image.btn_choice_yes_1()
        } else {
            choiceImageView.image = R.image.btn_choice_no()
        }
    }
    
    func configInfo(_ event: OnlineEvent) {
        titleLabel.text = event.promo
        typeLabel.text = event.typeName
        if eventMode == .checkEvent {
            leadConstraint.constant = 20
            choiceImageView.isHidden = true
        } else {
            leadConstraint.constant = 55
            choiceImageView.isHidden = false
        }
    }
    
}

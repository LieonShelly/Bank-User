//
//  AnswerQuestionTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/1.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class AnswerQuestionTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var idLabel: UILabel!
    @IBOutlet fileprivate weak var contentTextLabel: UILabel!
    @IBOutlet fileprivate weak var theView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            theView.borderColor = UIColor(hex: CustomKey.Color.mainBlueColor)
            idLabel.textColor = UIColor(hex: CustomKey.Color.mainBlueColor)
            contentTextLabel.textColor = UIColor(hex: CustomKey.Color.mainBlueColor)
            
        } else {
            theView.borderColor = UIColor.lightGray
            idLabel.textColor = UIColor.black
            contentTextLabel.textColor = UIColor.black
        }
    }
    
    func configData(_ data: AdvertAnswer) {
        idLabel.text = data.answerID
        contentTextLabel.text = data.text
    }
}

//
//  BankAnnounceCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/5/24.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class BankAnnounceCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configData(_ news: News) {
        
        dateLabel.text = news.createdTime?.toDateString("yyyy-MM-dd HH:mm")
        contentLabel.text = news.summary
        titleLabel.text = news.title
        if news.isRead == false {
            backImage.image = UIImage(named: "btn_bg_ public")
        } else {
            backImage.image = UIImage(named: "btn_bg1_ public")
        }
    }
    
}

//
//  RankListTableViewCell.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class RankListTableViewCell: UITableViewCell {

    @IBOutlet weak var noImageView: UIImageView!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(data: AwardRank) {
        
        headImageView.setImage(with: data.avatar, placeholderImage: R.image.head_default())
        nameLabel.text = data.name
        mobileLabel.text = data.mobile
        if let times = data.times {
            timesLabel.text = "\(times)次"
        }
    }
    
}

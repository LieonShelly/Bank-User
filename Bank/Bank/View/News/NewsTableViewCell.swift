//
//  NewsTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 11/23/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var contentLabel: UILabel!
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var dateLbel: UILabel!
    @IBOutlet weak fileprivate var newsImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        dateLbel.textColor = UIColor(hex: 0x666666)
        titleLabel.textColor = UIColor(hex: 0x1c1c1c)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellDataConfig(_ cellData: News) {
        contentLabel.text = cellData.summary
        newsImageView.setImage(with: cellData.cover, placeholderImage: R.image.image_default_midden())
        dateLbel.text = cellData.createdTime?.toString("yyyy-MM-dd HH:mm")
        titleLabel.text = cellData.title
    }
    
}

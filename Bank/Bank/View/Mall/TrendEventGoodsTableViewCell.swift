//
//  TrendEventGoodsTableViewCell.swift
//  Bank
//
//  Created by yang on 16/1/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class TrendEventGoodsTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var trendEventImageView: UIImageView!
    @IBOutlet fileprivate weak var goodsNameLabel: UILabel!
    @IBOutlet fileprivate weak var eventDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configInfo(_ data: OnlineEvent) {
        trendEventImageView.setImage(with: data.imageURL, placeholderImage: R.image.image_default_large())
        goodsNameLabel.text = data.title
        if let startTime = data.startTime?.toString("yyyy-MM-dd HH:mm"), let endTime = data.endTime?.toString("yyyy-MM-dd HH:mm") {
            eventDateLabel.text = startTime + "至" + endTime
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

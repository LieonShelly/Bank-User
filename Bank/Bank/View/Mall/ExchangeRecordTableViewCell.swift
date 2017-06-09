//
//  ExchangeRecordTableViewCell.swift
//  Bank
//
//  Created by kilrae on 2017/4/27.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ExchangeRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configInfo(data: PointObject) {
        if let point = data.point, let money = data.money {
            pointLabel.text = String(point) + "积分" + "(\(money)元)"
        }
        dateLabel.text = data.redeemCreated?.toString("yyyy-MM-dd HH:mm")
        statusLabel.text = data.approveStatus?.text
    }
    
}

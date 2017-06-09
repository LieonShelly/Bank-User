//
//  OrderDeliveryTableViewCell.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderDeliveryTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var deliveryLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var phonelabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    var order: Order!
    var detailLinkHandleBlock: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ order: Order) {
        self.order = order
        if let shipment = order.shipment {
            deliveryLabel.text = shipment.dynamic
            if let time = shipment.time {
                timeLabel.text = time.toString("yyyy-MM-dd HH:mm:ss")
            }
            
        }
        nameLabel.text = order.cneeName
        phonelabel.text = order.mobile
        addressLabel.text = order.address
    }
    
    @IBAction func moreDeliveryAction(_ sender: UIButton) {
        if let block = detailLinkHandleBlock {
            block()
        }
    }
}

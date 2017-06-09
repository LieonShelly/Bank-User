//
//  OrderInfoTableViewCell.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderInfoTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var numberLabel: UILabel!
    @IBOutlet fileprivate weak var infoStackView: UIStackView!
    fileprivate var createTimeLabel: UILabel!
    fileprivate var payTimeLabel: UILabel!
    fileprivate var shipTimeLabel: UILabel!
    fileprivate var arrivarTimeLabel: UILabel!
    fileprivate var closeTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ order: Order) {
        if let number = order.orderNumber {
            numberLabel.text = "订单编号：" + number
        }
        for view in infoStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        if let createdTime = order.created {
            createTimeLabel = createdLabel()
            infoStackView.addArrangedSubview(createTimeLabel)
            createTimeLabel.text = "创建时间：" + createdTime.toString("yyyy-MM-dd HH:mm:ss")
        }
        
        if let payTime = order.payTime {
            payTimeLabel = createdLabel()
            infoStackView.addArrangedSubview(payTimeLabel)
            payTimeLabel.text = "付款时间：" + payTime.toString("yyyy-MM-dd HH:mm:ss")
        }
        
        if let shipTime = order.shipTime {
            shipTimeLabel = createdLabel()
            infoStackView.addArrangedSubview(shipTimeLabel)
            shipTimeLabel.text = "发货时间：" + shipTime.toString("yyyy-MM-dd HH:mm:ss")
        }

        if let arrivalTime = order.arrivalTime {
            arrivarTimeLabel = createdLabel()
            infoStackView.addArrangedSubview(arrivarTimeLabel)
            arrivarTimeLabel.text = "成交时间：" + arrivalTime.toString("yyyy-MM-dd HH:mm:ss")
        }

        if let closeTime = order.closeTime {
            closeTimeLabel = createdLabel()
            infoStackView.addArrangedSubview(closeTimeLabel)
            closeTimeLabel.text = "关闭时间：" + closeTime.toString("yyyy-MM-dd HH:mm:ss")
        }

    }
    
    fileprivate func createdLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }
    
}

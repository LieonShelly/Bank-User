//
//  MyOrderSectionHeaderView.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MyOrderSectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet fileprivate weak var sotreNameLabel: UILabel!
    @IBOutlet fileprivate weak var orderStatusLabel: UILabel!
    
    var tapHandleBlock: ((_ merchantID: String) -> Void)?
    
    fileprivate var merchantID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        orderStatusLabel.textColor = UIColor.orange
        sotreNameLabel.textColor = UIColor.darkGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        if let block = tapHandleBlock, let merchantID = merchantID {
            block(merchantID)
        }
    }
    
    /**
     设置普通订单信息
     
     - parameter order: 普通订单
     */
    func configInfo(_ order: Order) {
        sotreNameLabel.text = order.storeName
        orderStatusLabel.text = order.status?.text
        merchantID = order.merchantID
    }
    
    /**
     设置退款订单信息
     
     - parameter order: 退款订单
     */
    func configRefundOrderInfo(_ order: RefundOrder) {
        sotreNameLabel.text = order.storeName
        orderStatusLabel.text = order.status?.serviceText
        merchantID = order.merchantID
    }
}

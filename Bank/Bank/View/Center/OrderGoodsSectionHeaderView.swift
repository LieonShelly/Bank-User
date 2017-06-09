//
//  OrderGoodsSectionHeaderView.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderGoodsSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet fileprivate weak var storeNameLabel: UILabel!
    var callHandleBlock: ((_ tel: String) -> Void)?
    var order: Order!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storeNameLabel.textColor = UIColor(hex: 0x1c1c1c)
    }
    
    func configInfo(_ order: Order) {
        self.order = order
        storeNameLabel.text = order.storeName
    }
    
    //拨打电话
    @IBAction func callAction(_ sender: UIButton) {
        if let tel = order.storeTel, let block = callHandleBlock {
            block(tel)
        }
    }
    
}

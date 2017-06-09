//
//  ShopAddressTableViewCell.swift
//  Bank
//
//  Created by yang on 16/2/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ShopAddressTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    fileprivate var tel: String?
    var telHandleBlock: ((_ tel: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func configInfo(_ data: Store) {
        titleLabel.text = data.name
        addressLabel.text = data.address
        tel = data.tel
        phoneButton.setImage(R.image.ic_list_call(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        if let block = telHandleBlock {
            if let tel = self.tel {
                block(tel)
            }
        }
    }
    
}

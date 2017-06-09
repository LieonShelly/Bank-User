//
//  OrderSubmitSuccessTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class OrderSubmitSuccessTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var selectButton: UIButton!
    @IBOutlet fileprivate weak var orderNumberLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var shopNameLabel: UILabel!
    @IBOutlet fileprivate weak var shopIconImageView: UIImageView!
    @IBOutlet fileprivate weak var imageStackView: UIStackView!
    
    var selectedHandleBlock: ((_ order: Order, _ sender: UIButton) -> Void)?
    var gotoOrderDetailHandleBlock: ((_ segueID: String) -> Void)?
    var order: Order!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.setImage(R.image.btn_choice_yes(), for: .selected)
        selectButton.setImage(R.image.btn_choice_no(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configInfo(_ order: Order) {
        self.order = order
        selectButton.isSelected = order.isCheck
        if let no = order.orderNumber {
            orderNumberLabel.text = R.string.localizable.mall_ordernumber(no)
        }
        priceLabel.text = "\(order.totalPrice.numberToString())元"
        shopNameLabel.text = order.storeName
        guard let goodsList = order.goodsList else { return }
        for (goods, view) in zip(goodsList.suffix(4), imageStackView.arrangedSubviews) {
            guard let imageURL = goods.imageURL, let imageView = view as? UIImageView else { continue }
            imageView.setImage(with: imageURL, placeholderImage: R.image.image_default_midden())
        }
    }
    
    @IBAction func selectedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let block = selectedHandleBlock {
            block(self.order, sender)
        }
    }
    
    @IBAction func gotoOrderDetailAction(_ sender: UIButton) {
        if let block = gotoOrderDetailHandleBlock {
            block(R.segue.orderSubmitSuccessViewController.showOrderDetailVC.identifier)
        }
    }
    
}

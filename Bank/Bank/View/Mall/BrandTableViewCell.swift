//
//  BrandTableViewCell.swift
//  Bank
//
//  Created by yang on 16/2/23.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import SnapKit
import Device

typealias BrandDetailHandleBlock = (_ segueID: String, _ merchant: Merchant) -> Void

class BrandTableViewCell: UITableViewCell {
        
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var discountView: UIView!
//    @IBOutlet weak var discountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var merchantView: UIView!
    
    var brandDetailHandleBlock: BrandDetailHandleBlock?
    var goodsDetailHandleBlcok: GoodsDetailHandleBlock?
    var openDiscountHandleBlock: ((_ merchantID: String) -> Void)?
    
    fileprivate var selectedMerchant: Merchant?
    fileprivate var selectedGoods: Goods?
    fileprivate var goodsArray: [Goods] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if Device.size() == .screen5_5Inch {
            stackView.spacing = 35
        } else {
            stackView.spacing = 15
        }
        for _ in 0..<3 {
            guard let goodsView = R.nib.featureGoodsCollectionCell.firstView(owner: nil) else {
                return
            }
            stackView.addArrangedSubview(goodsView)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoBrandDetailAction(_:)))
        merchantView.addGestureRecognizer(tap)
    }
    
    func configInfo(_ data: Merchant) {
        selectedMerchant = data
        logoImageView.setImage(with: data.logo, placeholderImage: R.image.image_default_small())
        nameLabel.text = data.name
        if let content = data.storeDetail {
            desLabel.text = content
        }
        if let array = data.goodsList {
            goodsArray = array
        }
        setDiscountView()
        for i in 0..<3 {
            guard let goodsView = stackView.arrangedSubviews[i] as? FeatureGoodsCollectionCell else {
                return
            }
            if i >= goodsArray.count {
                goodsView.alpha = 0
            } else {
                goodsView.alpha = 1
                goodsView.configGoods(goodsArray[i])
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
                goodsView.addGestureRecognizer(tap)
            }
        }
        
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view as? FeatureGoodsCollectionCell else {
            return
        }
        if let blcok = goodsDetailHandleBlcok {
            if let goods = view.goods {
                selectedGoods = goods
                blcok(R.segue.mallHomeViewController.showGoodsDetailVC.identifier, goods)
            }
        }
    }
    
    func gotoBrandDetailAction(_ tap: UITapGestureRecognizer) {
        if let block = brandDetailHandleBlock, let merchant = selectedMerchant {
            block(R.segue.mallHomeViewController.showBrandDetialVC.identifier, merchant)
        }
    }
    
    func setDiscountView() {
        var items: [[Discount]] = []
        if let discountArray = selectedMerchant?.privilegeList?.filter({ return $0.type == .discount }) {
            if discountArray.isEmpty == false {
                items.append(discountArray)
            }
        }
        if let fullCutArray = selectedMerchant?.privilegeList?.filter({ return $0.type == .fullCut }) {
            if fullCutArray.isEmpty == false {
                items.append(fullCutArray)
            }
        }
        if !items.isEmpty {
            for (i, item) in zip(items.indices, items) {
                guard let view = R.nib.discountView.firstView(owner: nil) else {
                    return
                }
                view.frame = CGRect(x: 0.0, y: CGFloat(i) * 30.0, width: screenWidth, height: 30.0)
                view.configInfo(discounts: item)
                if i == 0 {
                    view.openButton.isHidden = false
                    view.openHandleBlock = {
                        if let block = self.openDiscountHandleBlock {
                            if let merchantID = self.selectedMerchant?.merchantID {
                                block(merchantID)
                            }
                        }
                    }
                }
                discountView.addSubview(view)
            }

        }
//        discountViewHeight.constant = CGFloat(items.count * 30)
    }
    
    override func prepareForReuse() {
//        discountViewHeight.constant = 60
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

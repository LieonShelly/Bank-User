//
//  BrandZoneView.swift
//  Bank
//
//  Created by yang on 16/1/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit
import Device
typealias GoodsDetailHandleBlock = (_ segueID: String, _ selectedGoods: Goods) -> Void

class BrandZoneView: UIView {

    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var contentLabel: UILabel!
    @IBOutlet fileprivate weak var goodsStackView: UIStackView!
    @IBOutlet fileprivate weak var gotoBrandDetailButton: UIButton!
    @IBOutlet weak var moreImageView: UIImageView!
    var brandDetailHandleBlock: BrandDetailHandleBlock?
    var goodsDetailHandleBlcok: GoodsDetailHandleBlock?
    fileprivate var goodsArray: [Goods] = []
    fileprivate var selectedMerchant: Merchant?
    fileprivate var selectedGoods: Goods!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if Device.size() == .screen5_5Inch {
            goodsStackView.spacing = 35
        } else {
            goodsStackView.spacing = 15
        }
        for _ in 0..<3 {
            guard let goodsView = R.nib.featureGoodsCollectionCell.firstView(owner: nil) else {
                return
            }
            goodsStackView.addArrangedSubview(goodsView)
        }
    }
    
    func conforData(_ data: Merchant) {
        selectedMerchant = data
        iconImageView.setImage(with: data.logo, placeholderImage: R.image.image_default_small())
        gotoBrandDetailButton.addTarget(self, action: #selector(gotoBrandDetailAction(_:)), for: .touchUpInside)
        titleLabel.text = data.name
        if let content = data.storeDetail {
            contentLabel.text = content
        }
        if let array = data.goodsList {
            goodsArray = array
        }
        
        for i in 0..<goodsArray.count {
            guard let goodsView = goodsStackView.arrangedSubviews[i] as? FeatureGoodsCollectionCell else {
                return
            }
            goodsView.configGoods(goodsArray[i])
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            goodsView.addGestureRecognizer(tap)
        }
        
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view as? FeatureGoodsCollectionCell else {
            return
        }
        if let goods = view.goods {
            selectedGoods = goods
        }
        if let blcok = goodsDetailHandleBlcok {
            blcok(R.segue.mallHomeViewController.showGoodsDetailVC.identifier, selectedGoods)
        }
    }
    
    func gotoBrandDetailAction(_ sender: UIButton) {
        if let block = brandDetailHandleBlock, let merchant = selectedMerchant {
            block(R.segue.mallHomeViewController.showBrandDetialVC.identifier, merchant)
        }
    }
}

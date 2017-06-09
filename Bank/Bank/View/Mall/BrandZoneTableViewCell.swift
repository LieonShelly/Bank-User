//
//  BrandZoneTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class BrandZoneTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var cycleView: UIView!
    lazy var pageController: CyclePageViewController = {
        return CyclePageViewController(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.frame.height))
    }()
    var selectedGoods: Goods?
    var brandDetailHandleBlock: BrandDetailHandleBlock?
    var goodsDetailHandleBlcok: GoodsDetailHandleBlock?
    var goodsArray: [Goods] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
    }
    
    func setCyclePageController(_ merchants: [Merchant]) {
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for i in 0..<merchants.count {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            let addView = R.nib.brandZoneView.firstView(owner: nil)
            addView?.moreImageView.isHidden = true
            addView?.brandDetailHandleBlock = { (segueID, merchant) in
                if let block = self.brandDetailHandleBlock {
                    block(segueID, merchant)
                }
            }
            addView?.goodsDetailHandleBlcok = { segueID, goods in
                if let blcok = self.goodsDetailHandleBlcok {
                    blcok(segueID, goods)
                }
            }
            addView?.conforData(merchants[i])
            if let view = addView {
                addViews.append(view)
            }
        }
        pageController.configDataSource(viewControllers: viewControllers, addViews: addViews, isAutoScroller: false)
        cycleView.addSubview(pageController.view)
        pageController.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

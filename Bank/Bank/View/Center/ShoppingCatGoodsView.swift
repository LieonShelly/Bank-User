//
//  ShoppingCatGoodsView.swift
//  Bank
//
//  Created by yang on 16/7/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ShoppingCatGoodsView: UIView {

    @IBOutlet fileprivate weak var collectionButton: VerticalButton!
    @IBOutlet fileprivate weak var deleteButton: VerticalButton!
    @IBOutlet fileprivate weak var goodsView: UIView!
    @IBOutlet fileprivate weak var isChoiceButton: UIButton!
    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var goodsInfoLabel: UILabel!
    @IBOutlet fileprivate weak var goodsPriceLabel: UILabel!
    @IBOutlet fileprivate weak var goodsNumberLabel: UILabel!
    @IBOutlet fileprivate weak var numberChangeView: UIView!
    @IBOutlet weak var changeEventButton: UIButton!
    @IBOutlet fileprivate weak var bottomConstaint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var invalidLabel: UILabel!
    @IBOutlet fileprivate weak var invalidButton: UIButton!
    @IBOutlet fileprivate weak var propertyLabel: UILabel!
    
    var tableView: UITableView?
    fileprivate var tapG: UITapGestureRecognizer?
    fileprivate var panG: UIPanGestureRecognizer?
    
    fileprivate lazy var gotoGoodsDetailTap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(gotoGoodsDetailAction(_:)))
    }()
    var deleteHandleBlock: ((_ goodsID: String) -> Void)?
    var collectionHandleBlock: ((_ goodsID: String) -> Void)?
    var selectHandleBlock: ((_ goodsID: String, _ merchantID: String, _ isChecked: Bool) -> Void)?
    var gotoGoodsDetailHandleBlock: ((_ goodsID: String) -> Void)?
    var numberChangeHandleBlock: ((_ goodsID: String, _ number: Int, _ stockNum: Int) -> Void)?
    var changeEventHandleBlock: ((_ goodsID: String) -> Void)?
    var goods: Goods?
    fileprivate var goodsID: String?
    var state: Bool = false {
        didSet {
            if state == true {
                hiddenButtonView()
                removeGestureRecognizer()
            } else {
                showButtonView()
            }
        }
    }

    override func awakeFromNib() {
        isChoiceButton.setImage(R.image.btn_choice_yes(), for: .selected)
        isChoiceButton.setImage(R.image.btn_choice_no(), for: .normal)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.showButtonView))
        leftSwipe.direction = .left
        goodsView.addGestureRecognizer(leftSwipe)
        
        goodsView.addGestureRecognizer(gotoGoodsDetailTap)
        //外部通知，把cell改回原来的状态
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeToDefaultFrame), name: NSNotification.Name(rawValue: "changeFrame"), object: nil)

    }
    
    //设置商品信息
    func configInfo(_ goods: Goods) {
        self.goods = goods
        propertyLabel.isHidden = true
        goodsImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        goodsInfoLabel.text = goods.title
        goodsPriceLabel.amountWithUnit(goods.price, amountFontSize: 15, unitFontSize: 15, unit: "¥", decimalPlace: 2)
        goodsNumberLabel.text = String(goods.num)
        isChoiceButton.isSelected = goods.isChecked
        self.goodsID = goods.goodsID

//        if goods.eventCount <= 1 {
////            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.width, height: 106))
//            changeEventButton.alpha = 0
//            bottomConstaint.constant = 0
//        } else {
//            bottomConstaint.constant = 34
//        }
        if goods.status == .onSale {
            //未失效商品
            isChoiceButton.isHidden = false
            invalidLabel.isHidden = true
            invalidButton.isHidden = true
        } else {
            //失效商品
            isChoiceButton.isHidden = true
            invalidLabel.isHidden = false
            invalidButton.isHidden = false
        }
        if !goods.propertyList.isEmpty {
            propertyLabel.isHidden = false
            let descList = goods.propertyList.flatMap { return $0.desc() }
            propertyLabel.text = descList.joined(separator: ";")
        }
    }
    
    // 修改数量
    @IBAction func numberChangeAction(_ sender: UIButton) {
        if let block = numberChangeHandleBlock,
            let goodsID = goods?.goodsID,
            let num = goods?.num, let stockNum = goods?.stockNum {
            block(goodsID, num, stockNum)
        }
    }
    // 跳转商品详情
    func gotoGoodsDetailAction(_ tap: UITapGestureRecognizer) {
        if let block = gotoGoodsDetailHandleBlock, let goodsID = goodsID {
            block(goodsID)
        }
    }
    
    //点击删除
    @IBAction func deleteAction(_ sender: VerticalButton) {
        removeGestureRecognizer()
        state = true
        if let block = deleteHandleBlock, let goodsID = goods?.goodsID {
            block(goodsID)
        }
    }
    //点击收藏
    @IBAction func collectionAction(_ sender: VerticalButton) {
        removeGestureRecognizer()
        state = true
        if let block = collectionHandleBlock, let goodsID = goods?.goodsID {
            block(goodsID)
        }
    }
    
    //点击选择框
    @IBAction func isChoiceClick(_ sender: UIButton) {
        isChoiceButton.isSelected = !isChoiceButton.isSelected
        if let block = selectHandleBlock,
            let goodsID = goods?.goodsID,
            let merchantID = goods?.merchantID {
            block(goodsID, merchantID, isChoiceButton.isSelected)
        }
    }

    //修改优惠
    @IBAction func changeEventAction(_ sender: UIButton) {
        if let block = changeEventHandleBlock, let goodsID = goods?.goodsID {
            block(goodsID)
        }
    }
    
    func removeGestureRecognizer() {
        if let tap = tapG, let pan = panG {
            tableView?.removeGestureRecognizer(tap)
            tableView?.removeGestureRecognizer(pan)
        }
    }
    
    func changeToDefaultFrame() {
        state = true
    }

    func showButtonView() {
        deleteButton.alpha = 1
        collectionButton.alpha = 1
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            if self.goods?.status == .onSale {
                self.goodsView.frame = CGRect(x: -150, y: self.goodsView.frame.origin.y, width: self.goodsView.frame.width, height: self.goodsView.frame.height)
            } else {
                self.goodsView.frame = CGRect(x: -75, y: self.goodsView.frame.origin.y, width: self.goodsView.frame.width, height: self.goodsView.frame.height)
            }
        }) 
        tableView?.isScrollEnabled = false
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.tableAction))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tableAction))
        tableView?.addGestureRecognizer(tap)
        tableView?.addGestureRecognizer(pan)
        tapG = tap
        panG = pan
        goodsView.removeGestureRecognizer(gotoGoodsDetailTap)
    }
    
    func tableAction() {
        state = true
        goodsView.addGestureRecognizer(gotoGoodsDetailTap)
    }
    
    func hiddenButtonView() {
        
        UIView.animate(withDuration: 0.2, animations: { 
            self.goodsView.frame = CGRect(x: 0, y: self.goodsView.frame.origin.y, width: self.goodsView.frame.width, height: self.goodsView.frame.height)
            }, completion: { (isFinished) in
                if isFinished {
                    
                }
        }) 
        tableView?.isScrollEnabled = true
    }

}

//
//  ShoppingGoodsTableViewCell.swift
//  Bank
//
//  Created by yang on 16/1/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

typealias DeleteHandleBlock = () -> Void
typealias CollectionHandleBlock = () -> Void
typealias SelectHandleBlock = () -> Void
private var tableView: UITableView?
private var tapG: UITapGestureRecognizer!
private var panG: UIPanGestureRecognizer!

class ShoppingGoodsTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var theView: UIView!
    @IBOutlet fileprivate weak var isChoiceButton: UIButton!
    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var goodsInfoLabel: UILabel!
    @IBOutlet fileprivate weak var goodsPriceLabel: UILabel!
    @IBOutlet fileprivate weak var goodsNumberLabel: UILabel!
    @IBOutlet fileprivate weak var invalidLabel: UILabel!
    
    var deleteHandleBlock: DeleteHandleBlock?
    var collectionHandleBlock: CollectionHandleBlock?
    var selectHandleBlock: SelectHandleBlock?
    var changeNumberHandkeBlock: ((_ number: Int) -> Void)?
    fileprivate var number: Int = 0
    var goods: Goods?
    var state: Bool? {
        didSet {
            if state == true {
                hiddenButtonView()
                removeTableViewGestureRecognizer()
            } else {
                showButtonView()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isChoiceButton.setImage(R.image.btn_choice_yes(), for: .selected)
        isChoiceButton.setImage(R.image.btn_choice_no(), for: .normal)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.showButtonView))
        leftSwipe.direction = .left
        addGestureRecognizer(leftSwipe)
        //外部通知，把cell改回原来的状态
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeToDefaultFrame), name: NSNotification.Name(rawValue: "changeFrame"), object: nil)
        
    }
    
    //设置商品信息
    func configInfo(_ goods: Goods) {
        self.goods = goods
        self.number = goods.num
        goodsImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        goodsInfoLabel.text = goods.title
        goodsPriceLabel.amountWithUnit(goods.price, amountFontSize: 15, unitFontSize: 15, unit: "¥", decimalPlace: 2)
        goodsNumberLabel.text = String(goods.num)
        isChoiceButton.isSelected = goods.isChecked
    }
    
    func removeTableViewGestureRecognizer() {
        tableView?.removeGestureRecognizer(tapG)
        tableView?.removeGestureRecognizer(panG)
    }
    
    func changeToDefaultFrame() {
        state = true
    }
    
    func showButtonView() {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "changeFrame"), object: nil)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.theView.frame = CGRect(x: -150, y: self.theView.frame.origin.y, width: self.theView.frame.width, height: self.theView.frame.height)
        }) 
        guard let tab = superview?.superview as? UITableView else {
            return
        }
        tableView = tab
        tableView?.isScrollEnabled = false
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.tableAction))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tableAction))
        tableView?.addGestureRecognizer(tap)
        tableView?.addGestureRecognizer(pan)
        tapG = tap
        panG = pan
    }
    
    func tableAction() {
        state = true
    }
    
    func hiddenButtonView() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.theView.frame = CGRect(x: 0, y: self.theView.frame.origin.y, width: self.theView.frame.width, height: self.theView.frame.height)
        }) 
        tableView?.isScrollEnabled = true
    }
    //点击删除
    @IBAction func deleteAction(_ sender: VerticalButton) {
        removeTableViewGestureRecognizer()
        state = true
        if let block = deleteHandleBlock {
            block()
        }
    }
    //点击收藏
    @IBAction func collectionAction(_ sender: VerticalButton) {
        removeTableViewGestureRecognizer()
        state = true
        if let block = collectionHandleBlock {
            block()
        }
    }

    @IBAction func isChoiceClick(_ sender: UIButton) {
        isChoiceButton.isSelected = !isChoiceButton.isSelected
        if let block = selectHandleBlock {
            block()
        }
    }
    
    @IBAction func minusClick(_ sender: UIButton) {
        number -= 1
        if number <= 0 {
            self.number = 1
            Navigator.showAlertWithoutAction(nil, message: "数量至少为1")
            return
        }
        if let block = changeNumberHandkeBlock {
            block(number)
        }
        goodsNumberLabel.text = String(number)
        
    }

    @IBAction func addClick(_ sender: UIButton) {
        if number > goods?.stockNum {
            Navigator.showAlertWithoutAction(nil, message: "库存不足")
            return
        }
        number += 1
        goodsNumberLabel.text = String(number)
        if let block = changeNumberHandkeBlock {
            block(number)
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

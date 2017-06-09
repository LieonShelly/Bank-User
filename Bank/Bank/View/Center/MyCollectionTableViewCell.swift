//
//  MyCollectionTableViewCell.swift
//  Bank
//
//  Created by yang on 16/1/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class MyCollectionTableViewCell: UITableViewCell {
    @IBOutlet fileprivate weak var goodsImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var newPriceLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var numberLabel: UILabel!
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet fileprivate weak var leadConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var trailConstraint: NSLayoutConstraint!
    
    fileprivate var tableView: UITableView?
    fileprivate lazy var leftSwipe: UISwipeGestureRecognizer = {
        return UISwipeGestureRecognizer(target: self, action: #selector(self.showButtonView))
    }()
    fileprivate lazy var tapG: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.tableAction))
    }()
    fileprivate lazy var panG: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.tableAction))
    }()
    var deleteHandleBlock: DeleteHandleBlock?
    
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
    var goods: Goods?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedButton.isHidden = true
        // Initialization code
        self.selectionStyle = .none
        selectedButton.setImage(R.image.btn_choice_no(), for: .normal)
        selectedButton.setImage(R.image.btn_choice_yes(), for: .selected)
        leftSwipe.direction = .left
        //外部通知，把cell改回原来的状态
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeToDefaultFrame), name: NSNotification.Name(rawValue: "changeFrame"), object: nil)
    }
    
    func configGoods(_ goods: Goods) {
        self.goods = goods
        goodsImageView.setImage(with: goods.imageURL, placeholderImage: R.image.image_default_midden())
        titleLabel.text = goods.title
        newPriceLabel.amountWithUnit(goods.price, amountFontSize: 17, unitFontSize: 17, unit: "¥", decimalPlace: 2)
        priceLabel.amountWithUnit(goods.marketPrice, color: UIColor(hex: 0xa0a0a0), amountFontSize: 13, unitFontSize: 13, strikethrough: true, unit: "¥", decimalPlace: 2)
        numberLabel.text = "已售\(goods.sellNum)份"
        infoLabel.text = goods.detail
        if isEditing == true {
//            for view in subviews {
//                if view.isKindOfClass(UIControl) {
//                    for subView in view.subviews {
//                        guard let imageView = subView as? UIImageView else {
//                            return
//                        }
//                        selected = goods.isChecked
//                        if goods.isChecked == true {
//                            imageView.image = R.image.btn_choice_yes()
//                        } else {
//                            imageView.image = R.image.btn_choice_no()
//                        }
//                        
//                    }
//                }
//            }
            removeGestureRecognizer(leftSwipe)
//            selected = goods.isChecked
            leadConstraint.constant = 50
            trailConstraint.constant = -33
        } else {
            addGestureRecognizer(leftSwipe)
            leadConstraint.constant = 17
            trailConstraint.constant = 13
        }
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
            self.theView.frame = CGRect(x: -80, y: self.theView.frame.origin.y, width: self.theView.frame.width, height: self.theView.frame.height)
        }) 
        guard let tab = superview?.superview as? UITableView else {
            return
        }
        tableView = tab
        tableView?.isScrollEnabled = false
        tableView?.addGestureRecognizer(tapG)
        tableView?.addGestureRecognizer(panG)
    }
    
    func tableAction() {
        state = true
    }
    
    //隐藏底部button
    func hiddenButtonView() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.theView.frame = CGRect(x: 0, y: self.theView.frame.origin.y, width: self.theView.frame.width, height: self.theView.frame.height)
        }) 
        tableView?.isScrollEnabled = true
    }
    @IBAction func deleteAction(_ sender: VerticalButton) {
        removeTableViewGestureRecognizer()
        state = true
        if let block = deleteHandleBlock {
            block()
        }

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if isEditing == true {
            for view in subviews {
                if view.isKind(of: UIControl.self) {
                    for subView in view.subviews {
                        guard let imageView = subView as? UIImageView else {
                            return
                        }
                        if selected == true {
                            imageView.image = R.image.btn_choice_yes()
                        } else {
                            imageView.image = R.image.btn_choice_no()
                        }
                        
                    }
                }
            }
        }
    }
    
}

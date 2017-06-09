//
//  GroupTableViewCell.swift
//  Bank
//
//  Created by yang on 16/7/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var stackView: UIStackView!
    @IBOutlet fileprivate weak var eventTypeNameLabel: UILabel!
    @IBOutlet fileprivate weak var eventPromoLabel: UILabel!
    @IBOutlet fileprivate weak var topConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var eventView: UIView!
    
    var tableView: UITableView?
    var deleteHandleBlock: ((_ goodsID: String) -> Void)?
    var collectionHandleBlock: ((_ goodsID: String) -> Void)?
    var selectHandleBlock: ((_ goodsID: String, _ merchntID: String, _ isChecked: Bool) -> Void)?
    var gotoGoodsDetailHandleBlock: ((_ goodsID: String) -> Void)?
    var changeEventHandleBlock: ((_ goodsID: String, _ selectedEventID: String) -> Void)?
    var numberChangeHandleBlock: ((_ goodsID: String, _ number: Int, _ stockNum: Int) -> Void)?
    var gotoEventDetailHandleBlock: ((_ eventID: String) -> Void)?
    fileprivate var eventID: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoEventDetailAction(_:)))
        eventView.addGestureRecognizer(tap)
    }
    
    func configInfo(_ group: Group) {
        var maxY: CGFloat = 0
        if let event = group.event {
            self.eventID = event.eventID
            if event.eventID == "" {
                topConstraint.constant = 0
                eventView.alpha = 0
            } else {
                eventTypeNameLabel.text = event.typeName
                eventPromoLabel.text = event.promo
                topConstraint.constant = 40
                eventView.alpha = 1
            }
        } else {
            topConstraint.constant = 0
            eventView.alpha = 0
        }
        
        if let goodsList = group.goodsList {
            for view in stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
            for goods in goodsList {
                guard let goodsView = R.nib.shoppingCatGoodsView.firstView(owner: nil) else {
                    return
                }
                goodsView.goods = goods
                goodsView.tableView = tableView
                guard let count = goods.eventCount else { return }
                if count <= 1 {
                    goodsView.frame = CGRect(x: 0.0, y: maxY, width: self.frame.width, height: 106.0)
                    maxY += 106
                    goodsView.changeEventButton.alpha = 0
                } else {
                    goodsView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 140)
                    maxY += 140
                    goodsView.changeEventButton.alpha = 1
                }
                goodsView.configInfo(goods)
                goodsView.selectHandleBlock = { (goodsID, merchantID, isChecked) in
                    self.selectAction(goodsID, merchantID: merchantID, isChecked: isChecked)
                    
                }
                goodsView.deleteHandleBlock = { goodsID in
                    self.deleteAction(goodsID)
                    
                }
                goodsView.collectionHandleBlock = { goodsID in
                    self.collectionAction(goodsID)
                    
                }
                goodsView.gotoGoodsDetailHandleBlock = { goodsID in
                    self.gotoGoodsDetailAction(goodsID)
                    
                }
                goodsView.changeEventHandleBlock = { goodsID in
                    self.eventChangeAction(goodsID)
                }
                goodsView.numberChangeHandleBlock = { (goodsID, number, stockNum) in
                    self.numberChangeAction(goodsID, number: number, stockNum: stockNum)
                }
                stackView.addArrangedSubview(goodsView)
            }
        }
    }
    
    func gotoEventDetailAction(_ tap: UITapGestureRecognizer) {
        if let block = gotoEventDetailHandleBlock, let eventID = eventID {
            block(eventID)
        }
    }
    
    fileprivate func selectAction(_ goodsID: String, merchantID: String, isChecked: Bool) {
        if let block = self.selectHandleBlock {
            block(goodsID, merchantID, isChecked)
        }
    }
    
    fileprivate func deleteAction(_ goodsID: String) {
        if let block = self.deleteHandleBlock {
            block(goodsID)
        }
    }

    fileprivate func collectionAction(_ goodsID: String) {
        if let block = self.collectionHandleBlock {
            block(goodsID)
        }
    }
    
    fileprivate func gotoGoodsDetailAction(_ goodsID: String) {
        if let block = self.gotoGoodsDetailHandleBlock {
            block(goodsID)
        }
    }
    
    fileprivate func numberChangeAction(_ goodsID: String, number: Int, stockNum: Int) {
        if let block = self.numberChangeHandleBlock {
            block(goodsID, number, stockNum)
        }
    }
    
    fileprivate func eventChangeAction(_ goodsID: String) {
        if let block = self.changeEventHandleBlock, let eventID = eventID {
            block(goodsID, eventID)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  MyOrderSectionFooterView.swift
//  Bank
//
//  Created by yang on 16/5/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class MyOrderSectionFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet fileprivate weak var infoLabel: UILabel!
    @IBOutlet fileprivate weak var firstButton: UIButton!
    @IBOutlet fileprivate weak var secondButton: UIButton!
    @IBOutlet fileprivate weak var thirdButton: UIButton!
    @IBOutlet fileprivate weak var refundButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    var firstHandleBlock: ((_ order: Order, _ actionType: OrderActionType) -> Void)?
    var gotoRefundDetailHandleBlock: ((_ selectedID: String?) -> Void)?
    var totalNumber: Int = 0
    var order: Order?
    fileprivate var refundOrder: RefundOrder?
    var orderActionType: OrderActionType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoLabel.textColor = UIColor(hex: 0x1c1c1c)
        priceLabel.textColor = UIColor.orange
    }
    
    enum OrderActionType {
        /// 付款
        case pay
        /// 取消订单
        case cancel
        /// 确认收货
        case confirm
        /// 申请退款
        case refund
        /// 查看物流
        case lookShip
        /// 评价
        case appraise
        /// 联系平台客服
        case contactService
        /// 钱款去向
        ///case MoneyGoing
        /// 删除订单
        case delete
    }
    
    @IBAction func firstButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 100:
            orderActionType = .refund
        default:
            break
        }
        if let block = firstHandleBlock,
            let order = order,
            let type = orderActionType {
            block(order, type)
        }
    }
    
    @IBAction func secondButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 200:
            orderActionType = .cancel
        case 201:
            orderActionType = .lookShip
        default:
            break
        }
        if let block = firstHandleBlock, let order = order, let type = orderActionType {
            block(order, type)
        }
    }
    
    @IBAction func thirdButtonAction(_ sender: UIButton) {
        switch sender.tag {
        case 300:
            orderActionType = .pay
        case 301:
            orderActionType = .confirm
        case 302:
            orderActionType = .appraise
//        case 303:
//            orderActionType = .delete
        case 304:
            orderActionType = .contactService
        case 305:
            orderActionType = .delete
        default:
            break
        }
        if let block = firstHandleBlock, let order = order, let type = orderActionType {
            block(order, type)
        }
    }
    
    /**
     跳转退款详情页
    */
    @IBAction func refundAction(_ sender: UIButton) {
        if let block = gotoRefundDetailHandleBlock {
            block(order?.refundID)
        }
    }
    
    /**
     设置普通订单信息
     
     - parameter order: 普通订单
     */
    func configInfo(_ order: Order) {
        self.order = order
        totalNumber = 0
        if let list = order.goodsList {
            for goods in list {
                totalNumber += goods.num
            }
        }
        let priceStr = order.totalPrice.numberToString()
        let deliveryCostStr = order.deliveryCost.numberToString()
        priceLabel.text = "\(priceStr)元"
        infoLabel.text = "共\(totalNumber)件商品(含运费\(deliveryCostStr)元) 合计:"
        if order.orderType == .merchandise && order.refundStatus != nil {
            refundButton.setTitle(order.refundStatus?.text, for: .normal)
            refundButton.isHidden = false
        } else {
            refundButton.isHidden = true
        }
        setOrderStatus()
    }
    
    /**
     设置退款订单信息
     
     - parameter order: 退款订单
     */
    func configRefundInfo(_ order: RefundOrder) {
        self.refundOrder = order
        totalNumber = 0
        if let goodsList = order.goodsList {
            for goods in goodsList {
                totalNumber += goods.num
            }
        }
        let priceStr = order.totalPrice.numberToString()
        let deliveryCostStr = order.deliveryCost.numberToString()
        priceLabel.text = "\(priceStr)元"
        infoLabel.text = "共\(totalNumber)件商品(含运费\(deliveryCostStr)元) 合计:"
        setRefundOrderStatus()
        refundButton.isHidden = true
    }
    
    /**
     设置普通订单状态下的操作
     */
    func setOrderStatus() {
        thirdButton.setTitle(order?.status?.actionText)
        firstButton.isHidden = true
        secondButton.isHidden = true
        thirdButton.isHidden = false
        secondButton.setTitleColor(UIColor(hex: 0x666666), for: UIControlState())
        secondButton.backgroundColor = UIColor.white
        secondButton.isEnabled = true
        secondButton.borderColor = UIColor(hex: 0x666666)
        if let status = order?.status {
            switch status {
            case .waitingPay:
                secondButton.isHidden = false
                secondButton.setTitle(R.string.localizable.button_title_cancel_order(), for: UIControlState())
                secondButton.tag = 200   // 取消订单
                thirdButton.tag = 300 // 付款
            case .waitingShip:
                thirdButton.isHidden = true
            case .shipped:
                firstButton.isHidden = false
                firstButton.setTitle(R.string.localizable.button_title_drawback())
                firstButton.tag = 100  // 申请退款
                // 已经申请退款后的订单申请退款不可点并且变灰
                if order?.refundStatus == .waiting || order?.refundStatus == .success {
                    firstButton.setTitleColor(UIColor.lightGray, for: UIControlState())
                    firstButton.backgroundColor = UIColor(hex: 0xf5f5f5)
                    firstButton.isEnabled = false
                    firstButton.borderColor = UIColor.lightGray
                } else {
                    firstButton.backgroundColor = UIColor.white
                    firstButton.setTitleColor(UIColor(hex: 0x666666), for: UIControlState())
                    firstButton.isEnabled = true
                    firstButton.borderColor = UIColor(hex: 0x666666)
                }
                secondButton.isHidden = false
                secondButton.setTitle(R.string.localizable.button_title_logistics(), for: UIControlState())
                secondButton.tag = 201  // 查看物流
                thirdButton.tag = 301 // 确认收货
            case .confirmed:
                if order?.orderType == .merchandise {
                    secondButton.isHidden = false
                    secondButton.setTitle(R.string.localizable.button_title_logistics())
                    secondButton.tag = 201 // 查看物流
                }
                thirdButton.setTitle(R.string.localizable.button_title_evaluation())
                if order?.isUserEvaluate == true {
                    thirdButton.setTitle(R.string.localizable.button_title_see_evaluation())
                }
                thirdButton.tag = 302  // 评价
            case .closed:
                thirdButton.isHidden = false
                thirdButton.tag = 305  // 删除订单
                break
            default:
                break
            }
            
        }
    }
    
    /**
     设置退款订单不同状态下的操作
     */
    func setRefundOrderStatus() {
        firstButton.isHidden = true
        secondButton.isHidden = true
        if let status = refundOrder?.status {
            switch status {
            case .success:
                thirdButton.isHidden = true
                thirdButton.tag = 303 // 钱款去向
            default:
                thirdButton.isHidden = false
                thirdButton.setTitle(refundOrder?.status?.actionText)
                thirdButton.tag = 304 // 联系客服
            }
        }
    }
}

extension UIButton {
    func setTitle(_ title: String!) {
        self.setTitle(title, for: UIControlState())
    }
}

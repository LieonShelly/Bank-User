//
//  RefundFlowView.swift
//  Bank
//
//  Created by kilrae on 2017/4/21.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class RefundFlowView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        
    }
    
    func configInfo(flow: RefundFlow, row: Int) {
        switch row {
        case 0:
            imageView.image = R.image.icon_apply()
            nameLabel.text = "申请退款"
            dateLabel.text = flow.updated?.toString("yyyy-MM-dd HH:mm:ss")
            infoLabel.isHidden = true
        case 1:
            imageView.image = R.image.icon_to_examine()
            nameLabel.text = "等待商家处理"
            dateLabel.isHidden = true
            infoLabel.isHidden = true
        case 2:
            imageView.image = R.image.icon_to_examine()
            if flow.result == .agree && flow.role == .merchant {
                nameLabel.text = "商家同意退款"
                imageView.image = R.image.icon_refund()
                nameLabel.textColor = UIColor(hex: 0x00a8fe)
                infoLabel.text = "退款具体到账时间请以您的账户时间为准"
            } else if flow.result == .agree && flow.role == .platfrom {
                nameLabel.text = "平台同意退款"
                imageView.image = R.image.icon_refund()
                nameLabel.textColor = UIColor(hex: 0x00a8fe)
                infoLabel.text = "退款具体到账时间请以您的账户时间为准"
            } else if flow.result == .refused && flow.role == .merchant {
                nameLabel.text = "商家拒绝退款"
                nameLabel.textColor = UIColor(hex: 0xfe192e)
                imageView.image = R.image.icon_refund_fail()
                infoLabel.text = "退款失败原因：商家拒绝退款，如有疑问请联系商家或者客服"
            } else if flow.result == .refused && flow.role == .user {
                nameLabel.text = "用户已确认收货"
                nameLabel.textColor = UIColor(hex: 0xfe192e)
                imageView.image = R.image.icon_refund_fail()
                infoLabel.text = "退款失败原因：用户已确认收货"
            }
            dateLabel.text = flow.updated?.toString("yyyy-MM-dd HH:mm:ss")
        case 3:
            imageView.image = R.image.icon_refund_fail02()
            nameLabel.text = "平台同意退款"
            dateLabel.text = flow.updated?.toString("yyyy-MM-dd HH:mm:ss")
            infoLabel.text = "退款具体到账时间请以您的账户时间为准"
            nameLabel.textColor = UIColor(hex: 0x00a8fe)
        default:
            break
        }
    }
    
    func configInfo(point: PointObject, row: Int) {
        switch row {
        case 0:
            imageView.image = R.image.icon_apply()
            nameLabel.text = "兑换申请已提交"
            dateLabel.text = point.redeemCreated?.toString("yyyy-MM-dd HH:mm:ss")
            infoLabel.isHidden = true
        case 1:
            imageView.image = R.image.icon_to_examine()
            nameLabel.text = "平台审核"
            dateLabel.text = "平台将在72小时内处理"
            infoLabel.isHidden = true
        case 2:
            if point.approveStatus == .success {
                nameLabel.text = "审核通过"
                imageView.image = R.image.icon_refund()
                nameLabel.textColor = UIColor(hex: 0x00a8fe)
                infoLabel.text = "具体到账时间请以您的账户时间为准"
            } else if point.approveStatus == .fail {
                nameLabel.text = "审核不通过"
                nameLabel.textColor = UIColor(hex: 0xfe192e)
                imageView.image = R.image.icon_refund_fail()
                infoLabel.isHidden = true
            }
            dateLabel.text = point.redeemUpdated?.toString("yyyy-MM-dd HH:mm:ss")
        default:
            break
        }
    }

}

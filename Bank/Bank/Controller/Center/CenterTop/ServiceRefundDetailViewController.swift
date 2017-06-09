//
//  ServiceRefundDetailViewController.swift
//  Bank
//
//  Created by 杨锐 on 16/8/2.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class ServiceRefundDetailViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var codeLabel: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var accountLabel: UILabel!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var createdTimeLabel: UILabel!
    @IBOutlet fileprivate weak var reasultLabel: UILabel!
    @IBOutlet fileprivate weak var failReasonLabel: UILabel!
    @IBOutlet fileprivate weak var refundTimeLabel: UILabel!
    @IBOutlet fileprivate weak var viewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var refundInfoLabel: UILabel!
    @IBOutlet fileprivate weak var refundImageView: UIImageView!
    @IBOutlet fileprivate weak var verticalLineView: UIView!
    @IBOutlet fileprivate weak var refundFlowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    var couponID: String?
    fileprivate var refundDetail: ServiceRefundDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        refundFlowView.isHidden = true
        title = R.string.localizable.center_myorder_refundDetail_title()
        requestRefundData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configUI() {
        codeLabel.text = refundDetail?.couponCode?.couponString()
        if let priceStr = refundDetail?.amount.numberToString() {
            priceLabel.text = "\(priceStr)元"
        }
        accountLabel.text = refundDetail?.refundAccount
        statusLabel.text = refundDetail?.status?.serviceText
        createdTimeLabel.text = refundDetail?.created?.toString("yyyy-MM-dd HH:mm:ss")
        if let status = refundDetail?.status {
            switch status {
            case .waiting:
                viewHeight.constant = 190
                verticalLineView.isHidden = true
            case .success:
                viewHeight.constant = 290
                verticalLineView.isHidden = false
                reasultLabel.textColor = UIColor(hex: 0x00a8fe)
                refundTimeLabel.text = refundDetail?.finishedTime?.toString("yyyy-MM-dd HH:mm:ss")
                reasultLabel.text = "审核通过"
                refundImageView.image = R.image.icon_refund()
            case .refuse:
                viewHeight.constant = 320
                verticalLineView.isHidden = false
                reasultLabel.textColor = UIColor(hex: 0xfe192e)
                reasultLabel.text = "审核不通过"
                refundInfoLabel.isHidden = true
                refundTimeLabel.isHidden = true
                refundImageView.image = R.image.icon_refund_fail()
            default:
                break
            }
        }
        refundFlowView.isHidden = false
    }
    
    /**
     请求退款详情
     */
    fileprivate func requestRefundData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.couponID = couponID
        let req: Promise<ServiceRefundDetailData> = handleRequest(Router.endpoint( OrderPath.order(.serviceRefundDetail), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.refundDetail = value.data
                self.configUI()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
 
    }

}

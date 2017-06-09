//
//  RefundDetailTableViewController.swift
//  Bank
//
//  Created by yang on 16/3/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class RefundDetailTableViewController: BaseTableViewController {

    @IBOutlet fileprivate weak var storeNameLabel: UILabel!
    @IBOutlet fileprivate weak var phoneLabel: UILabel!
    @IBOutlet fileprivate weak var refundTypeLabel: UILabel!
    @IBOutlet fileprivate weak var refundPriceLabel: UILabel!
    @IBOutlet fileprivate weak var refundReasonLabel: UILabel!
    @IBOutlet fileprivate weak var refundNumberLabel: UILabel!
    @IBOutlet fileprivate weak var refundStatusLabel: UILabel!
    @IBOutlet weak var refundAccountLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    var refundID: String?
    fileprivate var refundDetail: RefundDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x00a8fe)]
        requestRefundDetailData()
        setTableView()
        guard let controllersCount = navigationController?.viewControllers.count else {return}
        let vc = navigationController?.viewControllers[controllersCount - 2]
        if vc?.isKind(of: RefundGoodsTableViewController.self) == true {
            navigationController?.viewControllers.remove(at: controllersCount - 2)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RefundReasonTableViewController {
            vc.refundDetail = self.refundDetail
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func configUI() {
        guard let status = refundDetail?.status else {
            return
        }
        refundStatusLabel.text = status.merchandiseText
        storeNameLabel.text = refundDetail?.storeName
        phoneLabel.text = refundDetail?.tel
        refundTypeLabel.text = refundDetail?.typeName
        if let price = refundDetail?.amount {
            let priceStr = price.numberToString()
            refundPriceLabel.text = "\(priceStr)元"
        }
        refundReasonLabel.text = refundDetail?.reason
        refundNumberLabel.text = refundDetail?.refundNumber
        var height: CGFloat = 0
        if let account = refundDetail?.refundAccount {
            // TODO: 其他行的银行卡怎么办？
            refundAccountLabel.text = "绵商银行卡(尾号\(account))"
        }
        guard var flows = refundDetail?.flow else {
            return
        }
        if !flows.isEmpty {
            flows.insert(flows[0], at: 0)
        }
        print(flows)
        for i in 0..<flows.count {
            let flow = flows[i]
            guard let flowView = R.nib.refundFlowView.firstView(owner: nil) else {
                return
            }
            flowView.configInfo(flow: flow, row: i)
            if i == flows.count - 1 {
                flowView.lineView.isHidden = true
                if flow.result == .refused && flow.role == .user {
                    refundStatusLabel.text = status.merchandiseText + " 用户已确认收货"
                } else if flow.result == .refused && flow.role == .merchant {
                    refundStatusLabel.text = status.merchandiseText + " 商家已拒绝"
                }
            }
            height += 85
            stackView.addArrangedSubview(flowView)
        }
        stackViewHeight.constant = height
        if let tel = AppConfig.shared.baseData?.serviceHotLine {
            infoTextView.text = "为确保顺利退款，建议你在提交退款申请前先与商家电话沟通达成一致，并获取退货地址，如遇困难，您可拨打平台客服电话：\(tel)获取帮助，更多疑问请查看帮助中心"
        }
        tableView.reloadData()
    }

}

// MARK: - Request

extension RefundDetailTableViewController {
    func requestRefundDetailData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.refundID = self.refundID
        let req: Promise<RefundDetailData> = handleRequest(Router.endpoint( OrderPath.order(.refundDetail), param: param))
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

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RefundDetailTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if refundDetail != nil {
            return 3
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            return 160
        case (2, 0):
            return 40
        case (2, 1):
            return 160 + stackViewHeight.constant
        default:
            return 50
        }
    }
}

// MARK: - UITextViewDelegate
extension RefundDetailTableViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
    
    @available(iOS 10, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
}

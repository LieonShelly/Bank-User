//
//  CouponDetailViewController.swift
//  Bank
//
//  Created by yang on 16/3/30.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class CouponDetailViewController: BaseViewController {

    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var codeImageView: UIImageView!
    @IBOutlet fileprivate weak var codeNumberLabel: UILabel!
    @IBOutlet fileprivate weak var applyRefundButton: UIButton!
    @IBOutlet fileprivate weak var refundDetailButton: UIButton!
    @IBOutlet fileprivate weak var outOfDateLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var couponID: String?
    
    fileprivate var coupon: Coupon? {
        didSet {
            setInfo()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        headerView.frame = tableView.bounds
        tableView.tableFooterView = headerView
        refundDetailButton.isHidden = true
        applyRefundButton.backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(couponAwardStaff), name: .couponAwardStaff, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .couponAwardStaff, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    @objc func couponAwardStaff(_ notification: NSNotification) {
        self.requestData()
        guard let vc = R.storyboard.myAward.couponUseSuccessViewController() else {
            return
        }
        if let extra = notification.object as? [String: Any], let awardID = extra["award_id"] as? String {
            vc.awardID = awardID
        }
        vc.dismissBlock = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            self?.dim(.out)
            _ = self?.navigationController?.popViewController(animated: true)
        }
        vc.considerHandleBlock = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            self?.dim(.out)
            guard let vc = R.storyboard.myAward.myAwardViewController() else {
                return
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        vc.awardHandleBlock = { [weak self] awardID in
            vc.dismiss(animated: true, completion: nil)
            self?.dim(.out)
            guard let vc = R.storyboard.myAward.rewardViewController() else {
                return
            }
            vc.awardID = awardID
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        self.dim(.in)
        self.present(vc, animated: true, completion: nil)
    }
    
    func setInfo() {
        titleLabel.text = coupon?.goodsTitle
        if let dateString = coupon?.expireTime?.toString("yyyy-MM-dd") {
            dateLabel.text = "有效期至：\(dateString)"
        }
        if let code = coupon?.code {
            codeNumberLabel.text = code.couponString()
        }
        if let string = coupon?.qrcodeData {
            if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) {
                codeImageView.image = UIImage(data: data)
            }
        }
        codeNumberLabel.alpha = 1
        codeImageView.alpha = 1
        //判断是否退款
        if let status = coupon?.status {
            switch status {
            case .refunding, .refunded:
                outOfDateLabel.isHidden = true
                applyRefundButton.isEnabled = false
                applyRefundButton.backgroundColor = UIColor(hex: 0xdadada)
                applyRefundButton.setTitleColor(UIColor.gray, for: UIControlState())
                refundDetailButton.isHidden = false
            case .outOfDate:
                outOfDateLabel.isHidden = false
                codeImageView.alpha = 0.2
                codeNumberLabel.alpha = 0.2
                applyRefundButton.isEnabled = true
                applyRefundButton.backgroundColor = UIColor.white
                applyRefundButton.setTitleColor(UIColor.orange, for: UIControlState())
                refundDetailButton.isHidden = true
            case .used:
                outOfDateLabel.isHidden = true
                applyRefundButton.isEnabled = false
                applyRefundButton.backgroundColor = UIColor(hex: 0xdadada)
                applyRefundButton.setTitleColor(UIColor.gray, for: UIControlState())
            default:
                outOfDateLabel.isHidden = true
                applyRefundButton.isEnabled = true
                applyRefundButton.backgroundColor = UIColor.white
                applyRefundButton.setTitleColor(UIColor.orange, for: UIControlState())
                refundDetailButton.isHidden = true

            }
        }
    }
    
    //请求消费券详情
    func requestData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.couponID = couponID
        let req: Promise<CouponData> = handleRequest(Router.endpoint(OrderPath.order(.couponDetail), param: param))
        req.then { (value) -> Void in
            self.coupon = value.data
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = coupon?.goodsID
        }
        if let vc = segue.destination as? RefundServiceTableViewController {
            vc.couponID = self.couponID
            if let price = self.coupon?.price {
                vc.refundPrice = price
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //申请退款
    @IBAction func refundAction(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.couponDetailViewController.showRefundVC, sender: nil)
    }
    
    /// 查看退款详情
    @IBAction func gotoRefundDetailAction(_ sender: UIButton) {
        guard let vc = R.storyboard.myOrder.serviceRefundDetailViewController() else {
            return
        }
        vc.couponID = couponID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //点击进入商品详情
    @IBAction func gotoOrderDetailAction(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.couponDetailViewController.showGoodsDetailVC, sender: nil)
    }

}

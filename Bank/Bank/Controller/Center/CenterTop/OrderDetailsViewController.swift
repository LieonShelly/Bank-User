//
//  OrderDetailsViewController.swift
//  Bank
//
//  Created by yang on 16/3/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//  swiftlint:disable cyclomatic_complexity

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD
import Device

class OrderDetailsViewController: BaseViewController {
    
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var firstButton: UIButton!
    @IBOutlet fileprivate weak var secondButton: UIButton!
    @IBOutlet fileprivate weak var thirdButton: UIButton!
    @IBOutlet fileprivate weak var bottomHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    @IBOutlet fileprivate weak var deadlineDescLabel: UILabel!
    @IBOutlet fileprivate weak var statusImageView: UIImageView!
    @IBOutlet fileprivate weak var bottomToolView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var refundButton: UIButton!
    
    var orderID: String?
    fileprivate var isPriceUpdate: Bool = false
    fileprivate var selectedGoods: Goods!
    fileprivate var selectedCoupon: Coupon!
    fileprivate var order: Order?
    fileprivate var goodsList: [Goods] = []
    fileprivate var couponArray: [Coupon] = []
    fileprivate var orderDetailType: OrderDetailType?
    
    enum OrderDetailType {
        case address
        case withoutAddress
        case addressLogistics
        case coupons
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        if Device.size() == .screen4Inch {
            stackView.spacing = 8
        } else if Device.size() == .screen4_7Inch {
            stackView.spacing = 15
        } else if Device.size() == .screen5_5Inch {
            stackView.spacing = 30
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOrderInfo(_:)), name: .refreshOrderInfo, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods.goodsID
        }
        if let vc = segue.destination as? AppraiseViewController {
            vc.order = self.order
        }
        
        if let vc = segue.destination as? RefundGoodsTableViewController {
            vc.order = self.order
        }
        
        if let vc = segue.destination as? CouponDetailViewController {
            vc.couponID = self.selectedCoupon.couponID
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshOrderInfo, object: nil)
    }
    
    @IBAction func unwindOrderDetailFromRefundDetail(_ segue: UIStoryboardSegue) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func refreshOrderInfo(_ notification: Foundation.Notification) {
        self.isPriceUpdate = true
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(R.nib.orderInfoTableViewCell)
        tableView.register(R.nib.orderGoodsTableViewCell)
        tableView.register(R.nib.orderDeliveryTableViewCell)
        tableView.register(R.nib.orderAddressTableViewCell)
        tableView.register(R.nib.orderConsumeTableViewCell)
        tableView.register(R.nib.orderGoodsSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.orderGoodsSectionHeaderView.name)
        tableView.register(R.nib.orderGoodsSectionFooterView(), forHeaderFooterViewReuseIdentifier: R.nib.orderGoodsSectionFooterView.name)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func setUI() {
        statusLabel.text = order?.status?.detailText
        deadlineDescLabel.text = order?.deadlineDesc
        if order?.status == .waitingShip {
            bottomToolView.isHidden = true
            bottomHeight.constant = 0
        } else {
            bottomToolView.isHidden = false
            bottomHeight.constant = 60
        }
        firstButton.isHidden = true
        secondButton.isHidden = true
        secondButton.isEnabled = true
        secondButton.backgroundColor = UIColor.white
        thirdButton.isHidden = false
        guard let status = order?.status else {return}
        switch status {
        case .waitingPay:
            statusImageView.image = R.image.center_banner_order2()
            secondButton.isHidden = false
            secondButton.setTitle(R.string.localizable.button_title_cancel_order(), for: UIControlState())
            thirdButton.setTitle(R.string.localizable.button_title_pay(), for: UIControlState())
        case .waitingShip:
            statusImageView.image = R.image.center_banner_order4()
        case .shipped:
            statusImageView.image = R.image.center_banner_order5()
//            firstButton.isHidden = false
//            firstButton.setTitle(R.string.localizable.button_title_logistics(), for: UIControlState())
            secondButton.isHidden = false
            secondButton.setTitle(R.string.localizable.button_title_apply_drawback(), for: UIControlState())
            if order?.refundStatus == .success || order?.refundStatus == .waiting {
                secondButton.backgroundColor = UIColor.lightGray
                secondButton.isEnabled = false
            }
            thirdButton.setTitle(R.string.localizable.button_title_confirm_received(), for: UIControlState())
        case .confirmed:
            if order?.orderType == .merchandise {
//                secondButton.isHidden = false
                statusImageView.image = R.image.center_banner_order6()
//                secondButton.setTitle(R.string.localizable.button_title_logistics(), for: UIControlState())
            } else {
                secondButton.isHidden = true
                statusImageView.image = R.image.center_banner_order3()
            }
            if order?.isUserEvaluate == true {
                thirdButton.setTitle(R.string.localizable.button_title_see_evaluation(), for: UIControlState())
            } else {
                thirdButton.setTitle(R.string.localizable.button_title_evaluation(), for: UIControlState())
            }
        case .closed:
            statusImageView.image = R.image.center_banner_order2()
            thirdButton.setTitle(order?.status?.actionText, for: UIControlState())
        default:
            break
        }
        if order?.refundStatus != nil {
            refundButton.isHidden = false
            refundButton.setTitle(order?.refundStatus?.detailText, for: .normal)
        }
    }
    
    @IBAction func firstButtonAction(_ sender: UIButton?) {
        // 查看物流
//        if let vc = R.storyboard.myOrder.logisticsViewController() {
//            vc.orderID = self.orderID
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    @IBAction func secondButtonAction(_ sender: UIButton) {
        if let status = order?.status {
            switch status {
            case .waitingPay:
                //取消订单
                showAlertViewController(R.string.localizable.alertTitle_is_cancel_order(), actionType: 0)
                
            case .shipped:
                //申请退款 页面跳转
                self.performSegue(withIdentifier: R.segue.orderDetailsViewController.showGoodsRefundVC, sender: nil)
            case .confirmed:
                // 查看物流
//                self.firstButtonAction(nil)
                break
            default:
                break
            }
        }
    }
    
    @IBAction func thirdButtonAction(_ sender: UIButton) {
        if let status = order?.status {
            guard let order = self.order else {return}
            switch status {
            case .waitingPay:
                //付款
                if self.isPriceUpdate {
                    let alert = UIAlertController(title: "提示", message: R.string.localizable.alertTitle_order_price_update(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
                        self.requestData()
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.requestBankCardData(order: order)
                }
            case .shipped:
                // 确认收货
                self.showAlertViewController(R.string.localizable.alertTitle_confirm_receive(), actionType: 1)
            case .confirmed:
                // 评价
                if order.isCanEvaluate == true || order.isUserEvaluate == true {
                    self.performSegue(withIdentifier: R.segue.orderDetailsViewController.showAppraiseVC, sender: nil)
                } else {
                    Navigator.showAlertWithoutAction(nil, message: "消费后才能评价")
                }
            case .closed:
                // 删除订单
                self.showAlertViewController("确定删除该订单", actionType: 2)
            default:
                break
            }
            
        }
    }
    
    @IBAction func gotoRefundDetail(_ sender: UIButton) {
        guard let vc = R.storyboard.myOrder.refundDetailTableViewController() else {
            return
        }
        vc.refundID = order?.refundID
        Navigator.push(vc)
    }
    
    /// 弹框提示
    fileprivate func showAlertViewController(_ message: String, actionType: Int) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            switch actionType {
            case 0:
                //取消订单
                self.requestCanCelOrder()
            case 1:
                //确认收货
                self.requestConfirmData()
            case 2:
                // 删除订单
                self.requestDeleteData()
            default:
                break
            }
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindPayFromBindCard(_ segue: UIStoryboardSegue) {
        
    }
}

// MARK: Request
extension OrderDetailsViewController {
    /**
     请求订单详情
     */
    fileprivate func requestData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = self.orderID
        let req: Promise<OrderDetailData> = handleRequest(Router.endpoint( OrderPath.order(.detail), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.order = value.data
                if let items = value.data?.goodsList {
                    self.goodsList = items
                    //赋值钱将团购券列表清空
                    self.couponArray.removeAll()
                    for goods in items {
                        if let couponList = goods.couponList {
                            self.couponArray.append(contentsOf: couponList)
                        }
                    }
                }
                self.setUI()
                self.tableView.reloadData()
                self.isPriceUpdate = false
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    /**
     取消订单
     */
    fileprivate func requestCanCelOrder() {
        let param = OrderParameter()
        param.orderID = orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.cancel), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_order_cancel_success())
                self.requestData()
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    /**
     选择支付界面
     */
//    internal func showPayment(_ order: Order) {
//        guard let paymentvc = R.storyboard.main.choosePaymentViewController() else {
//            return
//        }
//        paymentvc.amount = Double(order.totalPrice)
//        
//        paymentvc.addNewCard = { [weak self] in
//            guard let vc = R.storyboard.bank.cardsListViewController() else {
//                return
//            }
//            vc.lastViewController = self
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }
//        paymentvc.dismiss = { [weak self] in
//            self?.dim(.out, coverNavigationBar: true)
//            paymentvc.dismiss(animated: true, completion: nil)
//        }
//        paymentvc.confirm = { [weak self] bankcard in
//            self?.requestPayPassData(cardID: bankcard?.cardID, subOrderIDs: [order.orderID])
//        }
//        dim(.in, coverNavigationBar: true)
//        self.present(paymentvc, animated: true, completion: nil)
//        
//    }
    
    /// 请求银行卡信息
    func requestBankCardData(order: Order) {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList, !items.isEmpty {
                self.requestPayPassData(cardID: items.first?.cardID, subOrderIDs: [order.orderID])
            } else {
                self.showBindCardAlert()
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let window = UIApplication.shared.keyWindow {
                    MBProgressHUD.errorMessage(view: window, message: error.localizedDescription)
                }
        }
    }
    
    /**
     请求输入支付密码界面
     */
    fileprivate func requestPayPassData(cardID: String?, subOrderIDs: [String]?) {
        let hud = MBProgressHUD.loading(view: self.view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.type = .onlinePay
            vc.cardID = cardID
            vc.subOrderIDs = subOrderIDs
            vc.resultHandle = { [weak self] (result, pass) in
                
                switch result {
                case .passed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.showPaySuccess()
                case .canceled:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                case .failed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.setFundPassAlertController()
                }
            }
            self.dim(.in, coverNavigationBar: true)
            self.present(vc, animated: true, completion: nil)
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                guard let err = error as? AppError else {
                    return
                }
                if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    self.setFundPassAlertController(message: err.toError().localizedDescription)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    /// 支付成功
    fileprivate func showPaySuccess() {
        guard let vc = R.storyboard.main.paySuccessViewController() else {
            return
        }
        vc.dismissHandleBlock = {
            self.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            self.requestData()
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     确认收货
     */
    fileprivate func requestConfirmData() {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.confirmOrder), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let view = self.navigationController?.view {
                    MBProgressHUD.errorMessage(view: view, message: "收货成功！")
                }
                self.performSegue(withIdentifier: R.segue.orderDetailsViewController.showAppraiseVC, sender: nil)
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 删除订单
    func requestDeleteData() {
        let hud = MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.delete), param: param))
        req.then { (value) -> Void in
            // success
            if let view = self.navigationController?.view {
                MBProgressHUD.errorMessage(view: view, message: "订单删除成功")
            }
            _ = self.navigationController?.popViewController(animated: true)
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: UITableViewDataSource
extension OrderDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //商品
        if let status = order?.status {
            if order?.orderType == .merchandise {
                switch status {
                case .waitingPay, .waitingShip, .shipped, .closed, .confirmed:
                    return 3
                default:
                    return 0
                }
            } else {
                //服务
                switch status {
                case .waitingPay, .closed:
                    return 2
                case .confirmed:
                    return 2 + couponArray.count
                default :
                    return 0
                }
            }

        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let status = order?.status {
            if order?.orderType == .merchandise {
                switch status {
                case .waitingPay, .waitingShip, .shipped, .closed, .confirmed:
                    if section == 2 {
                        return goodsList.count
                    }
                default:
                    return 0
                }
            } else {
                if section == 1 {
                    return goodsList.count
                }
            }

        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let order = self.order else {return UITableViewCell()}
        guard let status = order.status else {return UITableViewCell()}
        switch indexPath.section {
        case 0:
            guard let orderInfoCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderInfoTableViewCell) else {
            return UITableViewCell()
            }
            orderInfoCell.configInfo(order)
            return orderInfoCell
        case 1:
            if order.orderType == .merchandise {
                switch status {
                case .waitingPay, .waitingShip, .closed:
                    guard let orderAddressCell: OrderAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderAddressTableViewCell, for: indexPath) else {return UITableViewCell()}
                    orderAddressCell.configInfo(order)
                    return orderAddressCell
                case .shipped, .confirmed:
                    guard let orderDeliveryCell: OrderDeliveryTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderDeliveryTableViewCell, for: indexPath) else {return UITableViewCell()}
                    orderDeliveryCell.configInfo(order)
                    orderDeliveryCell.detailLinkHandleBlock = {
                        if let vc = R.storyboard.myOrder.logisticsViewController() {
                            vc.orderID = self.orderID
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    return orderDeliveryCell
                default:
                    return UITableViewCell()
                }
            } else {
                guard let orderGoodsCell: OrderGoodsTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderGoodsTableViewCell, for: indexPath) else {return UITableViewCell()}
                orderGoodsCell.configInfo(goodsList[indexPath.row])
                return orderGoodsCell
            }
        case 2:
            if order.orderType == .merchandise {
                guard let orderGoodsCell: OrderGoodsTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderGoodsTableViewCell, for: indexPath) else {return UITableViewCell()}
                orderGoodsCell.configInfo(goodsList[indexPath.row])
                return orderGoodsCell
            } else {
                guard let orderConsumeCell: OrderConsumeTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderConsumeTableViewCell, for: indexPath) else {return UITableViewCell()}
                orderConsumeCell.configInfo(couponArray[indexPath.section - 2])
                orderConsumeCell.couponDetailHandleBlock = { coupon in
                    self.selectedCoupon = coupon
                    self.performSegue(withIdentifier: R.segue.orderDetailsViewController.showCouponDetailVC, sender: nil)
                }
                return orderConsumeCell
            }
        default:
            guard let orderConsumeCell: OrderConsumeTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.orderConsumeTableViewCell, for: indexPath) else {return UITableViewCell()}
            orderConsumeCell.configInfo(couponArray[indexPath.section - 2])
            orderConsumeCell.couponDetailHandleBlock = { coupon in
                self.selectedCoupon = coupon
//                if coupon.status == .Refunded {
//                    // TODO 跳转到退款详情页
//                }
                self.performSegue(withIdentifier: R.segue.orderDetailsViewController.showCouponDetailVC, sender: nil)
            }
            return orderConsumeCell
        }
    }
}

// MARK: UITableViewDelegate
extension OrderDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? OrderGoodsTableViewCell else {
            return
        }
        self.selectedGoods = cell.goods
        performSegue(withIdentifier: R.segue.orderDetailsViewController.showGoodsDetailVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let order = self.order else {return 10}
        guard let status = order.status else {return 10}
        if order.orderType == .merchandise {
            switch status {
            case .waitingPay, .waitingShip, .shipped, .closed, .confirmed:
                if section == 2 {
                    return 50
                }
            default:
                return 0
            }
        } else {
            if section == 1 {
                return 50
            }
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if order?.orderType == .merchandise {
            if section == 2 {
                if order?.platformPoint == 0 {
                    return 145
                } else {
                    return 190
                }
            }
        } else {
            if section == 1 {
                if order?.platformPoint == 0 {
                    return 145
                } else {
                    return 190
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.orderGoodsSectionHeaderView.name) as? OrderGoodsSectionHeaderView else {
            return UIView()
        }
        guard let order = self.order else {return UIView()}
        guard let status = order.status else {return UIView()}
        headerView.configInfo(order)
        headerView.callHandleBlock = { [weak self] tel in
            self?.setTelAlertViewController(tel)
        }
        if order.orderType == .merchandise {
            switch status {
            case .waitingPay, .waitingShip, .shipped, .closed, .confirmed:
                if section == 2 {
                    return headerView
                }
            default:
                return UIView()
            }
        } else {
            if section == 1 {
                return headerView
            }
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let order = self.order else {return UIView()}
        guard let status = order.status else {return UIView()}
        if order.orderType == .merchandise {
            switch status {
            case .waitingPay, .waitingShip, .shipped, .closed, .confirmed:
                if section == 2 {
                    guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.orderGoodsSectionFooterView.name) as? OrderGoodsSectionFooterView else {
                        return UIView()
                    }
                    footerView.configInfo(order)
                    return footerView
                }
            default:
                return UIView()
            }
        } else {
            if section == 1 {
                guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.orderGoodsSectionFooterView.name) as? OrderGoodsSectionFooterView else {
                    return UIView()
                }
                footerView.configInfo(order)
                return footerView
            }
        }
        return UIView()
        
    }
}

//extension OrderDetailsViewController: ChooseCardProtocol {
//    func dismissFromAddNewCard() {
//        _ = self.navigationController?.popToViewController(self, animated: true)
//        DispatchQueue.main.async {
//            if let order = self.order {
//                self.showPayment(order)
//            }
//        }
//    }
//}

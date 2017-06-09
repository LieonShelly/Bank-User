//
//  OrderSubmitSuccessViewController.swift
//  Bank
//
//  Created by yang on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable for_where

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class OrderSubmitSuccessViewController: BaseViewController {

    @IBOutlet fileprivate weak var selectAllButton: UIButton!
    @IBOutlet fileprivate weak var tableview: UITableView!
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet fileprivate weak var totalPriceLabel: UILabel!
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    @IBOutlet fileprivate weak var totalDiscountLabel: UILabel!
    
    var orders: [Order] = []
    var selectedOrders: [Order] = []
    fileprivate var refreshOrder: Order?
    fileprivate var refreshOrderID: String = ""
    fileprivate var isPriceUpdate: Bool = false
    fileprivate var selectedOrder: Order!
    fileprivate var totalPrice: Float = 0
    fileprivate var totalPoint: Int = 0
    fileprivate var totalDiscount: Float = 0
    fileprivate var param: OrderParameter = OrderParameter()
    var submitType: SubmitType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectAllButton.setImage(R.image.btn_choice_no(), for: .normal)
        selectAllButton.setImage(R.image.btn_choice_yes(), for: .selected)
        totalPriceLabel.adjustsFontSizeToFitWidth = true
        for order in orders {
            selectedOrders.append(order)
        }
        updateUI()
        setTableView()
        setLeftBarButton()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOrderInfo(_:)), name: .refreshOrderInfo, object: nil)
    }
    
    override func leftAction() {
        if submitType == .goodsDetail {
            performSegue(withIdentifier: R.segue.orderSubmitSuccessViewController.showGoodsDetailVC.identifier, sender: nil)
        } else {
            performSegue(withIdentifier: R.segue.orderSubmitSuccessViewController.showShoppingCartVC.identifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OrderDetailsViewController {
            vc.orderID = self.selectedOrder.orderID
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshOrderInfo, object: nil)
    }
    
    @IBAction func unwindOrderSuccessFromPay(_ segue: UIStoryboardSegue) {
        dim(.out, coverNavigationBar: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func refreshOrderInfo(_ notification: Foundation.Notification) {
        self.isPriceUpdate = true
        if let extra = notification.object as? [String: Any] {
            if let orderID = extra["order_id"] as? String {
                self.refreshOrderID = orderID
            }
            print(refreshOrderID)
        }
    }
    
    func updateUI() {
        if selectedOrders.count == orders.count {
            selectAllButton.isSelected = true
        } else {
            selectAllButton.isSelected = false
        }
        totalPoint = 0
        totalDiscount = 0
        totalPrice = 0
        for order in selectedOrders {
            totalPrice += order.totalPrice
            totalPoint += order.totalPoint
            totalDiscount += order.totalDiscount
        }
        totalPriceLabel.attributedText = NSAttributedString(leftString: "合计：", rightString: "¥\(totalPrice.numberToString())", leftColor: UIColor(hex: 0x1c1c1c), rightColor: UIColor.orange, leftFontSize: 16, rightFoneSize: 16)
        totalDiscountLabel.text = "已优惠：¥\(totalDiscount.numberToString())"
        pointLabel.text = "本次消费可获得\(totalPoint)积分"
    }
    
    func setTableView() {
        tableview.configBackgroundView()
        tableview.tableFooterView = UIView()
        tableview.tableHeaderView = headerView
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.register(R.nib.orderSubmitSuccessTableViewCell)
    }
    
    @IBAction func selectAllAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        selectedOrders.removeAll()
        for order in orders {
            order.isCheck = sender.isSelected
            if order.isCheck == true {
                selectedOrders.append(order)
            }
        }
        updateUI()
        tableview.reloadData()
    }
    
    @IBAction func payAction(_ sender: UIButton) {
        requestLockOrder()
        if self.isPriceUpdate {
            let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_order_price_update(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
                self.requestOrderDetail()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            var orderIDs: [String] = []
            for order in selectedOrders {
                orderIDs.append(order.orderID)
            }
            param.subOrderIDs = orderIDs
            requestBankCardData()
        }

    }
    
    /// 锁定支付
    fileprivate func requestLockOrder() {
        var orderIDs: [String] = []
        for order in selectedOrders {
            orderIDs.append(order.orderID)
        }
        print(orderIDs)
        let param = LockOrderParameter()
        param.subOrderIds = orderIDs
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPayPath.lockOrder, param: param))
        req.then { (value) -> Void in
            print("\(value.status)正在改价")
            }.always {
            }.catch { (error) in
        }
    }
    
    /// 支付成功弹框
    fileprivate func showPaySuccess() {
        guard let vc = R.storyboard.main.paySuccessViewController() else {
            return
        }
        vc.dismissHandleBlock = {
            self.dim(.out, coverNavigationBar: true)
            vc.dismiss(animated: true, completion: nil)
            guard let orderVC = R.storyboard.myOrder.myOrderViewController() else {
                return
            }
            if self.submitType == .goodsDetail {
                orderVC.sourceType = .goodsDetail
            } else {
                orderVC.sourceType = .shoppingCart
            }
            self.navigationController?.pushViewController(orderVC, animated: true)
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     选择支付界面
     */
//    fileprivate func showPayment() {
//        guard let paymentvc = R.storyboard.main.choosePaymentViewController() else {
//            return
//        }
//        paymentvc.amount = Double(totalPrice)
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
//            self?.param.payAccount = bankcard?.cardID
//            self?.requestPayPassData()
//        }
//        dim(.in, coverNavigationBar: true)
//        self.present(paymentvc, animated: true, completion: nil)
//
//    }
    
    /// 请求银行卡信息
    func requestBankCardData() {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList, !items.isEmpty {
                self.requestPayPassData(cardID: items.first?.cardID)
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
    fileprivate func requestPayPassData(cardID: String?) {
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.type = .onlinePay
            vc.cardID = cardID
            vc.subOrderIDs = self.param.subOrderIDs
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
    
    /**
     请求订单详情
     */
    fileprivate func requestOrderDetail() {
        let hud = MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = refreshOrderID
        let req: Promise<OrderDetailData> = handleRequest(Router.endpoint(OrderPath.order(.detail), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.isPriceUpdate = false
                guard let refreshOrder = value.data else { return }
                self.refreshOrder = refreshOrder
                for i in 0..<self.orders.count {
                    let order = self.orders[i]
                    if self.refreshOrderID == order.orderID {
                        refreshOrder.totalPoint = order.totalPoint
                        self.orders.remove(at: i)
                        self.orders.insert(refreshOrder, at: i)
                    }
                }
                for i in 0..<self.selectedOrders.count {
                    let order = self.selectedOrders[i]
                    if self.refreshOrderID == order.orderID {
                        refreshOrder.totalPoint = order.totalPoint
                        self.selectedOrders.remove(at: i)
                        self.selectedOrders.insert(refreshOrder, at: i)
                    }
                }
                self.updateUI()
                self.tableview.reloadData()
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    @IBAction func unwindPayFromBindCard(_ segue: UIStoryboardSegue) {
        
    }

}

extension OrderSubmitSuccessViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: OrderSubmitSuccessTableViewCell = tableview.dequeueReusableCell(withIdentifier: R.nib.orderSubmitSuccessTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(orders[indexPath.row])
        cell.selectedHandleBlock = { order, sender in
            if sender.isSelected == true {
                self.selectedOrders.append(order)
            } else {
                for index in 0..<self.selectedOrders.count where self.selectedOrders[index].orderID == order.orderID {
                    self.selectedOrders.remove(at: index)
                }
            }
            self.updateUI()
        }
        cell.gotoOrderDetailHandleBlock = { segueID in
            self.selectedOrder = self.orders[indexPath.row]
            self.performSegue(withIdentifier: segueID, sender: nil)
        }
        return cell
    }
}

extension OrderSubmitSuccessViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//extension OrderSubmitSuccessViewController: ChooseCardProtocol {
//    func dismissFromAddNewCard() {
//        _ = self.navigationController?.popToViewController(self, animated: true)
//        DispatchQueue.main.async {
//            self.showPayment()
//        }
//    }
//}

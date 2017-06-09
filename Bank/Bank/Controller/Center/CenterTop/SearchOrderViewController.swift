//
//  SearchOrderViewController.swift
//  Bank
//
//  Created by yang on 16/3/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import PullToRefresh
import MBProgressHUD
import Device

class SearchOrderViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    fileprivate var titleView: UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
    fileprivate var selectedOrder: Order?
    fileprivate var currentPage: Int = 1
    fileprivate var orderArray: [Order] = []
    fileprivate var refreshOrderID: String = ""
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .order
        )}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.placeholder = R.string.localizable.placeHoder_title_enter_search_keywords()
        titleView.backgroundColor = UIColor.white
        titleView.borderStyle = .none
        titleView.clearButtonMode = .whileEditing
        titleView.layer.cornerRadius = 3
        titleView.tintColor = UIColor(hex: 0x00a8fe)
        titleView.becomeFirstResponder()
        titleView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 30))
        titleView.leftViewMode = .always
        setTitleView(view: titleView)
        setTableView()
        addPullToRefresh()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOrderInfo(_:)), name: .refreshOrderInfo, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleView.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshOrderInfo, object: nil)
        if let tableView = tableView {
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    @objc fileprivate func refreshOrderInfo(_ notification: Foundation.Notification) {
        if let extra = notification.object as? [String: Any] {
            if let orderID = extra["order_id"] as? String {
                self.refreshOrderID = orderID
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestList((self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OrderDetailsViewController {
            vc.orderID = self.selectedOrder?.orderID
        }
        
        if let vc = segue.destination as? AppraiseViewController {
            vc.order = self.selectedOrder
        }
        
        if let vc = segue.destination as? RefundGoodsTableViewController {
            vc.order = self.selectedOrder
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 135
        tableView.register(R.nib.myOrderTableViewCell)
        tableView.register(R.nib.myOrderSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.myOrderSectionHeaderView.name)
        if Device.size() > .screen4Inch {
            tableView.register(R.nib.myOrderSectionFooterView(), forHeaderFooterViewReuseIdentifier: R.nib.myOrderSectionFooterView.name)
        } else {
            tableView.register(R.nib.myOrderSectionFooterView_SE(), forHeaderFooterViewReuseIdentifier: R.nib.myOrderSectionFooterView_SE.name)
        }
    }
    
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        titleView.resignFirstResponder()
        requestList()
    }
    
    fileprivate func validInput(_ page: Int = 1) -> Promise<OrderParameter> {
        return Promise { fulfill, reject in
            guard let title = titleView.text else {
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                return reject(error as Error)
            }
            let count = !title.isEmpty
            switch count {
            case true:
                let param = OrderParameter()
                param.keyword = titleView.text
                param.page = page
                param.perPage = 20
                fulfill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error as Error)
            }
            
        }
    }
    //弹框提示
    func showAlertView(_ orderID: String?, message: String?, actionType: Int) {
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let determinAction = UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default) { (action) in
            switch actionType {
            case 0:
                //取消订单
                guard let orderID = orderID else { return }
                self.requestCanCelOrder(orderID)
            case 1:
                //拨打客服电话
                if let tel = AppConfig.shared.baseData?.serviceHotLine {
                    if let url = URL(string: "tel:" + tel) {
                        UIApplication.shared.openURL(url)
                    }
                }
            case 2:
                // 确认收货
                guard let orderID = orderID else { return }
                self.requestConfirmData(orderID)
            case 3:
                // 删除订单
                guard let orderID = orderID else { return }
                self.requestDeleteData(orderID: orderID)
            default:
                break
            }
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil)
        alertView.addAction(determinAction)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }

    //跳转评价页面
    func gotoAppraiseViewController(_ order: Order) {
        selectedOrder = order
        performSegue(withIdentifier: R.segue.searchOrderViewController.showAppraiseVC, sender: nil)
    }
    
    //跳转退款页面
    func gotoRefundViewController(_ order: Order) {
        selectedOrder = order
        if order.orderType == .merchandise {
            performSegue(withIdentifier: R.segue.searchOrderViewController.showRefundGoodsVC, sender: nil)
        } else {
            performSegue(withIdentifier: R.segue.searchOrderViewController.showRefundServiceVC, sender: nil)
        }
    }
    
    //跳转查看物流界面
    func gotoLogisticsViewController(_ order: Order) {
        guard let vc = R.storyboard.myOrder.logisticsViewController() else {
            return
        }
        vc.orderID = order.orderID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //按钮点击之后
    func afterClickAction(_ orderID: String, orderStatus: OrderStatus) {
        for order in self.orderArray where order.orderID == orderID {
            order.status = orderStatus
        }
        tableView.reloadData()
    }
    
    @IBAction func unwindPayFromBindCard(_ segue: UIStoryboardSegue) {
        
    }
    
}

// Request
extension SearchOrderViewController {
    
    func requestList(_ page: Int = 1) {
        validInput(page).then { (param) -> Promise<OrderListData> in
            let req: Promise<OrderListData> = handleRequest(Router.endpoint(OrderPath.order(.goodsOrderList), param: param))
            MBProgressHUD.loading(view: self.view)
            return req
            }.then { (value) -> Void in
                if value.isValid {
                    self.refreshOrderID = ""
                    if let array = value.data?.items {
                        self.currentPage = page
                        if self.currentPage == 1 {
                            self.orderArray = array
                        } else {
                            self.orderArray.append(contentsOf: array)
                        }
                        self.tableView.reloadData()
                    }
                    if self.orderArray.isEmpty {
                        self.tableView.tableFooterView = self.noneView
                        self.noneView.buttonHandleBlock = { [weak self] in
                            if let viewcontrollers = self?.tabBarController?.viewControllers {
                                guard let theNav = viewcontrollers[2] as? UINavigationController else {
                                    return
                                }
                                theNav.popToRootViewController(animated: false)
                                self?.tabBarController?.selectedViewController = theNav
                            }
                        }
                        let deadlineTime = DispatchTime.now() + .milliseconds(100)
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { 
                            MBProgressHUD.errorMessage(view: self.view, message: "没有找到相关订单，建议精简关键词再试!")

                        })
                    } else {
                        self.tableView.tableFooterView = UIView()
                    }
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
    func requestCanCelOrder(_ orderID: String) {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(OrderPath.order(.cancel), param: param))
        req.then { (_) -> Void in
            self.afterClickAction(orderID, orderStatus: .closed)
            }.always {
                _ = MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    /**
     选择支付界面
     */
//    fileprivate func showPayment(_ order: Order) {
//        guard let paymentvc = R.storyboard.main.choosePaymentViewController() else {
//            return
//        }
//        paymentvc.amount = Double(order.totalPrice)
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
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint(BankCardPath.list, param: parameter))
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
    func requestPayPassData(cardID: String?, subOrderIDs: [String]?) {
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.payPassStatus, param: nil))
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
            self.requestList()
        }
        self.dim(.in, coverNavigationBar: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     确认收货
     */
    func requestConfirmData(_ orderID: String) {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(OrderPath.order(.confirmOrder), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_confirm_receive_success())
                for order in self.orderArray where order.orderID == orderID {
                    order.isCanEvaluate = true
                }
                self.afterClickAction(orderID, orderStatus: .confirmed)
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
    ///
    /// - Parameter orderID: 订单ID
    func requestDeleteData(orderID: String) {
        let hud = MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.orderID = orderID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(OrderPath.order(.delete), param: param))
        req.then { (value) -> Void in
            // success
            MBProgressHUD.errorMessage(view: self.view, message: "订单删除成功")
            for i in 0..<self.orderArray.count where self.orderArray[i].orderID == orderID {
                self.orderArray.remove(at: i)
            }
            self.tableView.reloadData()
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
}

extension SearchOrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let goodsList = orderArray[section].goodsList {
            return goodsList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyOrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.myOrderTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        if let goodsList = orderArray[indexPath.section].goodsList {
            cell.configInfo(goodsList[indexPath.row])
        }
        return cell
        
    }
    
}

extension SearchOrderViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Device.size() > .screen4Inch {
            return 135
        }
        return 115

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        titleView.resignFirstResponder()
        selectedOrder = orderArray[indexPath.section]
        self.performSegue(withIdentifier: R.segue.searchOrderViewController.showOrderDetailVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myOrderSectionHeaderView.name) as? MyOrderSectionHeaderView else {
            return nil
        }
        headerView.configInfo(orderArray[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView: MyOrderSectionFooterView?
        if Device.size() > .screen4Inch {
            footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myOrderSectionFooterView.name) as? MyOrderSectionFooterView
        } else {
            footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myOrderSectionFooterView_SE.name) as?MyOrderSectionFooterView
        }
        footerView?.configInfo(orderArray[section])
        // 进入退款详情页
        footerView?.gotoRefundDetailHandleBlock = { [weak self] selectedID in
            guard let vc = R.storyboard.myOrder.refundDetailTableViewController() else {
                return
            }
            vc.refundID = selectedID
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        footerView?.firstHandleBlock = { [weak self] (order, orderActionType) in
            switch orderActionType {
            case .pay:
                if self?.refreshOrderID == order.orderID {
                    let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: R.string.localizable.alertTitle_order_price_update(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
                        if let page = self?.currentPage {
                            self?.requestList(page)
                        }
                    }))
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.selectedOrder = order
                    self?.requestBankCardData(order: order)
                }
                break
            case .cancel:
                self?.showAlertView(order.orderID, message: "是否取消订单", actionType: 0)
            case .confirm:
                self?.showAlertView(order.orderID, message: R.string.localizable.alertTitle_confirm_receive(), actionType: 2)
            case .refund:
                self?.gotoRefundViewController(order)
            case .lookShip:
                self?.gotoLogisticsViewController(order)
                break
            case .appraise:
                if order.isCanEvaluate == true || order.isUserEvaluate == true {
                    self?.gotoAppraiseViewController(order)
                } else {
                    Navigator.showAlertWithoutAction(nil, message: "消费后才能评价")
                }

            case .contactService:
                // 联系客服
                if let tel = AppConfig.shared.baseData?.serviceHotLine {
                    self?.showAlertView(nil, message: "是否拨打客服电话\(tel)", actionType: 1)
                }
                break
                //            case .MoneyGoing:
                //                //TODO
                //                break
            case .delete:
                self?.showAlertView(order.orderID, message: "确定删除该订单", actionType: 3)
            }
            
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let order = orderArray[section]
        if order.status == .waitingShip {
            return 40
        }
        return 75
    }
}

//extension SearchOrderViewController: ChooseCardProtocol {
//    func dismissFromAddNewCard() {
//        _ = self.navigationController?.popToViewController(self, animated: true)
//        DispatchQueue.main.async {
//            if let order = self.selectedOrder {
//                self.showPayment(order)
//            }
//        }
//    }
//}

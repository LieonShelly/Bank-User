//
//  MyOrderViewController.swift
//  Bank
//
//  Created by Mac on 15/11/26.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable private_outlet

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD
import Device

class MyOrderViewController: BaseViewController {
    
    enum SourceType {
        case goodsDetail
        case shoppingCart
        case defalut
    }
    
    @IBOutlet fileprivate weak var titleView: UIView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var selectedButton: UIButton?
    fileprivate var indicator: UIView?

    fileprivate lazy var noneOrderView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .order)}()
    fileprivate var currentPage: Int = 1
    fileprivate var refundCurrentPage: Int = 1
    fileprivate var couponID: String?
    fileprivate var lastOrderArray: [Order] = []
    fileprivate var selectedOrder: Order?
    fileprivate var selectedRefundOrder: RefundOrder?
    fileprivate var lastRefundOrderArray: [RefundOrder] = []
    fileprivate var orderStatus: OrderStatus?
    fileprivate var isRefunding: Bool = false
    fileprivate let titleArray: [String] = ["全部", "待付款", "待发货", "待收货", "退款"]
    fileprivate let width = UIScreen.main.bounds.width / 5
    fileprivate var titleButtons: [TagButton] = []
    fileprivate var refreshOrderID: String = ""
    var index: Int?
    
    var sourceType: SourceType = .defalut
    
    fileprivate var orderArray: [Order] = [] {
        didSet {
            if orderArray.isEmpty {
                noneOrderView.buttonHandleBlock = {
                    guard let vc = R.storyboard.mall.goodsListViewController() else {
                        return
                    }
                    vc.catID = "0"
                    vc.goodsType = .merchandise
                    Navigator.push(vc)
                }
                tableView.addSubview(noneOrderView)
            } else {
                noneOrderView.removeFromSuperview()
            }
        }
    }
    fileprivate var refundOrderArray: [RefundOrder] = [] {
        didSet {
            if refundOrderArray.isEmpty {
                noneOrderView.buttonHandleBlock = { [weak self] in
                    if let viewcontrollers = self?.tabBarController?.viewControllers {
                        guard let theNav = viewcontrollers[2] as? UINavigationController else {
                            return
                        }
                        theNav.popToRootViewController(animated: false)
                        self?.tabBarController?.selectedViewController = theNav
                    }
                }
                tableView.addSubview(noneOrderView)
            } else {
                noneOrderView.removeFromSuperview()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setTitleView()
        setTableView()
        setLeftBarButton()
        addPullToRefresh()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshOrderInfo(_:)), name: .refreshOrderInfo, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = index {
            buttonAction(self.titleButtons[index])
        } else {
            if isRefunding == true {
                let isReload = refundCurrentPage == 1 ? false : true
                requestRefundList(refundCurrentPage, isReload: isReload)
            } else {
                let isReload = currentPage == 1 ? false : true
                requestList(currentPage, isReload: isReload)
            }
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .refreshOrderInfo, object: nil)
        if let tableView = tableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
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
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            if self?.isRefunding == true {
                self?.requestRefundList((self?.refundCurrentPage ?? 1) + 1)
            } else {
                self?.requestList((self?.currentPage ?? 1) + 1)
            }
            self?.tableView.endRefreshing(at: .bottom)
        }
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            if self?.isRefunding == true {
                self?.requestRefundList()
            } else {
                self?.requestList()
            }
        }
    }

    /**
     返回时跳转的视图
     */
    override func leftAction() {
        switch sourceType {
        case .defalut:
            _ = navigationController?.popViewController(animated: true)
        case .goodsDetail:
            self.performSegue(withIdentifier: R.segue.myOrderViewController.unwindFromGoodsDetail.identifier, sender: nil)
            break
        case .shoppingCart:
            self.performSegue(withIdentifier: R.segue.myOrderViewController.unwindFromShoppingCart.identifier, sender: nil)
            break
        }
        
    }
    
    fileprivate func setTitleView() {
        for i in 0..<titleArray.count {
            
            let button: TagButton = TagButton(type: .custom)
            button.frame = CGRect(x: width*CGFloat(i), y: 0, width: width, height: 38)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            button.tag = i
            button.setTitle(titleArray[i], for: UIControlState())
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(UIColor.darkGray, for: UIControlState())
            button.setTitleColor(UIColor(hex: CustomKey.Color.mainBlueColor), for: .selected)
            if i == 0 {
                selectedButton = button
                selectedButton?.isSelected = true
            }
            button.layoutSubviews()
            titleButtons.append(button)
            titleView.addSubview(button)
        }
        indicator = UIView(frame: CGRect(x: 0, y: 38, width: width, height: 2))
        indicator?.backgroundColor = UIColor(hex: CustomKey.Color.mainBlueColor)
        if let indicator = indicator {
            titleView.addSubview(indicator)
        }
    }
    
    @objc fileprivate func buttonAction(_ btn: UIButton) {
        index = btn.tag
        selectedButton?.isSelected = false
        selectedButton = btn
        selectedButton?.isSelected = true
        UIView.animate(withDuration: 0.3, animations: {
            guard let x = self.selectedButton?.frame.origin.x else {return}
            self.indicator?.frame = CGRect(x: x, y: 38, width: self.width, height: 2)
        }) 
        isRefunding = false
        switch btn.tag {
        case 0:
            orderStatus = nil
        case 1:
            orderStatus = .waitingPay
        case 2:
            orderStatus = .waitingShip
        case 3:
            orderStatus = .shipped
        case 4:
            orderStatus = nil
            isRefunding = true
            requestRefundList()
            return
        default:
            break
        }
        requestList()
    }
    
    func setTableView() {
        tableView.rowHeight = 135
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.register(R.nib.myOrderTableViewCell)
        tableView.register(R.nib.myOrderSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.myOrderSectionHeaderView.name)
        if Device.size() > .screen4Inch {
            tableView.register(R.nib.myOrderSectionFooterView(), forHeaderFooterViewReuseIdentifier: R.nib.myOrderSectionFooterView.name)
        } else {
            tableView.register(R.nib.myOrderSectionFooterView_SE(), forHeaderFooterViewReuseIdentifier: R.nib.myOrderSectionFooterView_SE.name)
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
        performSegue(withIdentifier: R.segue.myOrderViewController.showAppraiseVC, sender: nil)
    }
    
    //跳转退款页面
    func gotoRefundViewController(_ order: Order) {
        selectedOrder = order
        if order.orderType == .merchandise {
            performSegue(withIdentifier: R.segue.myOrderViewController.showRefundGoodsVC, sender: nil)
        } else {
            performSegue(withIdentifier: R.segue.myOrderViewController.showRefundServiceVC, sender: nil)
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
        for (index, order) in zip(self.orderArray.indices, self.orderArray) where order.orderID == orderID {
            if self.orderStatus == nil {
                order.status = orderStatus
            } else {
                orderArray.remove(at: index)
            }
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OrderDetailsViewController {
            vc.orderID = selectedOrder?.orderID
        }
        
        if let vc = segue.destination as? AppraiseViewController {
            vc.order = self.selectedOrder
        }
        
        if let vc = segue.destination as? RefundDetailTableViewController {
            vc.refundID = self.selectedRefundOrder?.refundID
        }
        
        if let vc = segue.destination as? RefundGoodsTableViewController {
            vc.order = self.selectedOrder
        }
        
        if segue.destination is SearchOrderViewController {
            setBackBarButtonWithoutTitle()
        } else {
            setBackBarButton()
        }
        
        if let vc = segue.destination as? ServiceRefundDetailViewController {
            vc.couponID = self.selectedRefundOrder?.couponID
        }
        
    }
    
    @IBAction func unwindPayFromBindCard(_ segue: UIStoryboardSegue) {
        
    }
    
}

// MARK: Request
extension MyOrderViewController {
    /**
     请求订单列表
     */
    func requestList(_ page: Int = 1, isReload: Bool = false) {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.keyword = nil
        param.status = orderStatus
        param.isRefunding = isRefunding
        param.refundStatus = nil
        param.page = page
        param.perPage = 20
        param.refundStatus = nil
        let req: Promise<OrderListData> = handleRequest(Router.endpoint(OrderPath.order(.goodsOrderList), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.refreshOrderID = ""
                if let array = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.orderArray = array
                    } else {
                        if isReload == false {
                            self.lastOrderArray = self.orderArray
                        } else {
                            self.orderArray = self.lastOrderArray
                        }
                        self.orderArray.append(contentsOf: array)
                    }
                    self.tableView.reloadData()
                    MBProgressHUD.hide(for: self.view, animated: true)
                }

            }
            }.always {
                self.tableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     请求订单列表（退款）
     */
    func requestRefundList(_ page: Int = 1, isReload: Bool = false) {
        MBProgressHUD.loading(view: view)
        let param = OrderParameter()
        param.page = page
        param.perPage = 20
        let req: Promise<RefundOrderListData> = handleRequest(Router.endpoint( OrderPath.order(.refundOrderList), param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let array = value.data?.items {
                    self.refundCurrentPage = page
                    if self.refundCurrentPage == 1 {
                        self.refundOrderArray = array
                    } else {
                        if isReload == false {
                            if isReload == false {
                                self.lastRefundOrderArray = self.refundOrderArray
                            } else {
                                self.refundOrderArray = self.lastRefundOrderArray
                            }
                        }
                        self.refundOrderArray.append(contentsOf: array)
                    }
                    self.tableView.reloadData()
                }
            }
            }.always {
                self.tableView.endRefreshing(at: .top)
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
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.cancel), param: param))
        req.then { (value) -> Void in
            self.afterClickAction(orderID, orderStatus: .closed)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
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
//    }
    
    /// 请求银行卡信息
    func requestBankCardData(order: Order) {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList, !items.isEmpty {
                self.requestLockOrder(subOrderIDs: [order.orderID])
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
                case .failed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.setFundPassAlertController()
                default:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
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
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.confirmOrder), param: param))
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
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( OrderPath.order(.delete), param: param))
        req.then { (value) -> Void in
                // success
            MBProgressHUD.errorMessage(view: self.view, message: "订单删除成功")
            let count = self.orderArray.count
            for i in 0..<count where self.orderArray[i].orderID == orderID {
                self.orderArray.remove(at: i)
                break
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
    
    /// 锁定支付
    fileprivate func requestLockOrder(subOrderIDs: [String]?) {
        
        let param = LockOrderParameter()
        param.subOrderIds = subOrderIDs
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPayPath.lockOrder, param: param))
        req.then { (value) -> Void in
            print("\(value.status)正在改价")
            }.always {
            }.catch { (error) in
        }
    }
}

extension MyOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Device.size() > .screen4Inch {
            return 135
        }
        return 115
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isRefunding == true {
            selectedRefundOrder = refundOrderArray[indexPath.section]
            //进入退款详情
            if selectedRefundOrder?.orderType == .merchandise {
                performSegue(withIdentifier: R.segue.myOrderViewController.showRefundDetailVC, sender: nil)
            } else {
                performSegue(withIdentifier: R.segue.myOrderViewController.showServiceRefundDetailVC, sender: nil)
            }
            
        } else {
            selectedOrder = orderArray[indexPath.section]
            //进入订单详情
            performSegue(withIdentifier: R.segue.myOrderViewController.orderDetailsSegue, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myOrderSectionHeaderView.name) as? MyOrderSectionHeaderView else {
            return nil
        }
        if isRefunding == true {
            headerView.configRefundOrderInfo(refundOrderArray[section])
        } else {
            headerView.configInfo(orderArray[section])
        }
        headerView.tapHandleBlock = { merchantID in
            guard let vc = R.storyboard.mall.brandDetailViewController() else {
                return
            }
            vc.merchantID = merchantID
            Navigator.push(vc)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView: MyOrderSectionFooterView?
        if Device.size() > .screen4Inch {
            footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myOrderSectionFooterView.name) as? MyOrderSectionFooterView
        } else {
            footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.myOrderSectionFooterView_SE.name) as?MyOrderSectionFooterView
        }
        if isRefunding == true {
            footerView?.configRefundInfo(refundOrderArray[section])
        } else {
            footerView?.configInfo(orderArray[section])
        }
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
                        let isReload = self?.currentPage == 1 ? false : true
                        if let page = self?.currentPage {
                            self?.requestList(page, isReload: isReload)
                        }
                    }))
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.selectedOrder = order
                    self?.requestBankCardData(order: order)
                }
            case .cancel:
                self?.showAlertView(order.orderID, message: "是否取消订单", actionType: 0)
            case .confirm:
                // 确认收货
                self?.showAlertView(order.orderID, message: R.string.localizable.alertTitle_confirm_receive(), actionType: 2)
            case .refund:
                self?.gotoRefundViewController(order)
            case .lookShip:
                // 查看物流
                self?.gotoLogisticsViewController(order)
                break
            case .appraise:
                // 评价
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
//                //TODO 钱款去向
//                Navigator.showAlertWithoutAction(nil, message: "功能开发中")
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
        if isRefunding == true {
            let order = refundOrderArray[section]
            if order.status == .success {
                return 40
            }
            return 75
        } else {
            let order = orderArray[section]
            if order.status == .waitingShip {
                return 40
            }
            return 75
        }
    }
    
}

extension MyOrderViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isRefunding == true ? refundOrderArray.count : orderArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRefunding == true {
            if let goodsList = refundOrderArray[section].goodsList {
                return goodsList.count
            }
        } else {
            if let goodsList = orderArray[section].goodsList {
                return goodsList.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyOrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.myOrderTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        if isRefunding == true {
            if let goodsList = refundOrderArray[indexPath.section].goodsList {
                cell.configInfo(goodsList[indexPath.row])
            }
        } else {
            if let goodsList = orderArray[indexPath.section].goodsList {
                cell.configInfo(goodsList[indexPath.row])
            }
        }
        return cell
    }
}

//
//  SubmitOrderViewController.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import Device

//提交类型
enum SubmitType {
    /// 商品详情
    case goodsDetail
    /// 购物车
    case shoppingCart
}

class SubmitOrderViewController: BaseViewController {
    @IBOutlet fileprivate var headerView: UIView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var totalPriceLabel: UILabel!
    @IBOutlet fileprivate weak var pointLabel: UILabel!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var phoneLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    @IBOutlet fileprivate weak var checkoutLabel: UILabel!
    @IBOutlet weak var pointLeadConstraint: NSLayoutConstraint!
    
    var submitType: SubmitType?
    var goodsType: GoodsType?
    var shoppingCart: ShoppingCart?
    var merchants: [Merchant] = []
    var selectedAddress: Address?
    fileprivate var selectedGoods: Goods?
    fileprivate var selectedMerchantID: String?
    fileprivate var selectedEventID: String?
    fileprivate var noneAddressLabel: UILabel!
    fileprivate var orders: [Order] = []
    fileprivate var goodsNumber: Int = 1
    fileprivate var changeGoodsNumberView: ChangeGoodsNumberView?
    fileprivate var changeGoodsEventView: ChangeGoodsEventView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if goodsType == .merchandise {
            requestAddress()
        }
        if Device.size() == .screen4Inch {
            pointLeadConstraint.constant = 40
        }
        totalPriceLabel.adjustsFontSizeToFitWidth = true
        pointLabel.adjustsFontSizeToFitWidth = true
        setBottomUI()
        setTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if goodsType == .merchandise {
            setHeaderView()
            tableView.reloadData()
        }
        setBottomUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddressManagementTableViewController {
            vc.addressType = .selected
            vc.lastViewController = self
        }
        if let vc = segue.destination as? BrandDetailViewController {
            vc.merchantID = self.selectedMerchantID
        }
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods?.goodsID
        }
        if let vc = segue.destination as? OrderSubmitSuccessViewController {
            vc.orders = self.orders
            vc.submitType = self.submitType
            self.orders.removeAll()
            self.shoppingCart = nil
            self.merchants.removeAll()
        }
    }
    
    func setBottomUI() {
        
        if let items = shoppingCart?.merchants {
            merchants = items
        }
        if let price = shoppingCart?.totalPrice.numberToString() {
            totalPriceLabel.attributedText = NSAttributedString(leftString: "合计：", rightString: "¥\(price)", leftColor: UIColor.darkGray, rightColor: UIColor.orange, leftFontSize: 16, rightFoneSize: 16)

        }
        if let point = shoppingCart?.totalPoint {
            pointLabel.text = "本次消费可获得\(point)积分"
        }
        checkoutLabel.text = "提交订单"
        
    }
    
    func setTableView() {
        tableView.configBackgroundView()
        tableView.delegate = self
        tableView.dataSource = self
        if goodsType == .merchandise {
            tableView.tableHeaderView = headerView
        }
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.submitOrderTableViewCell)
        tableView.register(R.nib.submitOrderSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.submitOrderSectionHeaderView.name)
        tableView.register(R.nib.submitOrderSectionFooterView(), forHeaderFooterViewReuseIdentifier: R.nib.submitOrderSectionFooterView.name)
    }
    
    func setHeaderView() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        headerView.addGestureRecognizer(tap)
        if selectedAddress == nil {
            // 没有设置地址的处理
            if noneAddressLabel == nil {
                noneAddressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
                headerView.addSubview(noneAddressLabel)
            }
            noneAddressLabel.text = "您还没有地址，点击添加新地址"
            noneAddressLabel.backgroundColor = UIColor.white
            noneAddressLabel.textAlignment = .center
            noneAddressLabel.textColor = UIColor.gray
            
            return
        }
        if noneAddressLabel != nil && selectedAddress != nil {
            noneAddressLabel.removeFromSuperview()
        }
        nameLabel.text = selectedAddress?.name
        phoneLabel.text = selectedAddress?.mobile
        if let region = selectedAddress?.region {
            if let detailAddress = selectedAddress?.address {
                addressLabel.text = "收货地址：" + region + detailAddress
            }
        }
        
    }
    
    //选择收货地址
    func tapAction(_ tap: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: R.segue.submitOrderViewController.showAddressVC, sender: nil)
    }
    
    //提交订单
    @IBAction func submitOrderAction(_ sender: UIButton) {
        if selectedAddress == nil && goodsType == .merchandise {
            Navigator.showAlertWithoutAction(nil, message: "未选择地址")
            return
        }
        if submitType == .goodsDetail {
            requesetSubmitOrderforGoodsDetail()
        } else {
            requesetSubmitOrderForShoppingCart()
        }
        
    }
    
    //修改数量界面
    func showChangeGoodsNumberView(_ goodsID: String, number: Int, stockNum: Int) {
        if changeGoodsNumberView == nil {
            changeGoodsNumberView = R.nib.changeGoodsNumberView.firstView(owner: nil)
            changeGoodsNumberView?.frame = UIScreen.main.bounds
            guard let changeGoodsNumberView = self.changeGoodsNumberView else {return}
            self.view.addSubview(changeGoodsNumberView)
        }
        changeGoodsNumberView?.stockNumber = stockNum
        changeGoodsNumberView?.number = number
        changeGoodsNumberView?.alpha = 1
        changeGoodsNumberView?.cancelHandleBlock = {
            self.changeGoodsNumberView?.alpha = 0
        }
        changeGoodsNumberView?.determinHandleBlock = { [weak self] number in
            self?.changeGoodsNumberView?.alpha = 0
            if number == 0 {
                if let view = self?.view {
                    MBProgressHUD.errorMessage(view: view, message: "数量不能为0")
                }
                return
            }
            self?.goodsNumber = number
            self?.requestPrepareBuy()
        }
    }
    
    //修改优惠界面
    func showChangeGoodsEventView(_ goodsID: String, events: [OnlineEvent]) {
        if changeGoodsEventView == nil {
            changeGoodsEventView = R.nib.changeGoodsEventView.firstView(owner: nil)
        }
        changeGoodsEventView?.frame = UIScreen.main.bounds
        guard let changeGoodsEventView = changeGoodsEventView else {return}
        view.addSubview(changeGoodsEventView)
        changeGoodsEventView.events = events
        changeGoodsEventView.eventMode = .alertEvent
        changeGoodsEventView.tableView.reloadData()
        changeGoodsEventView.selectedEventID = selectedEventID
        changeGoodsEventView.alpha = 1
        changeGoodsEventView.selectedHandleBlock = { [weak self] eventID in
            self?.changeGoodsEventView?.alpha = 0
            self?.changeGoodsEventView?.removeFromSuperview()
            self?.selectedEventID = eventID
            self?.requestPrepareBuy()
        }
    }
}

// MARK: Request
extension SubmitOrderViewController {
    
    //请求地址信息
    func requestAddress() {
        MBProgressHUD.loading(view: view)
        let req: Promise<AddressListData> = handleRequest(Router.endpoint( OrderPath.address(.list), param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                if let array = value.data?.addressList {
                    for address in array where address.isDefault == true {
                        self.selectedAddress = address
                        self.setHeaderView()
                    }
                    if self.selectedAddress == nil && !array.isEmpty {
                        self.selectedAddress = array[0]
                        self.setHeaderView()
                    }
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
     提交订单(购物车)
     */
    func requesetSubmitOrderForShoppingCart() {
        MBProgressHUD.loading(view: view)
        let param = CartParameter()
        param.addressID = selectedAddress?.addressID
        let req: Promise<AddOrderData> = handleRequest(Router.endpoint( CartPath.addOrder, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let subOrders = value.data?.subOrders {
                    self.orders = subOrders
                    self.performSegue(withIdentifier: R.segue.submitOrderViewController.showOrderSuccessVC, sender: nil)
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
     准备立刻购买
     */
    func requestPrepareBuy() {
        MBProgressHUD.loading(view: view)
        let goods = shoppingCart?.merchants?[0].groups?[0].goodsList?[0]
        let param = CartParameter()
        param.goodsID = goods?.goodsID
        param.num = goodsNumber
        param.eventID = selectedEventID
        param.addressID = selectedAddress?.addressID
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.buyNowPrepare, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let shoppingCart = value.data {
                    self.shoppingCart = shoppingCart
                    self.setBottomUI()
                    self.tableView.reloadData()
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
     实施立刻购买(商品详情)
     */
    func requesetSubmitOrderforGoodsDetail() {
        MBProgressHUD.loading(view: view)
        let param = CartParameter()
        if let goods = shoppingCart?.merchants?[0].groups?[0].goodsList?[0] {
            param.goodsID = goods.goodsID
            param.num = goods.num
            param.price = goods.price
        }
        param.eventID = selectedEventID
        param.addressID = selectedAddress?.addressID
        let req: Promise<AddOrderData> = handleRequest(Router.endpoint( CartPath.buyNow, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let subOrders = value.data?.subOrders {
                    self.orders = subOrders
                    self.performSegue(withIdentifier: R.segue.submitOrderViewController.showOrderSuccessVC, sender: nil)
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
     请求商品参与的活动
     */
    func requestGoodsEventsData(_ goodsID: String) {
        MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.goodsID = goodsID
        let req: Promise<GoodsEventListData> = handleRequest(Router.endpoint( GoodsPath.eventList, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let events = value.data?.events {
                    self.showChangeGoodsEventView(goodsID, events: events)
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
}

// MARK: UITableViewDataSource
extension SubmitOrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return merchants.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var goodsArray: [Goods] = []
        if let groups = merchants[section].groups {
            for group in groups {
                if let goodsList = group.goodsList {
                    goodsArray.append(contentsOf: goodsList)
                }
            }
            return goodsArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SubmitOrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.submitOrderTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.submitType = self.submitType
        if submitType == .goodsDetail {
            if let groups = merchants[indexPath.section].groups {
                cell.group = groups[0]
                if !groups.isEmpty {
                    if let goodsList = groups[0].goodsList {
                        cell.number = goodsNumber
                        cell.configInfo(goodsList[indexPath.row])
                        cell.editNumberHandleBlock = { [weak self] in
                            guard let goodsNumber = self?.goodsNumber else { return }
                            guard let stockNum = goodsList[indexPath.row].stockNum else { return }
                            self?.showChangeGoodsNumberView(goodsList[indexPath.row].goodsID, number: goodsNumber, stockNum: stockNum)
                        }
                        selectedEventID = groups[0].event?.eventID
                    }
                }
            }
        } else {
            var goodsArray: [Goods] = []
            if let groups = merchants[indexPath.section].groups {
                for group in groups {
                    if let goodsList = group.goodsList {
                        goodsArray.append(contentsOf: goodsList)
                    }
                }
                cell.configInfo(goodsArray[indexPath.row])
            }
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension SubmitOrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groups = merchants[indexPath.section].groups {
            for group in groups {
                if let goodsList = group.goodsList {
                    self.selectedGoods = goodsList[indexPath.row]
                    self.performSegue(withIdentifier: R.segue.submitOrderViewController.showGoodsDetailVC, sender: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.submitOrderSectionHeaderView.name) as? SubmitOrderSectionHeaderView else {
            return UIView()
        }
        if goodsType == .service {
            headerView.topLayoutConstraint.constant = 0
        }
        headerView.configInfo(merchants[section])
        headerView.gotoShopHandleBlock = { segueID, merchantID in
            self.selectedMerchantID = merchantID
            self.performSegue(withIdentifier: R.segue.submitOrderViewController.showBrandDetailVC, sender: nil)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footView = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.submitOrderSectionFooterView.name) as? SubmitOrderSectionFooterView else {
            return UIView()
        }
        footView.configInfo(merchants[section])
        return footView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if goodsType == .service {
            return 35
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

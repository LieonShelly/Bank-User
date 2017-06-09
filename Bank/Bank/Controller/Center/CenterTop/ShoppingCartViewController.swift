//
//  ShoppingCartViewController.swift
//  Bank
//
//  Created by yang on 16/1/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class ShoppingCartViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var shoppingCartTableView: UITableView!
    @IBOutlet fileprivate weak var normalToolView: UIView!
    @IBOutlet fileprivate weak var editToolView: UIView!
    @IBOutlet fileprivate weak var editButton: UIButton!
    @IBOutlet fileprivate weak var selectAllButton: UIButton!
    @IBOutlet fileprivate weak var totalPriceLabel: UILabel!
    @IBOutlet fileprivate weak var discountLabel: UILabel!
    @IBOutlet fileprivate weak var totalpointLabel: UILabel!
    @IBOutlet fileprivate weak var settlementButton: UIButton!
    @IBOutlet fileprivate weak var editSelectedAllButton: UIButton!
    @IBOutlet fileprivate weak var pointView: UIView!
    @IBOutlet fileprivate weak var checkoutLabel: UILabel!
    @IBOutlet weak var toolHeight: NSLayoutConstraint!
    
    fileprivate var selectedGoodsID: String?
    fileprivate var totalPrice: Double = 0
    fileprivate var totalDiscount: Double = 0
    fileprivate var totalPoint: Int = 0
    fileprivate var selectedGoodsCount: Int = 0
    fileprivate var merchantArray: [Merchant] = []
    fileprivate var selectedMerchantID: String?
    fileprivate var eventList: [OnlineEvent] = []
    fileprivate var selectedEventID: String?
    fileprivate var changeGoodsEventView: ChangeGoodsEventView?
    fileprivate var changeGoodsNumberView: ChangeGoodsNumberView?
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.shoppingCartTableView.bounds, type: .cart)}()
    
    fileprivate var shoppingCart: ShoppingCart? {
        didSet {
            if self.shoppingCart?.merchants?.isEmpty == true {
                self.shoppingCartTableView.tableFooterView = noneView
                pointView.isHidden = true
                toolHeight.constant = 0
                normalToolView.isHidden = true
                self.editButton.isHidden = true
                self.editButton.isSelected = true
                self.editClick(editButton)
            } else {
                self.shoppingCartTableView.tableFooterView = UIView()
                pointView.isHidden = false
                toolHeight.constant = 60
                normalToolView.isHidden = false
                self.editButton.isHidden = false
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        editButton.setTitle("完成", for: .selected)
        selectAllButton.setImage(R.image.btn_choice_yes(), for: .selected)
        editSelectedAllButton.setImage(R.image.btn_choice_yes(), for: .selected)
        editSelectedAllButton.addTarget(self, action: #selector(selectAllClick(_:)), for: .touchUpInside)
        totalPriceLabel.adjustsFontSizeToFitWidth = true
        setTableView()
        setNormalToolView()
        addPullToRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeFrame"), object: nil)
    }
    
    deinit {
        if let tableView = shoppingCartTableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        shoppingCartTableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestList()
            self?.shoppingCartTableView.endRefreshing(at: .bottom)
        }
        shoppingCartTableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestList()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoodsID
        }
        if let vc = segue.destination as? SubmitOrderViewController {
            vc.shoppingCart = self.shoppingCart
            vc.submitType = .shoppingCart
            vc.goodsType = .merchandise
        }
        if let vc = segue.destination as? SalesGoodsViewController {
            vc.eventID = self.selectedEventID
        }
        if let vc = segue.destination as? BrandDetailViewController {
            vc.merchantID = self.selectedMerchantID
        }
    }
    
    @IBAction func unwindFromShoppingCart(_ segue: UIStoryboardSegue) {
        
    }
    
    func setTableView() {
        shoppingCartTableView.register(R.nib.groupTableViewCell)
        shoppingCartTableView.register(R.nib.shoppingSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.shoppingSectionHeaderView.name)
        shoppingCartTableView.register(R.nib.shoppingGoodsEventTableViewCell)
        shoppingCartTableView.tableFooterView = UIView()
        shoppingCartTableView.configBackgroundView()
        shoppingCartTableView.allowsMultipleSelection = true
        
    }
    
    func setNormalToolView() {
        let priceStr = totalPrice.numberToString()
        totalPriceLabel.attributedText = NSAttributedString(leftString: "合计：", rightString: "¥\(priceStr)", leftColor: UIColor(hex: 0x1c1c1c), rightColor: UIColor.orange, leftFontSize: 16, rightFoneSize: 16)
        let discountStr = totalDiscount.numberToString()
        discountLabel.text = "已优惠：¥\(discountStr)"
        totalpointLabel.text = "本次消费可获得\(totalPoint)积分"
        selectedGoodsCount = 0
        for merchant in merchantArray {
            if let groups = merchant.groups {
                for group in groups {
                    if let goodsList = group.goodsList {
                        for goods in goodsList where goods.isChecked == true {
                            self.selectedGoodsCount += 1
                        }
                    }
                }
            }
        }
        if let totalItems = shoppingCart?.totalItems {
            checkoutLabel.attributedText = NSAttributedString(leftString: "结算", rightString: "(\(totalItems))", leftColor: UIColor.white, rightColor: UIColor.white, leftFontSize: 20, rightFoneSize: 16)
        }
        if let isSelceted = shoppingCart?.isAllChecked {
            selectAllButton.isSelected = isSelceted
            editSelectedAllButton.isSelected = isSelceted
        }
        
    }
    
    //点击编辑按钮
    @IBAction func editClick(_ sender: UIButton) {
        editButton.isSelected = !editButton.isSelected
        if editButton.isSelected == true {
            normalToolView.alpha = 0
            pointView.alpha = 0
            editToolView.frame = normalToolView.frame
            view.addSubview(editToolView)
            shoppingCartTableView.isEditing = true
            
        } else {
            normalToolView.alpha = 1
            pointView.alpha = 1
            editToolView.removeFromSuperview()
            shoppingCartTableView.isEditing = false
        }
    }
    
    /**
     全选
     */
    @IBAction func selectAllClick(_ sender: UIButton) {
        if shoppingCart?.isAllCannotCheck == true {
            Navigator.showAlertWithoutAction(nil, message: "没有可以选中的有效商品")
            return
        }
        sender.isSelected = !sender.isSelected
        requeCartSelectedData("0", merchantID: "0", isCheck: sender.isSelected)
    }
    
    /**
     结算
     */
    @IBAction func settlementAction(_ sender: UIButton) {
        if selectedGoodsCount < 1 {
            Navigator.showAlertWithoutAction(nil, message: "没有选中商品")
            return
        }
        requestCatCheckOut()
    }
    
    /**
     批量收藏
     */
    @IBAction func collectionAction(_ sender: UIButton) {
        var goodsIDArray: [String] = []
        
        for merchant in merchantArray {
            if let groups = merchant.groups {
                for group in groups {
                    if let goodsList = group.goodsList {
                        for goods in goodsList where goods.isChecked {
                            goodsIDArray.append(goods.goodsID)
                        }
                    }
                }
            }
        }
        requestAddCollection(goodsIDArray)
    }
    
    /**
     批量删除
     */
    @IBAction func deleteAction(_ sender: UIButton) {
        var goodsIDs: [String] = []
        for merchant in merchantArray {
            if let groups = merchant.groups {
                for group in groups {
                    if let goodsList = group.goodsList {
                        for goods in goodsList where goods.isChecked {
                            goodsIDs.append(goods.goodsID)
                        }
                    }
                }
            }
        }
        showAlertView(goodsIDs)
    }
    
    //修改数量界面
    func showChangeGoodsNumberView(_ goodsID: String, number: Int, stockNum: Int) {
        if changeGoodsNumberView == nil {
            changeGoodsNumberView = R.nib.changeGoodsNumberView.firstView(owner: nil)
            changeGoodsNumberView?.frame = UIScreen.main.bounds
            if  let view = self.changeGoodsNumberView {
                self.navigationController?.view.addSubview(view)
            }
        }
        changeGoodsNumberView?.stockNumber = stockNum
        changeGoodsNumberView?.number = number
        changeGoodsNumberView?.alpha = 1
        changeGoodsNumberView?.cancelHandleBlock = {
            self.changeGoodsNumberView?.alpha = 0
        }
        changeGoodsNumberView?.determinHandleBlock = { [weak self] number in
            self?.requestUpdateGoodsData(goodsID, number: number)
            self?.changeGoodsNumberView?.alpha = 0
        }
    }
    
    //修改优惠界面
    func showChangeGoodsEventView(_ goodsID: String, events: [OnlineEvent], selectedEventID: String) {
        if changeGoodsEventView == nil {
            changeGoodsEventView = R.nib.changeGoodsEventView.firstView(owner: nil)
        }
        changeGoodsEventView?.frame = UIScreen.main.bounds
        if  let view = self.changeGoodsEventView {
            self.navigationController?.view.addSubview(view)
        }
        changeGoodsEventView?.events = events
        changeGoodsEventView?.eventMode = .alertEvent
        changeGoodsEventView?.tableView.reloadData()
        changeGoodsEventView?.selectedEventID = selectedEventID
        changeGoodsEventView?.alpha = 1
        changeGoodsEventView?.selectedHandleBlock = { [weak self] eventID in
            self?.changeGoodsEventView?.alpha = 0
            self?.changeGoodsEventView?.removeFromSuperview()
            self?.requestUpdateEventData(goodsID, eventID: eventID)
        }
        
    }
    
    //删除时弹框提示是否删除
    func showAlertView(_ goodsIDs: [String]) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: "是否从购物车中删除？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.requestDeleteData(goodsIDs)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: { (anction) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Request
extension ShoppingCartViewController {
    //请求购物车商品
    func requestList() {
        MBProgressHUD.loading(view: view)
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.getCart, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                if let merchants = value.data?.merchants {
                    self.merchantArray = merchants
                }
                if let price = value.data?.totalPrice {
                    self.totalPrice = price
                }
                if let discount = value.data?.totalDiscount {
                    self.totalDiscount = discount
                }
                if let point = value.data?.totalPoint {
                    self.totalPoint = point
                }
                self.setNormalToolView()
                self.shoppingCartTableView.reloadData()
            }
            }.always {
                self.shoppingCartTableView.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    //删除购物车商品
    func requestDeleteData(_ goodsIDs: [String]) {
        if goodsIDs.isEmpty {
            Navigator.showAlertWithoutAction(nil, message: "未选中任何商品，请选中后再删除")
            return
        }
        MBProgressHUD.loading(view: view)
        let param = CartParameter()
        param.goodsIDs = goodsIDs
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.delGoods, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                if let items = value.data?.merchants {
                    self.merchantArray = items
                }
                if let price = value.data?.totalPrice {
                    self.totalPrice = price
                }
                if let discount = value.data?.totalDiscount {
                    self.totalDiscount = discount
                }
                if let point = value.data?.totalPoint {
                    self.totalPoint = point
                }
                self.setNormalToolView()
                self.shoppingCartTableView.reloadData()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    //修改购物车商品数量
    func requestUpdateGoodsData(_ goodsID: String, number: Int) {
        if number == 0 {
            MBProgressHUD.errorMessage(view: self.view, message: "数量不能为0")
            return
        }
        MBProgressHUD.loading(view: view)
        let param = CartParameter()
        param.goodsID = goodsID
        param.num = number
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.updateGoodsNum, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                if let items = value.data?.merchants {
                    self.merchantArray = items
                }
                if let price = value.data?.totalPrice {
                    self.totalPrice = price
                }
                if let discount = value.data?.totalDiscount {
                    self.totalDiscount = discount
                }
                if let point = value.data?.totalPoint {
                    self.totalPoint = point
                }
                self.setNormalToolView()
                self.shoppingCartTableView.reloadData()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    //修改购物车促销活动
    func requestUpdateEventData(_ goodsID: String, eventID: String) {
        let param = CartParameter()
        param.eventID = eventID
        param.goodsID = goodsID
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.updateOnlineEvent, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                if let items = value.data?.merchants {
                    self.merchantArray = items
                }
                if let price = value.data?.totalPrice {
                    self.totalPrice = price
                }
                if let discount = value.data?.totalDiscount {
                    self.totalDiscount = discount
                }
                if let point = value.data?.totalPoint {
                    self.totalPoint = point
                }
                self.setNormalToolView()
                self.shoppingCartTableView.reloadData()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    //请求商品参与的活动
    func requestGoodsEventsData(_ goodsID: String, selectedEventID: String) {
        MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.goodsID = goodsID
        let req: Promise<GoodsEventListData> = handleRequest(Router.endpoint( GoodsPath.eventList, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let events = value.data?.events {
                    self.eventList = events
                    self.showChangeGoodsEventView(goodsID, events: events, selectedEventID: selectedEventID)
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
    
    //购物车选中切换
    func requeCartSelectedData(_ goodsID: String, merchantID: String, isCheck: Bool) {
        MBProgressHUD.loading(view: view)
        let param = CartParameter()
        param.goodsID = goodsID
        param.merchantID = merchantID
        param.isChecked = isCheck
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.cartCheck, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                if let items = value.data?.merchants {
                    self.merchantArray = items
                }
                if let price = value.data?.totalPrice {
                    self.totalPrice = price
                }
                if let discount = value.data?.totalDiscount {
                    self.totalDiscount = discount
                }
                if let point = value.data?.totalPoint {
                    self.totalPoint = point
                }
                self.setNormalToolView()
                self.shoppingCartTableView.reloadData()
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
     购物车结算
     */
    func requestCatCheckOut() {
        MBProgressHUD.loading(view: view)
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.checkOut, param: nil))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                self.performSegue(withIdentifier: R.segue.shoppingCartViewController.showSubmitOrderVC, sender: nil)
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
     收藏商品
     */
    func requestAddCollection(_ goods: [String]) {
        if goods.isEmpty {
            MBProgressHUD.errorMessage(view: self.view, message: "未选中任何商品，请选中后再收藏")
            return
        }
//        MBProgressHUD.loading(view: view)
        let param = CartParameter()
        param.goodsIDs = goods
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.removeCollection, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.shoppingCart = value.data
                if let merchants = value.data?.merchants {
                    self.merchantArray = merchants
                }
                if let price = value.data?.totalPrice {
                    self.totalPrice = price
                }
                if let discount = value.data?.totalDiscount {
                    self.totalDiscount = discount
                }
                if let point = value.data?.totalPoint {
                    self.totalPoint = point
                }
                self.setNormalToolView()
                self.shoppingCartTableView.reloadData()
                MBProgressHUD.errorMessage(view: self.view, message: R.string.localizable.alertTitle_receive_sucess_check_in_collection())
            }
            }.always {
//                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ShoppingCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groups = merchantArray[section].groups {
            return groups.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return merchantArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: GroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.groupTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        if let groups = merchantArray[indexPath.section].groups {
            cell.tableView = shoppingCartTableView
            cell.configInfo(groups[indexPath.row])
            
        }
        cell.deleteHandleBlock = { goodsID in
            self.showAlertView([goodsID])
        }
        cell.collectionHandleBlock = { goodsID in
            self.requestAddCollection([goodsID])
        }
        cell.selectHandleBlock = { (goodsID, merchantID, isChecked) in
            self.requeCartSelectedData(goodsID, merchantID: merchantID, isCheck: isChecked)
        }
        cell.gotoGoodsDetailHandleBlock = { goodsID in
            self.selectedGoodsID = goodsID
            self.performSegue(withIdentifier: R.segue.shoppingCartViewController.showGoodsDetailVC, sender: nil)
        }
        cell.numberChangeHandleBlock = { [weak self] (goodsID, number, stockNum) in
            self?.showChangeGoodsNumberView(goodsID, number: number, stockNum: stockNum)
        }
        cell.changeEventHandleBlock = { [weak self] (goodsID, selectedEventID) in
            self?.requestGoodsEventsData(goodsID, selectedEventID: selectedEventID)
        }
        cell.gotoEventDetailHandleBlock = { [weak self] eventID in
            self?.selectedEventID = eventID
            self?.performSegue(withIdentifier: R.segue.shoppingCartViewController.showSaleVC, sender: nil)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

// MARK: UITableViewDelegate
extension ShoppingCartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "changeFrame"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let groups = merchantArray[indexPath.section].groups {
            var height: CGFloat = 0
            if let goodsList = groups[indexPath.row].goodsList {
                for goods in goodsList {
                    if goods.eventCount > 1 {
                        height += 150
                    } else {
                        height += 116
                    }
                }
            }
            if let event = groups[indexPath.row].event {
                if event.eventID == "" {
                    height += 0
                } else {
                    height += 40
                }
            }
            return height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.shoppingSectionHeaderView.name) as? ShoppingSectionHeaderView else {
            return UIView()
        }
        header.configInfo(merchantArray[section])
        header.selectHandleBlock = { [weak self] sender in
            if header.merchant?.isAllCannotCheck == true {
                Navigator.showAlertWithoutAction(nil, message: "该店铺没有可选择的有效商品")
                return
            }
            sender.isSelected = !sender.isSelected
            if let merchantID = header.merchant?.merchantID {
                self?.requeCartSelectedData("0", merchantID: merchantID, isCheck: header.selectButton.isSelected)
            }
            
        }
        header.gotoMerchantDetailHandleBlock = { merchantID in
            self.selectedMerchantID = merchantID
            self.performSegue(withIdentifier: R.segue.shoppingCartViewController.showBrandDetailVC, sender: nil)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
}

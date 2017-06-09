//
//  GoodsDetailViewController.swift
//  Bank
//
//  Created by Koh Ryu on 12/4/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet
import UIKit
import PromiseKit
import URLNavigator
import ObjectMapper
import WebKit
import MBProgressHUD

class GoodsDetailViewController: BaseViewController {

    @IBOutlet fileprivate weak var bottomStackView: UIStackView!
    @IBOutlet fileprivate weak var selloutLabel: UILabel!
    @IBOutlet fileprivate weak var collectButton: VerticalButton!
    @IBOutlet fileprivate weak var addtoCartButton: UIButton!
    @IBOutlet fileprivate weak var buyNowButton: UIButton!
    @IBOutlet fileprivate weak var shoppingCartButton: TagButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    fileprivate var changeGoodsEventView: ChangeGoodsEventView?
    fileprivate var theLayer: CALayer?
    fileprivate var cartNumber: Int = 0
    fileprivate var eventList: [OnlineEvent] = []
    fileprivate var selectedEventID: String?
    fileprivate var goods: Goods!
    fileprivate var shoppingCart: ShoppingCart?
    fileprivate var noneGoodsView: NoneBackgroundView?
    fileprivate var goodsConfigID: String?
    fileprivate var isReload: Bool = false
    lazy var webView = {
        return WKWebView()
    }()
    
    var order: Order!
    var goodsID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        webView.navigationDelegate = self
        collectButton.setImage(R.image.btn_already_collect(), for: .normal)
        collectButton.setImage(R.image.btn_already_collected(), for: .selected)
        collectButton.setTitle(R.string.localizable.button_title_collect(), for: UIControlState())
        collectButton.setTitle(R.string.localizable.button_title_collected(), for: .selected)
        shoppingCartButton.layoutSubviews()
        requestGoodsDetailData(goodsID: self.goodsID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if AppConfig.shared.isLoginFlag {
            requestGoodsNum()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BrandDetailViewController {
            vc.merchantID = goods.merchantID
        }
        if let vc = segue.destination as? SubmitOrderViewController {
            vc.shoppingCart = self.shoppingCart
            vc.submitType = .goodsDetail
            vc.goodsType = self.goods.type
        }
        if let vc = segue.destination as? SalesGoodsViewController {
            vc.eventID = self.selectedEventID
        }
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(webView)
        webView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(bottomStackView.snp.top).offset(0)
        })
    }
    
    @IBAction func unwindFromGoodsDetail(_ segue: UIStoryboardSegue) {
        
    }
    
    //售完或已下架
    func setSellOutView(_ content: String) {
        selloutLabel.frame = CGRect(x: 0, y: view.frame.height - 100, width: view.frame.width, height: 50)
        selloutLabel.text = content
        view.addSubview(selloutLabel)
        if addtoCartButton != nil {
            addtoCartButton.isEnabled = false
            addtoCartButton.backgroundColor = UIColor(hex: 0xcccccc)
            addtoCartButton.setTitleColor(UIColor.black, for: UIControlState())
        }
        buyNowButton.isEnabled = false
        buyNowButton.backgroundColor = UIColor(hex: 0xb3b3b3)
        buyNowButton.setTitleColor(UIColor.black, for: UIControlState())
    }
    
    fileprivate func setNoneGoodsView() {
        if noneGoodsView == nil {
            if let view = R.nib.noneBackgroundView.firstView(owner: nil) {
                noneGoodsView = view
                self.view.addSubview(view)
            }
        }
        noneGoodsView?.imageView.image = R.image.mall_offlineEvent_icon_cannot_view()
        noneGoodsView?.titleImageView.image = R.image.word_goods()
        self.title = R.string.localizable.controller_title_good_details()
        self.navigationItem.rightBarButtonItems?.removeAll()
        noneGoodsView?.frame = view.bounds
    }
    
    func loadWebView() {
        if let html = goods.html {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    // MARK: 立刻购买
    @IBAction func nextHandle() {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        buyNowButton.isEnabled = false
        if goods.type == .merchandise && goods.goodsConfigID != "0" {
            self.showChooseParam()
            buyNowButton.isEnabled = true
        } else {
            requestPrepareBuy(goodsID: goods.goodsID)
        }
    }
    
    //加入购物车
    @IBAction func addToShoppingCartAction(_ sender: UIButton) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        sender.isEnabled = false
        if goods.goodsConfigID == "0" {
            requestAddToShoppingCart()
        } else {
            self.showChooseParam()
        }
        sender.isEnabled = true
    }
    
    //收藏
    @IBAction func collectAction(_ sender: VerticalButton) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        if collectButton.isSelected == false {
            requestAddCollect()
        } else {
            requestRemoveCollect()
        }
        collectButton.isSelected = !collectButton.isSelected
    }

    //购物车
    @IBAction func gotoShoppingCartAction(_ sender: UIButton) {
        if !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return
        }
        self.performSegue(withIdentifier: R.segue.goodsDetailViewController.showShoppingCartVC, sender: nil)
    }
    
    //分享
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        guard let vc = R.storyboard.main.shareViewController() else {return}
        vc.sharePage = .goodsDetail
        vc.shareID = goodsID
        vc.completeHandle = { [weak self] result in
            self?.dim(.out)
            self?.dismiss(animated: true, completion: nil)
        }
        dim(.in)
        present(vc, animated: true, completion: nil)
        
    }
    
    //加入购物车动画
    fileprivate func startAnimation() {
        addtoCartButton.isEnabled = true
        guard let navView = navigationController?.view else {
            return
        }
        MBProgressHUD.errorMessage(view: navView, message: R.string.localizable.label_title_add_shop_car_success())
    }
    
    //购物车商品数量变化
    fileprivate func cartNumberChange() {
        if cartNumber > 0 {
            self.shoppingCartButton.tagView?.isHidden = false
            self.shoppingCartButton.tagView?.setTitle(String(cartNumber), for: UIControlState())
        } else {
            self.shoppingCartButton.tagView?.isHidden = true
        }

    }
    
    //查看优惠界面
    func showChangeGoodsEventView(_ goodsID: String, events: [OnlineEvent]) {
        if changeGoodsEventView == nil {
            changeGoodsEventView = R.nib.changeGoodsEventView.firstView(owner: nil)
        }
        changeGoodsEventView?.frame = UIScreen.main.bounds
        changeGoodsEventView?.events = events
        changeGoodsEventView?.titleLabel.text = R.string.localizable.label_title_privilege()
        changeGoodsEventView?.eventMode = .checkEvent
        changeGoodsEventView?.tableView.reloadData()
        changeGoodsEventView?.alpha = 1
        changeGoodsEventView?.selectedHandleBlock = { [weak self] eventID in
            self?.selectedEventID = eventID
            self?.changeGoodsEventView?.alpha = 0
            self?.changeGoodsEventView?.removeFromSuperview()
            self?.performSegue(withIdentifier: R.segue.goodsDetailViewController.showSaleGoodsVC, sender: nil)
        }
        if let view = changeGoodsEventView {
            self.navigationController?.view.addSubview(view)
        }
    }
    
    /// 选择商品规格（普通商品才有）
    func showChooseParam() {
        guard let vc = R.storyboard.mall.chooseGoodsParamViewController() else {
            return
        }
        vc.goods = self.goods
        vc.lastController = self
        vc.goodsConfigID = self.goodsConfigID
        vc.dismissHandleBlock = { [weak self] in
            self?.dim(.out)
            vc.dismiss(animated: true, completion: nil)
        }
        vc.buttonHandleBlock = { [weak self] (actionMode, selectedGoods) in
            self?.goods = selectedGoods
            self?.goods.type = .merchandise
            switch actionMode {
            case .determin:
                break
            case .addCart:
                self?.requestAddToShoppingCart()
            case .buyNow:
                self?.requestPrepareBuy(goodsID: selectedGoods?.goodsID)
            }
        }
        self.dim(.in)
        present(vc, animated: true, completion: nil)
    }

}

// MARK: Request
extension GoodsDetailViewController {
    
    /// 请求商品详情
    func requestGoodsDetailData(goodsID: String?) {
//        let hud = MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.goodsID = goodsID
        let req: Promise<GoodsObjectData> = handleRequest(Router.endpoint(GoodsPath.goodsDetail, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if !self.isReload {
                    self.goodsConfigID = value.data?.goodsConfigID
                }
                self.goods = value.data
                self.loadWebView()
                self.isReload = true
            }
            }.always {
//                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

    /**
     加入购物车
     */
    func requestAddToShoppingCart() {
        let param = CartParameter()
        let addGoods = TheGoods()
        addGoods.theId = goods.goodsID
        addGoods.num = 1
        param.goods = [addGoods]
        let req: Promise<AddToShoppingCartData> = handleRequest(Router.endpoint( CartPath.addGoods, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.requestGoodsNum()
                self.startAnimation()
            }
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    /**
     添加收藏
     */
    func requestAddCollect() {
        let hud = MBProgressHUD.loading(view: view)
        let param = CollectionParameter()
        let collectable = Collectable()
        collectable.collectType = .goods
        collectable.collectId = goods.goodsID
        param.goodsArray = [collectable]
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( CollectionPath.add, param: param))
        req.then { (value) -> Void in
            MBProgressHUD.errorMessage(view: self.view, message: R.string.localizable.alertTitle_receive_sucess_check_in_collection())
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     取消收藏
     */
    func requestRemoveCollect() {
        let hud = MBProgressHUD.loading(view: view)
        let param = CollectionParameter()
        let collectable = Collectable()
        collectable.collectType = .goods
        collectable.collectId = goods.goodsID
        param.goodsArray = [collectable]
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( CollectionPath.remove, param: param))
        req.then { (value) -> Void in
            MBProgressHUD.errorMessage(view: self.view, message: "取消收藏成功")
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     准备立刻购买
     */
    func requestPrepareBuy(goodsID: String?) {
        let hud = MBProgressHUD.loading(view: view)
        let param = CartParameter()
        param.goodsID = goodsID
        param.num = 1
        param.eventID = nil
        param.addressID = nil
        let req: Promise<ShoppingCartData> = handleRequest(Router.endpoint( CartPath.buyNowPrepare, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let shoppingCart = value.data {
                    self.shoppingCart = shoppingCart
                    self.performSegue(withIdentifier: R.segue.goodsDetailViewController.showSubmitOrderVC, sender: nil)
                }
            }
            }.always {
                self.buyNowButton.isEnabled = true
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    //请求商品参与的活动
    func requestGoodsEventsData() {
        let hud = MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.goodsID = goodsID
        let req: Promise<GoodsEventListData> = handleRequest(Router.endpoint( GoodsPath.eventList, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let events = value.data?.events {
                    self.eventList = events
                    self.showChangeGoodsEventView(self.goodsID, events: events)
                }
            }
            }.always {
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
    
    /**
     请求购物车商品数量
     */
    fileprivate func requestGoodsNum() {
        let req: Promise<CartGoodsNumData> = handleRequest(Router.endpoint( CartPath.goodsNum, param: nil))
        req.then { (value) -> Void in
            if let num = value.data?.goodsNum {
                self.cartNumber = num
                self.cartNumberChange()
            }
            }.always {
            }.catch { (error) in
//                if let err = error as? AppError {
//                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
//                }
        }

    }
    
}

extension GoodsDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.scheme == Const.URLScheme {
                guard let string = url.host?.removingPercentEncoding else { return }
                guard let baseModel = Mapper<BaseInnerURLData>().map(JSONString: string), let action = baseModel.action else { return }
                switch action {
                case .showGoodsAddress:
                    Navigator.openInnerURL(url)
                    decisionHandler(.cancel)
                case .showGoodsPromos:
                    self.requestGoodsEventsData()
                    decisionHandler(.cancel)
                case .alternativeGoods:
                    if goods.status == .onSale {
                        self.showChooseParam()
                    }
                    decisionHandler(.cancel)
                default:
                    break
                }
            } else {
                let urlString = String(describing: url)
                if urlString.contains("tel") {
                    let tel = NSString(string: urlString).substring(from: 4)
                    setTelAlertViewController(tel)
                }
            }
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let status = self.goods.status {
            switch status {
            case .onSale:
                break
            case .soldOut:
                self.setSellOutView(R.string.localizable.label_title_sold_out())
            case .shelves:
                self.setSellOutView(R.string.localizable.label_title_undercarriage())
            case .noneGoods:
                self.setNoneGoodsView()
            }
        }
        self.collectButton.isSelected = self.goods.isMarked == true ? true : false
        if self.goods.type == .service && self.addtoCartButton != nil {
            self.addtoCartButton.removeFromSuperview()
        }
        self.bottomStackView.isHidden = false
        self.bottomViewHeight.constant = 50
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.loading(view: view)
    }
    
}

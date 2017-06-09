//
//  BrandDetailViewController.swift
//  Bank
//
//  Created by yang on 16/2/23.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class BrandDetailViewController: BaseViewController {
    
    enum CollectionViewType {
        /// 全部商品
        case allGoods
        /// 置顶分类商品
        case catGoods
    }
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet var topStackView: UIStackView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var discountView: UIView!
    @IBOutlet var discountViewHeight: NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    
    var merchantID: String?
    var selectedGoods: Goods?
    fileprivate var merchant: Merchant?
    fileprivate var brandDetailMoreVC: BrandDetailMoreViewController?
    fileprivate var storeCatID: String?
    fileprivate var currentPage: Int = 1
    fileprivate var selectedTopCat: Classify?
    fileprivate var allGoodsArray: [Goods] = []
    fileprivate var classifyArray: [Classify] = []
    fileprivate var topCats: [Classify] = []
//    fileprivate var collectionViewType: CollectionViewType = .catGoods

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setCollectionView()
        requestData()
        requestAllGoods()
        addPullToRefresh()
    }
    
    deinit {
        if let collectionView = collectionView {
            if let topRefresh = collectionView.topPullToRefresh {
                collectionView.removePullToRefresh(topRefresh)
            }
            if let bottomRefresh = collectionView.bottomPullToRefresh {
                collectionView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let bottomRefresh = PullToRefresh(position: .bottom)
        collectionView.addPullToRefresh(bottomRefresh) { [weak self] (collectionView) -> Void in
            self?.requestAllGoods((self?.currentPage ?? 1) + 1)
            self?.collectionView.endRefreshing(at: .bottom)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods?.goodsID
        }
        if let vc = segue.destination as? ShopDetailViewController {
            vc.merchantID = merchant?.merchantID
        }
        
        if let vc = segue.destination as? SearchGoodsViewController {
            vc.searchType = .merchantGoods
            vc.merchantID = merchant?.merchantID
            vc.storeCatID = storeCatID
            setBackBarButtonWithoutTitle()
        } else {
            setBackBarButton()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setCollectionView() {
        collectionView.configBackgroundView()
        collectionView.register(R.nib.goodsCollectionViewCell)
        collectionView.register(R.nib.brandDetailCollectionReusableView(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: R.nib.brandDetailCollectionReusableView.identifier)
        collectionView.contentInset = UIEdgeInsets(top: headerView.frame.height, left: 0, bottom: 0, right: 0)
        headerView.frame = CGRect(x: 0, y: -headerView.frame.height, width: view.frame.width, height: headerView.frame.height)
        collectionView.addSubview(headerView)
    }
    
    /// 设置置顶分类
    fileprivate func setButtonTitle(cats: [Classify]) {
        var topCats: [Classify] = []
        // 找出所有分类中的置顶分类
        for cat in cats where cat.isTop == true {
            topCats.append(cat)
        }

        for cat in topCats {
            let button = UIButton(type: .custom)
            if let catID = Int(cat.classifyID) {
                button.tag = catID
            }
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            if let title = cat.name {
                button.setTitle(title, for: UIControlState())
            }
            button.setTitleColor(UIColor.darkGray, for: UIControlState())
            topStackView.addArrangedSubview(button)
        }
    }
    
    @objc fileprivate func buttonAction(_ btn: UIButton) {
//        storeCatID = topCats[btn.tag].classifyID
        storeCatID = String(btn.tag)
        performSegue(withIdentifier: R.segue.brandDetailViewController.showSearchVC, sender: nil)
    }
    
    /// 显示更多菜单
    @IBAction func moreMenuAction(sender: UIBarButtonItem) {
        let menuView = MenuView(frame: UIScreen.main.bounds)
        navigationController?.view.addSubview(menuView)
        menuView.imagesArray = [R.image.mall_brandZone_icon_call_menu(), R.image.mall_brandZone_icon_share_menu()]
        menuView.dataSorceArray = ["和我联系", "分享给好友"]
        menuView.menuTableView.frame = CGRect(x: self.view.bounds.width - 145, y: 60, width: 135, height: 80)
        menuView.showTableView()
        menuView.actionBlock = { index in

            switch index {
            case 0:
                //和我联系
                self.performSegue(withIdentifier: R.segue.brandDetailViewController.showShopDetailVC, sender: nil)
            case 1:
                //分享给好友
                guard let vc = R.storyboard.main.shareViewController() else {return}
                vc.sharePage = .shopDetail
                vc.shareID = self.merchantID
                vc.completeHandle = { [weak self] result in
                    self?.dim(.out)
                    self?.dismiss(animated: true, completion: nil)
                }
                self.dim(.in)
                self.present(vc, animated: true, completion: nil)
            default:
                break
            }
        }
        
    }
    
    @IBAction func moreAction(sender: UIButton) {
        if brandDetailMoreVC == nil {
            brandDetailMoreVC = R.storyboard.mall.brandDetailMoreViewController()
        }
        brandDetailMoreVC?.dataArray = self.classifyArray
        brandDetailMoreVC?.selectedMerchant = self.merchant
        brandDetailMoreVC?.view.frame = CGRect(x: -view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        brandDetailMoreVC?.selectedHandleBlock = { storeCatID in
            self.storeCatID = storeCatID
            self.performSegue(withIdentifier: R.segue.brandDetailViewController.showSearchVC, sender: nil)
        }
        if let vc = brandDetailMoreVC, let view = vc.view {
            addChildViewController(vc)
            self.view.addSubview(view)
        }
        
    }

    fileprivate func setDiscountView() {
        var items: [[Discount]] = []
        if let discountArray = merchant?.privilegeList?.filter({ return $0.type == .discount }) {
            if !discountArray.isEmpty {
                items.append(discountArray)
            }
        }
        if let fullCutArray = merchant?.privilegeList?.filter({ return $0.type == .fullCut }) {
            if !fullCutArray.isEmpty {
                items.append(fullCutArray)
            }
        }
        if !items.isEmpty {
            for (i, item) in zip(items.indices, items) {
                guard let view = R.nib.discountView.firstView(owner: nil) else {
                    return
                }
                view.frame = CGRect(x: 0.0, y: CGFloat(i) * 30.0, width: screenWidth, height: 30.0)
                view.configInfo(discounts: item)
                if i == 0 {
                    view.openButton.isHidden = false
                    view.openHandleBlock = { [weak self] in
                        guard let vc = R.storyboard.discount.discountViewController() else {
                            return
                        }
                        vc.merchantID = self?.merchantID
                        vc.dismissHandleBlock = {
                            vc.dismiss(animated: true, completion: nil)
                            self?.dim(.out)
                        }
                        self?.dim(.in)
                        self?.present(vc, animated: true, completion: nil)
                    }
                }
                discountView.addSubview(view)
            }
        }
        discountViewHeight.constant = CGFloat(items.count * 30)
        let height = CGFloat(160) + discountViewHeight.constant
        collectionView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        headerView.frame = CGRect(x: 0, y: -height, width: view.frame.width, height: height)
    }
}

// MARK: Request
extension BrandDetailViewController {
    /**
     请求店铺数据
     */
    func requestData() {
        MBProgressHUD.loading(view: view)
        let parame = GoodsParameter()
        parame.merchantID = merchantID
        let req: Promise<MerchantData> = handleRequest(Router.endpoint(GoodsPath.merchantInfo, param: parame), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                self.merchant = value.data
                self.setDiscountView()
                if let cover = self.merchant?.cover {
                    self.coverImageView.setImage(with: cover, placeholderImage: R.image.image_default_large())
                } else {
                    self.coverImageView.image = R.image.mall_brandZone_pic_banner_shop()
                }
                if let classifyList = value.data?.classifyList {
                    self.classifyArray = classifyList
                    self.setButtonTitle(cats: self.classifyArray)
                    self.title = self.merchant?.name
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
     请求店铺置顶分类商品
    */
    func requestTopGoodsData() {
        let param = GoodsParameter()
        param.merchantID = merchantID
        let req: Promise<MerchantTopCatsData> = handleRequest(Router.endpoint(GoodsPath.merchantTopCats, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.topCats {
                    self.topCats = items
                    
                    let allGoods = Classify()
                    allGoods.name = "全部商品"
                    allGoods.goodsList = self.allGoodsArray
                    self.topCats.append(allGoods)
                    self.collectionView.reloadData()
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
     请求全部商品
    */
    fileprivate func requestAllGoods(_ page: Int = 1) {
        let param = GoodsParameter()
        param.page = page
        param.perPage = 10
        param.merchantID = merchantID
        let req: Promise<GoodsListData> = handleRequest(Router.endpoint(GoodsPath.list, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.items, items.isEmpty == false {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.allGoodsArray = items
                    } else {
                        self.allGoodsArray.append(contentsOf: items)
                    }
                }
                self.requestTopGoodsData()
            }
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }

}

// MARK: - UICollectionViewDataSource
extension BrandDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return topCats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let goodsList = topCats[section].goodsList {
            return goodsList.count
        }
        return 0

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.goodsCollectionViewCell, for: indexPath) else {
            return UICollectionViewCell()
        }
        if let goodsList = topCats[indexPath.section].goodsList {
            cell.configInfo(goodsList[indexPath.item])
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: R.nib.brandDetailCollectionReusableView.identifier, for: indexPath) as? BrandDetailCollectionReusableView else {
            return UICollectionReusableView()
        }
        view.titleLabel.text = topCats[indexPath.section].name
        return view
    }

}

// MARK: - UICollectionViewDelegate
extension BrandDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let goodsList = topCats[indexPath.section].goodsList {
            self.selectedGoods = goodsList[indexPath.item]
        }
        performSegue(withIdentifier: R.segue.brandDetailViewController.showGoodsDetailVC, sender: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BrandDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 50) / 2, height: (view.frame.width - 50) / 2 / 160 * 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
}

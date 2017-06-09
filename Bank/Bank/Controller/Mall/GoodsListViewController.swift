//
//  GoodsListViewController.swift
//  Bank
//
//  Created by yang on 16/1/27.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

class GoodsListViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak fileprivate var backToTopButton: UIButton!
    @IBOutlet weak fileprivate var shoppingCartButton: TagButton!
    
    fileprivate var banner: Banner?
    fileprivate var goodsArray: [Goods] = []
    fileprivate var lastGoodsArray: [Goods] = []
    fileprivate var selectedGoods: Goods?
    fileprivate var listView: ListView!
    fileprivate var currentPage = 1
    fileprivate var selectedCatID: String!
    fileprivate var goodsSortArray: [GoodsSort] = []
    fileprivate var titleView: UITextField!
    fileprivate var collectionBannerURL: URL?
    fileprivate var selectSort: GoodsSort?
    fileprivate var goodsCatArray: [GoodsCats] = [] {
        didSet {
            var cats: [GoodsCats] = []
            for cat in goodsCatArray {
                cats.append(cat)
                cats.append(contentsOf: cat.subCats)
            }
            _ = cats.contains { (cat) -> Bool in
                if cat.catID == self.catID {
                    self.catName = cat.catName
                    self.goodsType = cat.catType
                    return true
                }
                return false
            }
            setListView(goodsCatArray)
        }
    }
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.collectionView.bounds, type: .other)}()
    
    var catID: String? = "0"
    var goodsType: GoodsType?
    var catName: String = R.string.localizable.string_title_all_cats()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        shoppingCartButton.layoutSubviews()
        setCollectionView()
        setTitleView()
        setBackButton()
        requestSortData()
        addPullToRefresh()
    }
    
    func setBackButton() {
        let image = R.image.btn_left_arrow()?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: -1.5, right: 5))
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 5, width: 30, height: 30)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButtonItem
        navigationItem.hidesBackButton = true
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    }

    @objc fileprivate func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setTitleView() {
        titleView = UITextField(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        titleView.backgroundColor = UIColor.white
        titleView.layer.cornerRadius = 2
        titleView.clearButtonMode = .always
        titleView.placeholder = R.string.localizable.placeHoder_title_enter_search_keywords()
        titleView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 30))
        titleView.leftViewMode = .always
        titleView.returnKeyType = .search
        titleView.delegate = self
        titleView.tintColor = UIColor(hex: 0x00a8fe)
        setTitleView(view: titleView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods?.goodsID
        }
        
        if let vc = segue.destination as? SearchGoodsViewController {
            vc.searchType = .allGoods
            setBackBarButtonWithoutTitle()
        } else {
            setBackBarButton()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == R.segue.goodsListViewController.showCartVC.identifier && !AppConfig.shared.isLoginFlag {
            return false
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppConfig.shared.isLoginFlag {
            requestGoodsNum()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let topRefresh = TopPullToRefresh()
        let bottomRefresh = PullToRefresh(position: .bottom)
        collectionView?.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestData((self?.currentPage ?? 1) + 1, sort: self?.selectSort, catID: self?.catID)
            self?.collectionView?.endRefreshing(at: .bottom)
        }
        collectionView?.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestData(sort: self?.selectSort, catID: self?.catID)
        }
    }

    func setCollectionView() {
        collectionView.register(R.nib.goodsCollectionViewCell)
        collectionView.register(R.nib.goodsListCollectionViewCell)
        collectionView.register(R.nib.goodsListCollectionReusableView(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: R.nib.goodsListCollectionReusableView.identifier)
        collectionView.configBackgroundView()
    }

    func setListView(_ goodsCatArray: [GoodsCats]) {
        
        let listTitleArray = ["\(catName)", R.string.localizable.string_title_default()]
        listView = ListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), titleArray: listTitleArray)
        listView.selectedCatID = catID
        listView.titleColor = UIColor(hex: 0x666666)
        listView.image = R.image.btn_open()
        listView.createDataSource(goodsCatArray, secondDatas: goodsCatArray[0].subCats, thirdDatas: goodsSortArray, firstIsCat: true)
        view.addSubview(listView)
        listView.selectedCatHandleBlock = { [weak self] (cat, isAll) in
            self?.goodsArray.removeAll()
            self?.currentPage = 1
            self?.catID = cat.catID
            self?.goodsType = cat.catType
            self?.requestData(1, sort: self?.selectSort, catID: self?.catID)
            self?.requestBanner()
        }
        listView.selectedSortHandleBlock = { [weak self] sort in
            self?.selectSort = sort
            self?.requestData(1, sort: self?.selectSort, catID: self?.catID)
        }
        
    }
    
    //返回
    @IBAction func goBackAction(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //滑到顶部
    @IBAction func backToTopAction(_ sender: UIButton) {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

}

// MARK: Request
extension GoodsListViewController {
    /**
     请求商品列表
     */
    func requestData(_ page: Int = 1, sort: GoodsSort! = nil, catID: String? = nil) {
        let hud = MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.page = page
        param.perPage = 20
        param.catID = catID
        if sort != nil {
            param.sortType = sort.sortID
        }
        let req: Promise<GoodsListData> = handleRequest(Router.endpoint( GoodsPath.list, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.items, items.isEmpty == false {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.goodsArray = items
                    } else {
                        self.goodsArray.append(contentsOf: items)
                    }
                }
                self.collectionView.reloadData()
            }
            if self.goodsArray.isEmpty {
                self.collectionView.addSubview(self.noneView)
            } else {
                self.noneView.removeFromSuperview()
            }
            }.always {
                self.collectionView?.endRefreshing(at: .top)
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     请求分类信息
     */
    func requestCatData() {
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<GoodsCatsListData> = handleRequest(Router.endpoint( GoodsPath.category, param: nil), needToken: .default)
        req.then { (value) -> Void in
            if var items = value.data?.cats {
                let wholeCat = GoodsCats()
                wholeCat.catID = "0"
                wholeCat.catName = R.string.localizable.string_title_all_cats()
                wholeCat.catType = .service
                for item in items {
                    wholeCat.subCats.append(contentsOf: item.subCats)
                }
                items.insert(wholeCat, at: 0)
                self.goodsCatArray = items
                self.requestBanner()
                self.requestData(sort: self.selectSort, catID: self.catID)
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
     请求排序信息
     */
    func requestSortData() {
        let req: Promise<GoodsSortListData> = handleRequest(Router.endpoint( GoodsPath.sort, param: nil), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.orderbyList {
                    self.goodsSortArray = items
                    self.requestCatData()
                }
            }
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     请求banner
     */
    func requestBanner() {
        let param = HomeBasicParameter()
        if goodsType == .merchandise {
            param.bannerPosition = BannerPosition.goodsBanner
        } else {
            param.bannerPosition = BannerPosition.serviceBanner
        }
        self.collectionBannerURL = nil
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let arr = value.data?.banners, arr.isEmpty == false {
                self.banner = arr[0]
                if let imageURL = self.banner?.imageURL {
                    self.collectionBannerURL = imageURL
                    self.collectionView.reloadData()
                }
            }
            }.always {
                
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
        let req: Promise<CartGoodsNumData> = handleRequest(Router.endpoint(CartPath.goodsNum, param: nil))
        req.then { (value) -> Void in
            if let num = value.data?.goodsNum {
                if num > 0 {
                    self.shoppingCartButton.tagView?.isHidden = false
                    self.shoppingCartButton.tagView?.setTitle(String(num), for: .normal)
                } else {
                    self.shoppingCartButton.tagView?.isHidden = true
                }
            }
            }.always {
            }.catch { (error) in
//                if let err = error as? AppError {
//                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
//                }
        }
        
    }

}

// MARK: UICollectionViewDataSource
extension GoodsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if goodsType == .merchandise {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.goodsCollectionViewCell, for: indexPath) else {
                return UICollectionViewCell()
            }
            cell.configInfo(goodsArray[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.goodsListCollectionViewCell, for: indexPath) else {
                return UICollectionViewCell()
            }
            cell.configInfo(goodsArray[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: R.nib.goodsListCollectionReusableView.identifier, for: indexPath) as? GoodsListCollectionReusableView else {
            return UICollectionReusableView()
        }
        headerView.imageHandleBlock = { [weak self] in
            if let URL = self?.banner?.url {
                Navigator.openInnerURL(URL)
            }
        }
        headerView.bannerImageView.setImage(with: collectionBannerURL, placeholderImage: R.image.image_default_large())
        headerView.bannerImageView.contentMode = .scaleAspectFill
        return headerView
    }
    
}

// MARK: UICollectionViewDelegate
extension GoodsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGoods = goodsArray[indexPath.item]
        performSegue(withIdentifier: R.segue.goodsListViewController.showGoodsDetailVC, sender: nil)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GoodsListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if goodsType == .merchandise {
            return CGSize(width: (view.frame.width - 50) / 2, height: (view.frame.width - 50) / 2 / 160 * 220)
        }
        return CGSize(width: view.frame.width, height: 105)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionBannerURL == nil ? 0 : 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if goodsType == .merchandise {
            return 8
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if goodsType == .merchandise {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

// MARK: UITextFieldDelegate
extension GoodsListViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.performSegue(withIdentifier: R.segue.goodsListViewController.showSearcheGoodsVC, sender: nil)
        return false
    }

}

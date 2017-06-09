//
//  MallHomeViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable cyclomatic_complexity

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD
import PullToRefresh

class MallHomeViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var shoppingCartButton: TagButton!
    fileprivate var headerView: MallHomeHeaderView?
    fileprivate var rect: CGRect?
    fileprivate var mallHome: MallHome?
    fileprivate var isCheckIn: Bool!
    fileprivate var goodsArray: [Goods] = []
    fileprivate var goodsCatList: [Banner] = []
    fileprivate var onlineEventBanners: [Banner] = []
    fileprivate var merchants: [Merchant] = []
    fileprivate var banners: [Banner] = []
    fileprivate var newsList: [News] = []
    fileprivate var homeSections: [HomeSection] = [.promotion, .brandZone]
    fileprivate var selectedOnlineEvent: OnlineEvent?
    fileprivate var selectedOfflineEvent: OfflineEvent?
    fileprivate var selectedGoods: Goods?
    fileprivate var selectedMerchant: Merchant?
    fileprivate var menuCat: GoodsCats?
    fileprivate var titleView: UISearchBar!
    fileprivate var checkinView: MallHomeCheckInView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shoppingCartButton.layoutSubviews()
        setTitleView()
        setTableView()
        addPullToRefresh()
        requestOnlineEvents()
        requestMallHomeData()
        requestBanners()
        requestGoodsCats()
        requestNewsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        setBackBarButton()
        if AppConfig.shared.isLoginFlag {
            requestGoodsNum()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        if let tableView = tableView {
            if let topRefresh = tableView.topPullToRefresh {
                tableView.removePullToRefresh(topRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        tableView.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestOnlineEvents()
            self?.requestMallHomeData()
            self?.requestBanners()
            self?.requestGoodsCats()
            self?.requestNewsList()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsListViewController {
            vc.catID = self.menuCat?.catID
            vc.goodsType = self.menuCat?.catType
            if let name = self.menuCat?.catName {
                vc.catName = name
            }
            setBackBarButtonWithoutTitle()
        }
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods?.goodsID
        }
        if let vc = segue.destination as? BrandDetailViewController {
            vc.merchantID = self.selectedMerchant?.merchantID
        }
        if let vc = segue.destination as? SearchGoodsViewController {
            vc.searchType = .allGoods
            setBackBarButtonWithoutTitle()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == R.segue.mallHomeViewController.showCartVC.identifier && !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return false
        }
        return true
    }
    
    func setTitleView() {
        titleView = UISearchBar(frame: CGRect(x: 0, y: 0, width: 400, height: 30))
        titleView.placeholder = "搜索"
        titleView.searchBarStyle = .minimal
        titleView.backgroundColor = UIColor(hex: 0x00a8fe)
        titleView.delegate = self
        titleView.setImage(R.image.btn_search(), for: .search, state: .normal)
        titleView.tintColor = UIColor(hex: 0x00a8fe)
        guard let textField = titleView.value(forKey: "_searchField") as? UITextField else {
            return
        }
        textField.backgroundColor = UIColor(hex: 0x4cc2fe)
        textField.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        textField.setValue(UIFont.systemFont(ofSize: 15), forKeyPath: "_placeholderLabel.font")
        textField.layer.cornerRadius = 2
        let view = UIView()
        textField.addSubview(view)
        view.backgroundColor = UIColor(hex: 0x4cc2fe)
        view.frame = titleView.bounds
        view.layer.cornerRadius = 2
        navigationItem.titleView = titleView
        shoppingCartButton?.layoutSubviews()
    }
    
    func setTableView() {
        headerView = R.nib.mallHomeHeaderView.firstView(owner: nil)
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = UIColor(hex: CustomKey.Color.viewBackgroundColor)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(R.nib.onlineEventTableViewCell)
        tableView.register(R.nib.trendEventTableViewCell)
        tableView.register(R.nib.brandZoneTableViewCell)
        tableView.register(R.nib.mallGoodsTableViewCell)
        tableView.register(R.nib.mallHomeSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.mallHomeSectionHeaderView.name)
        tableView.register(R.nib.homeSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.homeSectionHeaderView.name)
        setHeader()
    }
    
    func setHeader() {
        headerView?.signHandleBlock = { [weak self] sender in
            if self?.isCheckIn == true {
                if let view = self?.view {
                    MBProgressHUD.errorMessage(view: view, message: R.string.localizable.alertTitle_register_today_success())
                }
            } else {
                if AppConfig.shared.isLoginFlag {
                    self?.requsetCheckIn()
                } else {
                    self?.showSessionVC()
                }
            }
            sender.isEnabled = true
        }
        headerView?.menuHandleBlock = { segueID, cat in
            self.menuCat = cat
            self.performSegue(withIdentifier: segueID, sender: nil)
        }
        headerView?.newsHandleBlock = { segueID in
            self.performSegue(withIdentifier: segueID, sender: nil)
        }
        headerView?.newsDetailHandleBlock = { newsID in
            guard let vc = R.storyboard.news.newsDetailsViewController() else {
                return
            }
            vc.newsID = newsID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        headerView?.lotteryHandleBlock = { segueID in
            guard let vc = R.storyboard.mall.hotGoodsViewController() else { return }
            vc.goodsType = .service
            Navigator.push(vc)
        }
        headerView?.hotGoodsHandleBlock = { segueID in
            guard let vc = R.storyboard.mall.hotGoodsViewController() else { return }
            vc.goodsType = .merchandise
            Navigator.push(vc)
        }
    }

}

// MARK: Request
extension MallHomeViewController {
    
    /**
     签到
     */
    func requsetCheckIn() {
        let hud = MBProgressHUD.loading(view: view)
        let req: Promise<CheckInData> = handleRequest(Router.endpoint(MallPath.checkIn, param: nil))
        req.then {(value) -> Void in
            if self.checkinView == nil {
                self.checkinView = R.nib.mallHomeCheckInView.firstView(owner: nil)
                self.checkinView?.frame = UIScreen.main.bounds
                if let checkView = self.checkinView {
                    self.tabBarController?.view.addSubview(checkView)
                }
            }
            self.checkinView?.configInfo(value.data?.point)
            self.checkinView?.deleteHandleBlock = {
                self.checkinView?.removeFromSuperview()
            }
            self.isCheckIn = true
            self.headerView?.checkInButton.isSelected = true
        }.always {
           hud.hide(animated: true)
        }.catch { (error) in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
            }
        }

    }
    
    /**
     本地生活基本数据
     */
    func requestMallHomeData() {
        let hud = MBProgressHUD.loading(view: self.view)
        let req: Promise<MallHomeData> = handleRequest(Router.endpoint( MallPath.mallHome, param: nil), needToken: .default)
        req.then { value -> Void in
            if value.isValid {
                self.mallHome = value.data
                self.isCheckIn = value.data?.isCheckedIn
                self.headerView?.checkInButton.isSelected = self.isCheckIn == true ? true : false
                if let goods = value.data?.goodsList {
                    self.goodsArray = goods
                }
                if let merchants = value.data?.merchantList {
                    self.merchants = merchants
                }
                if let newsList = value.data?.newsList {
                    self.newsList = newsList
                    self.headerView?.setNews(newsList)
                }
                self.tableView.reloadData()
            }
            }.always {
                self.tableView.endRefreshing(at: .top)
                hud.hide(animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     请求banner
     */
    func requestBanners() {
        let param = HomeBasicParameter()
        param.bannerPosition = .mallHomeBanner
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        req.then { value -> Void in
            if let banners = value.data?.banners {
                self.banners = banners
            }
            self.headerView?.setBanner(self.banners)
            if let pageController = self.headerView?.pageController {
                self.addChildViewController(pageController)
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /**
     现场活动区banner
     */
    /*
    func requestOfflineEvents() {
        let param = HomeBasicParameter()
        param.bannerPosition = .mallHomeOfflineEvents
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param))
        req.then { value -> Void in
            if value.isValid {
                if let banners = value.data?.banners {
                    self.offlineEventBanners = banners
                }
                self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .none)
            }
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    */
    /**
     促销活动区banner
     */
    func requestOnlineEvents() {
        let param = HomeBasicParameter()
        param.bannerPosition = .mallHomePromo
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        req.then { value -> Void in
            if value.isValid {
                if let banners = value.data?.banners {
                    self.onlineEventBanners = banners
                }
                self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .none)
            }
            }.always {
                
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    /**
     请求资讯
     */
    fileprivate func requestNewsList() {
        let param = NewsParameter()
        param.position = .mallHomeNews
        param.type = NewsType.pointMallHeadline.rawValue
        let req: Promise<TopNewsListData> = handleRequest(Router.endpoint( NewsPath.topList, param: param), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let list = value.data?.topNews {
                    self.newsList = list
                    self.headerView?.setNews(self.newsList)
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
     请求购物车商品数量
     */
    fileprivate func requestGoodsNum() {
        let req: Promise<CartGoodsNumData> = handleRequest(Router.endpoint( CartPath.goodsNum, param: nil))
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
    
    /// 请求商品分类
    fileprivate func requestGoodsCats() {
        let param = HomeBasicParameter()
        param.bannerPosition = .mallHomeGoodsCats
        let req: Promise<BannerListData> = handleRequest(Router.endpoint( HomeBasicPath.homeBanner, param: param), needToken: .default)
        req.then { value -> Void in
            if value.isValid {
                if let banners = value.data?.banners {
                    self.goodsCatList = banners
                    self.headerView?.setCats(banners)
                }
//                tableView.reloadData()
            }
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: UITableViewDelegate
extension MallHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 1 {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.mallHomeSectionHeaderView.name) as? MallHomeSectionHeaderView else {
                return UIView()
            }
            header.sectionTitle = "猜你喜欢"
            return header
        } else {
            guard  let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.homeSectionHeaderView.name) as? HomeSectionHeaderView else {
                return UIView()
            }
            header.homeSectionType = homeSections[section]
            header.moreHandleBlock = { type in
                switch type {
                case .promotion:
                    if let vc = R.storyboard.mall.trendEventViewController() {
                        Navigator.push(vc)
                    }
                case .brandZone:
                    if let vc = R.storyboard.mall.moreBrandsViewController() {
                        Navigator.push(vc)
                    }
                default:
                    break
                }
            }
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = UIView()
            view.backgroundColor = UIColor(hex: 0xf7f7f7)
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 13
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 203
        case 1:
            return 240
        case 2:
            return 103
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard let goodsCell: MallGoodsTableViewCell = cell as? MallGoodsTableViewCell else {
            return
        }
        self.selectedGoods = goodsCell.goods
        self.performSegue(withIdentifier: R.segue.mallHomeViewController.showGoodsDetailVC, sender: nil)
    }

}

// MARK: Table View Data Source
extension MallHomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if onlineEventBanners.isEmpty {
                return 0
            }
            return 1
        } else if section == 1 {
            return 1
        } else {
            return goodsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.onlineEventTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configInfo(onlineEventBanners)
            cell.tapHandleBlock = { (segueID, banner) in
                if let URL = banner.url {
                    Navigator.openInnerURL(URL)
                }
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.brandZoneTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.setCyclePageController(merchants)
            addChildViewController(cell.pageController)
            cell.brandDetailHandleBlock = { (segueID, merchant) in
                self.selectedMerchant = merchant
                self.performSegue(withIdentifier: segueID, sender: nil)
            }
            cell.goodsDetailHandleBlcok = {(segueID, goods) in
                self.selectedGoods = goods
                self.performSegue(withIdentifier: segueID, sender: nil)
            }
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.mallGoodsTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configInfo(goodsArray[indexPath.row])
            cell.lineView.isHidden = false
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}

// MARK: UITextFieldDelegate
extension MallHomeViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.performSegue(withIdentifier: R.segue.mallHomeViewController.showSearchGoodsVC, sender: nil)
        return false
    }
}

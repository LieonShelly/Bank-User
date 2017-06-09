//
//  LifeViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/17/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable empty_count

import UIKit
import Alamofire
import ObjectMapper
import PromiseKit
import URLNavigator
import PullToRefresh
import PINCache

class LifeHomeViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var leftItem: UIBarButtonItem!
    fileprivate lazy var dataHelper: LifeHomeDataHelper = LifeHomeDataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleImageView(image: R.image.logo())
        setupTableView()
        requsetHomeEventsAndADs()
        requestAds()
        addPullToRefresh()
        if AppConfig.shared.isLoginFlag {
            requestSaveToken()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        setBackBarButton()
        requestShortcuts()
        handleLaunchURL()
        if AppConfig.shared.isLoginFlag {
            requestUnreadCount()
        } else {
            self.leftItem.image = R.image.btn_news()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if AppConfig.shared.userInfo?.isPasswordExpired == true {
//            showSetPassAlertController()
//        }
        // 未设置支付密码时提示
        let value = UserDefaults.standard.bool(forKey: CustomKey.UserDefaultsKey.isPaypassSet)
        if !value && AppConfig.shared.isLoginFlag {
            let alert = UIAlertController(title: nil, message: R.string.localizable.alertTitle_not_set_paypass(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .cancel, handler: { (action) in
                if let vc = R.storyboard.session.paypassNavigationController() {
                    self.tabBarController?.present(vc, animated: true, completion: nil)
                }
            }))
            present(alert, animated: true, completion: nil)
        }
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
            self?.requsetHomeEventsAndADs()
            self?.requestAds()
            self?.requestShortcuts()
            self?.requestUnreadCount()
//            self?.handleLaunchURL()
        }
    }
    
    @IBAction func unwindFromAnswerSuccess(_ segue: UIStoryboardSegue) {
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == R.segue.lifeHomeViewController.showNotificationVC.identifier ||
            identifier == R.segue.lifeHomeViewController.showScanVC.identifier) &&
            !AppConfig.shared.isLoginFlag {
            showSessionVC()
            return false
        }
        return true
    }
    
    private func handleLaunchURL() {
        if let url = AppConfig.shared.launchShortcutItemURL {
            Navigator.openInnerURL(url)
            AppConfig.shared.launchShortcutItemURL = nil
        }
    }
    
    /// 设置引导修改登录密码
    fileprivate func showSetPassAlertController() {
        let alert = UIAlertController(title: "修改登录密码", message: "目前使用的登录密码为初始密码，为保障安全，建议您及时修改", preferredStyle: .alert)
        let attrString = NSMutableAttributedString(string: "目前使用的登录密码为初始密码，为保障安全，建议您及时修改")
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: attrString.length))
        alert.setValue(attrString, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: { (action) in
//            self.loginSuccessHandle()
        }))
        alert.addAction(UIAlertAction(title: "去修改", style: .default, handler: { (action) in
            guard let vc = R.storyboard.setting.passwordSetupViewController() else {
                return
            }
            Navigator.push(vc)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LifeHomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = HomeSection(rawValue: section) else { return 0 }
        switch type {
        case .shortcuts:
            return 1
        case .goods:
            return 1
        case .promotion:
            let count = dataHelper.hotEventsBaners?.count ?? 0
            return min(count, 2)
        case .cityActivity:
            return 1
        case .watchAdvertisement:
            return dataHelper.merchantAds?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = HomeSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch type {
        case .shortcuts:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.shortcutsTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.reloadShortcuts(dataHelper.shortcuts)
            cell.shortcutBlock = { shortcut in
                if shortcut.menuID == QuickMenu.addNewMenu().menuID && !AppConfig.shared.isLoginFlag {
                    self.showSessionVC()
                    return
                }
                if let url = shortcut.url {
                    let str = String(describing: url)
                    if str.contains("Frecommendation") {
                        guard let vc = R.storyboard.main.shareViewController() else {
                            return
                        }
                        vc.sharePage = .inviteFriends
                        vc.completeHandle = { [weak self] result in
                            
                            self?.tabBarController?.dim(.out)
                            self?.tabBarController?.dismiss(animated: true, completion: nil)
                        }
                        self.tabBarController?.dim(.in)
                        self.tabBarController?.present(vc, animated: true, completion: nil)
                    } else {
                        Navigator.openInnerURL(url)
                    }
                   
                }
            }
            return cell
        case .goods:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.featureGoodsTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configGoods(dataHelper.goods)
            cell.configCats(dataHelper.cats)
            cell.catTapHandle = { [weak self] catID, type, name in
                guard let vc = R.storyboard.mall.goodsListViewController() else { return }
                vc.catID = catID
                vc.goodsType = type
                vc.catName = name
                self?.setBackBarButtonWithoutTitle()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            cell.goodsTapHandle = { [weak self] goodsID in
                guard let vc = R.storyboard.mall.goodsDetailViewController() else { return }
                vc.goodsID = goodsID
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        case .promotion:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.featureEventTableViewCell, for: indexPath), let baner = dataHelper.hotEventsBaners?[indexPath.row] else {
                return UITableViewCell()
            }
            cell.configData(baner)
            return cell
        case .cityActivity:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.cityActivityTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            if let models = dataHelper.cityEvents {
                cell.models = models
            }
            return cell
        case  .watchAdvertisement:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.advertTableViewCell, for: indexPath), let merchantAds = dataHelper.merchantAds else {
                return UITableViewCell()
            }
            if indexPath.row < merchantAds.count {
                cell.configInfo(merchantAds[indexPath.row])
//                cell.advertisement = dataHelper.merchantAds?[indexPath.row]
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: Table View Delegate
extension LifeHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = HomeSection(rawValue: indexPath.section) else { return }
        switch type {
        case .promotion:
            if let URL = dataHelper.hotEventsBaners?[indexPath.row].url {
                Navigator.openInnerURL(URL)
            }
            break
        case .watchAdvertisement:
            if let vc = R.storyboard.point.advertDetailViewController() {
                vc.advertID = dataHelper.merchantAds?[indexPath.row].advertID
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let type = HomeSection(rawValue: indexPath.section) else { return 0 }
        switch type {
        case .shortcuts:
            return 225
        case .goods:
            return 310
        case .cityActivity:
            return 170
        case .promotion:
            return 90
        case .watchAdvertisement:
            return 130
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= 1 {
            return 33
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let type = HomeSection(rawValue: section) else { return 0 }
        switch type {
        case .shortcuts:
            return CGFloat.leastNormalMagnitude
        case .goods:
            return CGFloat.leastNormalMagnitude
        case .watchAdvertisement:
            return 21
        case .promotion:
            return 24
        case .cityActivity:
            return 105
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.homeSectionFooterView.name) as? HomeSectionFooterView, let middleBaner = dataHelper.midleBanner else {
            return nil
        }
        guard let url = middleBaner.url else { return  nil }
        guard let type = HomeSection(rawValue: section) else { return nil }
        switch type {
        case .cityActivity:
                view.configData(middleBaner)
                view.tapBlock = {
                    Navigator.openInnerURL(url)
                }
            return view
        case .promotion:
            let view = UIView()
            view.backgroundColor = UIColor.white
            let subView = UIView()
            subView.backgroundColor = UIColor(hex: 0xf7f7f7)
            view.addSubview(subView)
            subView.snp.makeConstraints({ (make) in
                make.top.equalTo(view.snp.top).offset(10)
                make.left.equalTo(view).offset(0)
                make.right.equalTo(view).offset(0)
                make.bottom.equalTo(view).offset(0)
            })
            let lineView = UIView()
            subView.addSubview(lineView)
            lineView.backgroundColor = UIColor(hex: 0xe5e5e5)
            lineView.snp.makeConstraints({ (make) in
                make.left.equalTo(subView).offset(0)
                make.top.equalTo(subView).offset(0)
                make.right.equalTo(subView).offset(0)
                make.height.equalTo(0.8)
            })
            return view
        default:
             return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= 1 {
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: R.nib.homeSectionHeaderView.name) as? HomeSectionHeaderView else {
                return nil
            }
            view.homeSectionType = HomeSection(rawValue: section)
            view.moreHandleBlock = { [weak self] type in
                switch type {
                case .goods:
                    if let vc = R.storyboard.mall.hotGoodsViewController() {
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                case .promotion:
                    if let vc = R.storyboard.mall.trendEventViewController() {
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                case .cityActivity:
                    if let vc = R.storyboard.point.offlineEventViewController() {
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                case .watchAdvertisement:
                    if let vc = R.storyboard.point.advertViewController() {
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                default:
                    break
                }
            }
            return view
        }
        return nil
    }
    
}

extension LifeHomeViewController {
    fileprivate func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(R.nib.homeSectionHeaderView(), forHeaderFooterViewReuseIdentifier: R.nib.homeSectionHeaderView.name)
        tableView.register(R.nib.homeSectionFooterView(), forHeaderFooterViewReuseIdentifier: R.nib.homeSectionFooterView.name)
        tableView.register(R.nib.shortcutsTableViewCell)
        tableView.register(R.nib.featureEventTableViewCell)
        tableView.register(R.nib.featureGoodsTableViewCell)
        tableView.register(R.nib.advertTableViewCell)
        tableView.register(R.nib.cityActivityTableViewCell)
    }
    
    fileprivate func configBanner(_ banners: [Banner]) {
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for i in 0..<banners.count {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            let addView = UIImageView()
            addView.contentMode = .scaleAspectFill
            addView.setImage(with: banners[i].imageURL, placeholderImage: R.image.image_default_large())
            addViews.append(addView)
        }
        let pageController = CyclePageViewController(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        pageController.configDataSource(viewControllers: viewControllers, addViews: addViews)
        if let pageControllerView = pageController.view {
            tableView.tableHeaderView = pageControllerView
        }
        addChildViewController(pageController)
        //轮播的点击事件
        pageController.tapHandler = { index in
            if index < banners.count {
                let banner = banners[index]
                if let URL = banner.url {
                    Navigator.openInnerURL(URL)
                }
            }
        }
        
    }
}

extension LifeHomeViewController {
    /// 未读消息数
    fileprivate func requestUnreadCount() {
        if AppConfig.shared.isLoginFlag {
            dataHelper.requestUnreadCount { (count) in
                AppConfig.shared.unreadCount = count
                if count > 0 {
                    self.leftItem.image = R.image.btn_news_on()
                } else {
                    self.leftItem.image = R.image.btn_news()
                }
            }
        }
    }
    
    fileprivate func requestShortcuts() {
        dataHelper.requestShortcuts { [unowned self] in
            self.updateTableView(fromSection: .shortcuts)
        }
    }
    
    fileprivate func requestAds() {
        dataHelper.loadCityEvntsAndAds {
            self.updateTableView(fromSection: .cityActivity, sectionLength: 2)
        }
    }
    
    fileprivate func requsetHomeEventsAndADs() {
        dataHelper.initBaseData()
        dataHelper.requestGoodsCats { [unowned self] in
            self.updateTableView(fromSection: .goods)
        }
        dataHelper.requestTopBanner {
            self.configBanner(self.dataHelper.topBaners)
        }
//        BannerListData.getFromCache(key: "Cache_Home_Banners") { (data) in
//            if let banners = data.data?.banners {
//                self.configBanner(banners)
//            }
//        }
        dataHelper.requestMiddleBaner { [unowned self] in
            self.updateTableView(fromSection: .watchAdvertisement)
        }
        dataHelper.requestHotEventsBaners { [unowned self] in
            self.updateTableView(fromSection: .promotion)
        }
        dataHelper.requestGoods { [unowned self] in
            self.updateTableView(fromSection: .goods)
            self.tableView.endRefreshing(at: .top)
        }
    }
    
    fileprivate  func updateTableView(fromSection: HomeSection, sectionLength: Int = 1) {
        let indexSet = NSIndexSet(indexesIn: NSRange(location: fromSection.rawValue, length: sectionLength)) as IndexSet
        self.tableView.reloadSections(indexSet, with: .automatic)
    }
    
    fileprivate func requestSaveToken() {
        let param = UserParameter()
        param.registrationID = AppConfig.shared.registrationID
        param.deviceToken = AppConfig.shared.pushToken
        param.deviceMode = "1"
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(UserPath.savePushToken, param: param))
        req.then { (value) -> Void in
            }.catch { error in
                print(error.localizedDescription)
                self.requestSaveToken()
        }
        
    }
}

//
//  HotGoodsViewController.swift
//  Bank
//
//  Created by 杨锐 on 16/7/30.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PullToRefresh
import URLNavigator
import PromiseKit
import MBProgressHUD

class HotGoodsViewController: BaseViewController {

    @IBOutlet weak fileprivate var collectionView: UICollectionView!
    @IBOutlet weak fileprivate var flowLayout: UICollectionViewFlowLayout!
    fileprivate var currentPage: Int = 1
    fileprivate var goodsList: [Goods] = []
    fileprivate var selectedGoods: Goods?
    
    var goodsType: GoodsType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        if goodsType == .merchandise {
            title = R.string.localizable.controller_title_love_buy()
        } else if goodsType == .service {
            title = R.string.localizable.controller_title_love_food()
        } else {
            title = R.string.localizable.controller_title_hot_goods()
        }
        setCollectionView()
        requestData()
        addPullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods?.goodsID
        }
    }
    
    deinit {
        if let collectionView = collectionView {
            if let topRefresh = collectionView.topPullToRefresh {
                collectionView.removePullToRefresh(topRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let topRefresh = TopPullToRefresh()
        collectionView?.addPullToRefresh(topRefresh) { [weak self] in
            self?.requestData()
        }
    }
    
    func setCollectionView() {
        flowLayout.itemSize = CGSize(width: (view.frame.width - 50) / 2, height: (view.frame.width - 50) / 2 / 160 * 220)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        flowLayout.minimumLineSpacing = 8
        collectionView.configBackgroundView()
        collectionView.register(R.nib.goodsCollectionViewCell)
        collectionView.register(R.nib.goodsListCollectionViewCell)
    }
    
    /**
     请求热门商品列表
     */
    func requestData() {
        MBProgressHUD.loading(view: view)
        let param = GoodsParameter()
        param.goodsType = goodsType
        let req: Promise<HotGoodsListData> = handleRequest(Router.endpoint(GoodsPath.hotGoodsList, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let items = value.data?.hotGoodsList {
                self.goodsList = items
                self.collectionView.reloadData()
            }
            }.always {
                self.collectionView?.endRefreshing(at: .top)
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
}

// MARK: UICollectionViewDataSource
extension HotGoodsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if goodsType == .service {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.goodsListCollectionViewCell, for: indexPath) else {
                return UICollectionViewCell()
            }
            cell.configInfo(goodsList[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.goodsCollectionViewCell, for: indexPath) else {
                return UICollectionViewCell()
            }
            cell.configInfo(goodsList[indexPath.item])
            return cell
        }
    }
    
}

// MARK: UICollectionViewDelegate
extension HotGoodsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGoods = goodsList[indexPath.item]
        performSegue(withIdentifier: R.segue.hotGoodsViewController.showGoodsDetailVC, sender: nil)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HotGoodsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if goodsType == .service {
            return CGSize(width: view.frame.width, height: 105)
        }
        return CGSize(width: (view.frame.width - 50) / 2, height: (view.frame.width - 50) / 2 / 160 * 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if goodsType == .service {
            return 0
        }
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if goodsType == .service {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
}

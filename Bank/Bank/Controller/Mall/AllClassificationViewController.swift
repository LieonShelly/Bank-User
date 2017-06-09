//
//  AllClassificationViewController.swift
//  Bank
//
//  Created by yang on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class AllClassificationViewController: BaseViewController {

    @IBOutlet weak fileprivate var collectionView: UICollectionView!
    fileprivate var goodsCatsArray: [GoodsCats] = []
    fileprivate var goodsSubCatsArray: [GoodsCats] = []
    fileprivate var selectedCat: GoodsCats?
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.collectionView.bounds, type: .other)}()
    
    var itemWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        itemWidth = (view.frame.width - 40) / 4
        collectionView.configBackgroundView()
        collectionView.register(R.nib.classiftionCollectionViewCell)
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsListViewController {
            vc.catID = self.selectedCat?.catID
            if let catName = self.selectedCat?.catName {
                vc.catName = catName
            }
            vc.goodsType = self.selectedCat?.catType
            setBackBarButtonWithoutTitle()
        } else {
            setBackBarButton()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestData() {
        MBProgressHUD.loading(view: view)
        let req: Promise<GoodsCatsListData> = handleRequest(Router.endpoint( GoodsPath.category, param: nil), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if let items = value.data?.cats {
                    self.goodsCatsArray = items
                }
                self.collectionView.reloadData()
            }
            if self.goodsCatsArray.isEmpty {
                self.collectionView.addSubview(self.noneView)
            } else {
                self.noneView.removeFromSuperview()
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

extension AllClassificationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return goodsCatsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodsCatsArray[section].subCats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.classiftionCollectionViewCell, for: indexPath) else {
            return UICollectionViewCell()
        }
        goodsSubCatsArray = goodsCatsArray[indexPath.section].subCats
        cell.titleLabel.backgroundColor = UIColor.white
        cell.titleLabel.text = goodsSubCatsArray[indexPath.row].catName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseID: String = "sectionHeader"
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseID, for: indexPath) as? ClassiftionSectionHeaderView else {
            return UICollectionReusableView()
        }
        view.titleLabel.text = goodsCatsArray[indexPath.section].catName
        return view
    }

}

extension AllClassificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClassiftionCollectionViewCell else {
            return
        }
        cell.titleLabel.backgroundColor = UIColor(hex: 0xe5e5e5)
        selectedCat = goodsCatsArray[indexPath.section].subCats[indexPath.row]
        performSegue(withIdentifier: R.segue.allClassificationViewController.showGoodsListVC, sender: nil)
    }
}

extension AllClassificationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: 40)
    }
}

//
//  FeatureGoodsTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/29.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

fileprivate let cellSize = CGSize(width: 100, height: 142)

class FeatureGoodsTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var pageControl: UIPageControl!
    @IBOutlet fileprivate var catLabels: [UILabel]!
    @IBOutlet fileprivate var catIcons: [UIImageView]!
    @IBOutlet fileprivate var buttons: [UIButton]!
    
    fileprivate let numberOfItemsInSection: Int = 3
    
    fileprivate var oriGoods: [Goods] = []
    fileprivate var goods: [Goods] = []
    fileprivate var cats: [Banner] = []
    
    var catTapHandle: ((_ catID: String, _ catType: GoodsType, _ catName: String) -> Void)?
    var goodsTapHandle: ((_ goodsID: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.register(R.nib.featureGoodsCollectionCell)
        collectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for button in buttons {
            button.isEnabled = false
        }
    }
    
    func configGoods(_ goods: [Goods]) {
        self.goods = goods
        self.oriGoods = goods
        let result = goods.count % numberOfItemsInSection
        switch result {
        case 1:
            // plus 2 fake 
            let fake = [Goods(), Goods()]
            self.goods.append(contentsOf: fake)
        case 2:
            // plus 1 fake
            self.goods.append(Goods())
        default:
            break
        }
        collectionView.reloadData()
        let page = Int(ceil(Float(goods.count) / Float(numberOfItemsInSection)))
        pageControl.numberOfPages = page
    }
    
    func configCats(_ cats: [Banner]) {
        self.cats = cats
        for i in 0..<min(cats.count, 4) {
//            catLabels[i].text = cats[i].catName
            catIcons[i].setImage(with: cats[i].imageURL, placeholderImage: R.image.image_default_small())
            buttons[i].isEnabled = true
        }
    }
    
    @IBAction fileprivate func catHandle(_ sender: UIButton) {
        if sender.tag < cats.count {
            if let url = cats[sender.tag].url {
                Navigator.openInnerURL(url)
            }
        }
    }
    
}

extension FeatureGoodsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.featureGoodsCollectionCell, for: indexPath) else {
            return UICollectionViewCell()
        }
        let index = indexPath.section * numberOfItemsInSection + indexPath.row
        if index < goods.count {
            cell.configGoods(goods[index])
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pageControl.numberOfPages
    }
    
}

extension FeatureGoodsTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let minSpaceForCell = (collectionView.frame.width - cellSize.width * CGFloat(numberOfItemsInSection)) / 4.0
        return UIEdgeInsets(top: 0, left: minSpaceForCell, bottom: 0, right: minSpaceForCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let minSpaceForCell = (collectionView.frame.width - cellSize.width * CGFloat(numberOfItemsInSection)) / 4.0
        return minSpaceForCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.section * numberOfItemsInSection + indexPath.row
        if index < oriGoods.count {
            if let block = goodsTapHandle {
                block(oriGoods[index].goodsID)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating {
                let page = collectionView.contentOffset.x / collectionView.frame.width
                pageControl.currentPage = Int(ceil(page))
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating {
            let page = collectionView.contentOffset.x / collectionView.frame.width
            pageControl.currentPage = Int(ceil(page))
        }
    }
}

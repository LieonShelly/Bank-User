//
//  ShortcutsTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/6/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class ShortcutsTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var pageControl: UIPageControl!
    
    fileprivate var shortcutData: [QuickMenu] = []
    
    var shortcutBlock: ((_ shortcut: QuickMenu) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        pageControl.pageIndicatorTintColor = UIColor(hex: 0xe5e5e5)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0xb3b3b3)
        collectionView.register(R.nib.shortcutsViewCell)
        collectionView.backgroundColor = UIColor(hex: 0xffffff)
        collectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadShortcuts(_ items: [QuickMenu]) {
        shortcutData = items
        collectionView.reloadData()
        DispatchQueue.main.async { 
            let page = Int(ceil(self.collectionView.contentSize.width / self.frame.width))
            self.pageControl.numberOfPages = page
            self.pageControl.isHidden = page <= 1
        }
    }
    
    fileprivate func tapHandle(_ sender: QuickMenu?) {
        guard let shortcut = sender, let block = shortcutBlock else {
            return
        }
        block(shortcut)
    }
    
}

extension ShortcutsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.shortcutsViewCell, for: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configShortcuts(shortcutData[indexPath.row], index: indexPath as NSIndexPath, isHome: true)
        cell.buttonTapBlock = { [weak self] (menu) in
            self?.tapHandle(menu)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shortcutData.count
    }
}

extension ShortcutsTableViewCell: UICollectionViewDelegate {
    
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

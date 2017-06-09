//
//  HorizontalFlowLayout.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable legacy_constant
import UIKit

class HorizontalFlowLayout: UICollectionViewLayout {
    var itemSize = CGSize(width: 85, height: 80) {
        didSet {
            invalidateLayout()
        }
    }
    
    fileprivate var cellCount = 0
    fileprivate var boundsSize = CGSize.zero
    fileprivate var rowGap: CGFloat = 0
    fileprivate var columnGap: CGFloat = 10
    
    override func prepare() {
        cellCount = self.collectionView?.numberOfItems(inSection: 0) ?? cellCount
        boundsSize = self.collectionView?.bounds.size ?? boundsSize
    }
    
    override var collectionViewContentSize: CGSize {
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        
        rowGap = (boundsSize.width - (CGFloat(horizontalItemsCount) * itemSize.width)) / CGFloat(horizontalItemsCount + 1)
        
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        var size = boundsSize
        size.width = CGFloat(numberOfPages) * boundsSize.width
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for i in 0..<cellCount {
            let indexPath = IndexPath(row: i, section: 0)
            let attr = self.computeLayoutAttributesForCellAtIndexPath(indexPath)
            allAttributes.append(attr)
        }
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.computeLayoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func computeLayoutAttributesForCellAtIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let row = indexPath.row
        let bounds = self.collectionView?.bounds ?? CGRect.zero
        
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        
        let columnPosition = row % horizontalItemsCount
        let rowPosition = (row/horizontalItemsCount)%verticalItemsCount
        let itemPage = Int(floor(Double(row)/Double(itemsPerPage)))
        
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        var frame = CGRect.zero
        frame.origin.x = CGFloat(itemPage) * bounds.size.width + CGFloat(columnPosition) * itemSize.width + CGFloat(rowGap * CGFloat(columnPosition + 1))
        frame.origin.y = CGFloat(rowPosition) * (itemSize.height + columnGap)
        frame.size = itemSize
        attr.frame = frame
        
        return attr
    }

}

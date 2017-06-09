//
//  GoodsListCollectionReusableView.swift
//  Bank
//
//  Created by yang on 16/6/3.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable private_outlet
import UIKit

class GoodsListCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var bannerImageView: UIImageView!
    var imageHandleBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        bannerImageView.addGestureRecognizer(tap)
        
    }
    
    func tapAction(_ tap: UITapGestureRecognizer) {
        if let block = imageHandleBlock {
            block()
        }
    }
    
}

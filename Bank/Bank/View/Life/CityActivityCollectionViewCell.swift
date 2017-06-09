//
//  CityActivityCollectionViewCell.swift
//  Bank
//
//  Created by lieon on 2016/10/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Kingfisher
import URLNavigator

class CityActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var joinNumLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var btnTapAction: (() -> Void)?
    
    var cityEventModel: CityEvent? {
        didSet {
            imageView.setImage(with: cityEventModel?.cover, placeholderImage: R.image.image_default_midden())
            titleLabel.text = cityEventModel?.title
            guard let  joinStr = cityEventModel?.appointmentNum else { return }
            joinNumLabel.text = "\(joinStr)人参加"
            guard let point = cityEventModel?.point else { return }
            pointLabel.text = "\(point)积分"
        }
    }
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(immediateRegisterAction(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @IBAction func immediateRegisterAction(_ sender: AnyObject) {
//        if let vc = R.storyboard.point.offlineEventDetailViewController() {
//            vc.eventID = cityEventModel?.eventID
//            Navigator.push(vc)
//        }
        if let block = btnTapAction {
            block()
        }
    }
}

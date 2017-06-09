//
//  CityActivityTableViewCell.swift
//  Bank
//
//  Created by lieon on 2016/10/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

class CityActivityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var models: [CityEvent] = [] {
        didSet {
            configInfo(models: models)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configInfo(models: [CityEvent]) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for idx in 0 ..< models.count {
            if idx > 1 {
                break
            }
            guard let view = R.nib.cityActivityCollectionViewCell.firstView(owner: self, options: nil) else { return }
            let selectedEvent = models[idx]
            view.cityEventModel = selectedEvent
            view.btnTapAction = { _ in
                if let vc = R.storyboard.point.offlineEventDetailViewController() {
                    vc.eventID = selectedEvent.eventID
                    Navigator.push(vc)
                }
            }
            stackView.addArrangedSubview(view)
        }
        if models.count < 2 {
            let view = UIView()
            stackView.addArrangedSubview(view)
        }
    }
}

//
//  TrendEventTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/14.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

typealias EventButtonHandleBlock = (_ segueID: String, _ event: Banner) -> Void
class TrendEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak fileprivate var leftButton: UIButton!
    @IBOutlet weak fileprivate var rightButton: UIButton!
    var eventButtonHandleBlock: EventButtonHandleBlock?
    var theData: [Banner]?
    // 0 online, 1 offline
    var theTag: Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
        leftButton.imageView?.contentMode = .scaleAspectFill
        rightButton.imageView?.contentMode = .scaleAspectFill
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configOfflineEventInfo(_ data: [Banner]) {
        theData = data
        if let leftImageURL = data[0].imageURL {
            leftButton.kf.setImage(with: leftImageURL, for: .normal, placeholder: R.image.image_default_midden())
        }
        if let rightImageURL = data[1].imageURL {
            rightButton.kf.setImage(with: rightImageURL, for: .normal, placeholder: R.image.image_default_midden())
        }
        leftButton.clipsToBounds = true
        rightButton.clipsToBounds = true
        leftButton.layer.cornerRadius = 5
        rightButton.layer.cornerRadius = 5
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        if let block = eventButtonHandleBlock {
            if let array = theData {
                block(R.segue.mallHomeViewController.showOfflineEventDetailVC.identifier, array[sender.tag])
            }
        }

    }
}

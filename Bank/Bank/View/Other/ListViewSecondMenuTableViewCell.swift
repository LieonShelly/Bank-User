//
//  ListViewSecondMenuTableViewCell.swift
//  Bank
//
//  Created by yang on 16/4/6.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable private_outlet

import UIKit

class ListViewSecondMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet fileprivate weak var separtorView: UIView!
    @IBOutlet weak var titleLead: NSLayoutConstraint!
    @IBOutlet weak var imageLead: NSLayoutConstraint!
    var goodsSubCat: GoodsCats?
    var sort: GoodsSort!
    var catID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedImageView.isHidden = true
        separtorView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            selectedImageView.isHidden = false
            titleLabel.textColor = UIColor(hex: 0x00a8fe)
        } else {
            selectedImageView.isHidden = true
            titleLabel.textColor = UIColor.darkGray
        }
        // Configure the view for the selected state
    }
    
    func configCatInfo(_ cat: GoodsCats) {
        goodsSubCat = cat
        titleLabel.text = cat.catName
        separtorView.isHidden = true
        imageLead.constant = self.frame.width - 40
        titleLead.constant = 20
    }
    
    func configSortInfo(_ sort: GoodsSort) {
        self.sort = sort
        titleLabel.text = sort.name
        separtorView.snp.updateConstraints { (make) in
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            make.height.equalTo(0.5)
        }
        imageLead.constant = 16
        titleLead.constant = 50
        separtorView.isHidden = false
    }
    
}

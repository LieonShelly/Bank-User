//
//  HomeSectionHeaderView.swift
//  Bank
//
//  Created by Koh Ryu on 16/2/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

public enum HomeSection: Int {
    /// 快捷键
    case shortcuts = 0
    /// 热门商品
    case goods
    /// 促销精选
    case promotion
    /// 同城活动
    case cityActivity
    /// 看广告
    case watchAdvertisement
    /// 品牌专区
    case brandZone
    
    var name: String {
        switch self {
        case .goods:
            return R.string.localizable.section_goods()
       case .promotion:
            return R.string.localizable.section_promotion()
        case .cityActivity:
            return R.string.localizable.section_city_activity()
        case .watchAdvertisement:
            return R.string.localizable.section_watch_advertisement()
        case .brandZone:
            return R.string.localizable.section_brand_zone()
        default:
            return ""
        }
    }
    
    var rows: Int {
        switch self {
        case .shortcuts:
            return 1
        case .goods:
            return 1
        case .promotion:
            return 2
        case .cityActivity:
            return 1
        case .watchAdvertisement:
            return 2
        default:
            return 0
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .goods:
            return R.image.icon_ok3()
        case .promotion:
            return R.image.icon_ok2()
        case .cityActivity:
            return R.image.icon_ok1()
        case .watchAdvertisement, .brandZone:
            return R.image.icon_ok()
        default:
            return nil
        }
    }
    
    static var count: Int {
        return 5
    }
}

class HomeSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var button: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var moreHandleBlock: ((_ type: HomeSection) -> Void)?
    var homeSectionType: HomeSection? {
        didSet {
            titleLabel.text = homeSectionType?.name
            iconImageView.image = homeSectionType?.iconImage
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(hex: 0xf5f5f5)
        titleLabel.textColor = UIColor(hex: 0x666666)
        button.setTitleColor(UIColor(hex: 0x666666), for: UIControlState())
        iconImageView.image = iconImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 3), resizingMode: .stretch)
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        guard let block = moreHandleBlock, let type = homeSectionType else {
            return
        }
        block(type)
    }
}

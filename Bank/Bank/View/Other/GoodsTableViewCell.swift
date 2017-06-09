//
//  GoodsTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 11/20/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

typealias GoodsTapHandleBlock = (_ goods: Goods) -> Void

class GoodsTableViewCell: UITableViewCell {
    @IBOutlet fileprivate var stackView: UIStackView!
    
    var tapHandle: GoodsTapHandleBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configGoods(_ goods: [Goods]) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for idx in 0 ..< goods.count {
            guard let view = R.nib.saleGoodsView.firstView(owner: self, options: nil) else {
                return
            }
            view.configGoods(goods[idx])
            view.tapHandle = { goods in
                if let block = self.tapHandle {
                    block(goods)
                }
            }
            stackView.addArrangedSubview(view)
        }
    }
    
}

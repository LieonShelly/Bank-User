//
//  ReplyContentView.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/27.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator

class ReplyContentView: UIView {
    
    var replyContent: ReplyContent?
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var label: UILabel!
    @IBOutlet fileprivate weak var detailButoonBottomCons: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var detailButton: UIButton!
    
    @IBAction func detailButtonClick(_ sender: AnyObject) {
        let vc = ProductDetailViewController()
        if let reply = replyContent, let link = reply.detailLink {
            vc.url = link
        }
        Navigator.push(vc)
    }
    
    func configData(_ content: ReplyContent) {
        replyContent = content
        label.text = content.content
        titleLabel.text = content.contentSubTypeName
    }
    
    func replyViewHeight(_ reply: ReplyContent) -> CGFloat {
    
        configData(reply)
        self.layoutIfNeeded()
        print(detailButton.frame.maxY  + detailButoonBottomCons.constant)
        return detailButton.frame.maxY  + detailButoonBottomCons.constant + 10
      
    }

}

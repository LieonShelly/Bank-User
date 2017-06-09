//
//  AnswerMediaItem.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class AnswerMediaItem: JSQMediaItem {
    
    fileprivate var cachedReplyView: ReplyContentView?
    fileprivate var reply: ReplyContent?
    
    convenience init(reply: ReplyContent?) {
        self.init()
        self.reply = reply
        cachedReplyView = nil
    }
    
    override func mediaHash() -> UInt {
        return UInt(self.hash)
    }
    
    override func mediaView() -> UIView! {
        if cachedReplyView == nil {
            let size = mediaViewDisplaySize()
            let outgoing = appliesMediaViewMaskAsOutgoing
            
            let contentView = R.nib.replyContentView.firstView(owner: nil)
            contentView?.frame = CGRect(origin: .zero, size: size)
            if let reply = reply {
                contentView?.configData(reply)
            }
            let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble:UIImage(named: "bubble_ingoing"), capInsets: bubbleEdgeInsets))
            if outgoing {
                masker?.applyOutgoingBubbleImageMask(toMediaView: contentView)
            } else {
                masker?.applyIncomingBubbleImageMask(toMediaView: contentView)
            }
            cachedReplyView = contentView
        }
        return cachedReplyView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        let view = R.nib.replyContentView.firstView(owner: nil)
        if let reply = reply {
            view?.configData(reply)
            let height = view?.replyViewHeight(reply)
            guard let h = height else {
                return CGSize(width: 245, height: 133)
            }
            return CGSize(width: 245, height: h)
        } else {
            return CGSize(width: 245, height: 133)
        }
    }
    
    override func mediaPlaceholderView() -> UIView! {
        let contentView = R.nib.replyContentView.firstView(owner: nil)
        let size = mediaViewDisplaySize()
        if contentView != nil {
            contentView?.frame = CGRect(origin: .zero, size: size)
            return contentView
        }
        return UIView()
    }
}

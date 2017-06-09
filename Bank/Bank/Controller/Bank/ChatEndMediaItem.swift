//
//  ChatEndMediaItem.swift
//  Bank
//
//  Created by lieon on 16/8/11.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController

typealias VaulueBlock = () -> Void

class ChatEndMediaItem: JSQMediaItem {

    var cachedChatEndView: ChatEndView?
    var chatEndMessageIDBlock: VaulueBlock?
    
    override func mediaHash() -> UInt {
        return UInt(self.hash)
    }
    
    override func mediaView() -> UIView! {
        if cachedChatEndView == nil {
            let size = mediaViewDisplaySize()
            let outgoing = appliesMediaViewMaskAsOutgoing
            let contentView = R.nib.chatEndView.firstView(owner: nil)
            contentView?.frame = CGRect(origin: .zero, size: size)
            contentView?.btnClickBlock = chatEndMessageIDBlock
            let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble:UIImage(named: "bubble_ingoing"), capInsets: bubbleEdgeInsets))
            if outgoing {
                masker?.applyOutgoingBubbleImageMask(toMediaView: contentView)
            } else {
                masker?.applyIncomingBubbleImageMask(toMediaView: contentView)
            }
            cachedChatEndView = contentView
        }
        return cachedChatEndView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
      
        let width = UIScreen.main.bounds.size.width - 30 * 2 - 10
            return CGSize(width: width, height: 120)
        }
    
    override func mediaPlaceholderView() -> UIView! {
        let contentView = R.nib.chatEndView.firstView(owner: nil)
        let size = mediaViewDisplaySize()
        if let view = contentView {
            view.frame = CGRect(origin: .zero, size: size)
            return view
        }
        return UIView()
    }
    
}

//
//  ProductMediaItem.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ProductMediaItem: JSQMediaItem {
    fileprivate var shareContent: SharedProduct?
    fileprivate var cachedSharedProductView: ShareProductView?
    convenience init(sharedProduct: SharedProduct?) {
        self.init()
        self.shareContent = sharedProduct
        self.cachedSharedProductView = nil
    }
    
    override func mediaHash() -> UInt {
        return UInt(self.hash)
    }
    
    override func mediaView() -> UIView! {
        if cachedSharedProductView == nil {
            let size = mediaViewDisplaySize()
            let outgoing = appliesMediaViewMaskAsOutgoing
            
            let contentView = R.nib.shareProductView.firstView(owner: nil)
            contentView?.frame = CGRect(origin: .zero, size: size)
            if shareContent != nil {
//                contentView?.configData(reply)
            }
            let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: outgoingBubble)
            if outgoing {
                masker?.applyOutgoingBubbleImageMask(toMediaView: contentView)
            } else {
                masker?.applyIncomingBubbleImageMask(toMediaView: contentView)
            }
            cachedSharedProductView = contentView
        }
        return cachedSharedProductView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        let view = R.nib.replyContentView.firstView(owner: nil)
        if shareContent != nil {
//            view?.configData(reply)
            let size = view?.systemLayoutSizeFitting(CGSize(width: 245, height: CGFloat.greatestFiniteMagnitude))
            return size ?? CGSize(width: 245, height: 133)
        } else {
            return CGSize(width: 245, height: 133)
        }
    }
    
    override func mediaPlaceholderView() -> UIView! {
        let contentView = R.nib.shareProductView.firstView(owner: nil)
        let size = mediaViewDisplaySize()
        if contentView != nil {
            contentView?.frame = CGRect(origin: .zero, size: size)
            return contentView
        }
        return UIView()
    }
}

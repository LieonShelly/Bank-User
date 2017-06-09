//
//  WithDrawMdeiaItem.swift
//  Bank
//
//  Created by lieon on 16/8/15.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class WithDrawMdeiaItem: JSQMediaItem {
    
    var  title: String = ""
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    override func mediaHash() -> UInt {
        return UInt(self.hash)
    }
    
    override func mediaView() -> UIView! {
        
        print("mediaView\(title)")
        let outgoing = appliesMediaViewMaskAsOutgoing
        let contentView = R.nib.withDrawView.firstView(owner: nil)
        if title != "" {
             contentView?.configData(title)
        }
        let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: JSQMessagesBubbleImageFactory(bubble: R.image.bubble_ingoing(), capInsets: bubbleEdgeInsets))
        if outgoing {
            masker?.applyOutgoingBubbleImageMask(toMediaView: contentView)
        } else {
            masker?.applyIncomingBubbleImageMask(toMediaView: contentView)
        }
       let size = mediaViewDisplaySize()
       contentView?.frame = CGRect(origin: .zero, size: size)
            
       return contentView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        print("mediaViewDisplaySize\(title)")
        return CGSize(width: 143, height: 44)
    }
    
    override func mediaPlaceholderView() -> UIView! {
        let view = R.nib.withDrawView.firstView(owner: nil)
        let size = mediaViewDisplaySize()
        if view != nil {
            view?.frame = CGRect(origin: .zero, size: size)
            return view
        }
        return UIView()
    } 

}

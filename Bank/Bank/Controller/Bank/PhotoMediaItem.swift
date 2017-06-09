//
//  PhotoMediaItem.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController

private let maxWidth: CGFloat = 240
private let maxHeight: CGFloat = 250
private let fixedRatio: CGFloat = maxWidth / maxHeight

class PhotoMediaItem: JSQMediaItem {
    
    fileprivate var cachedImageView: UIImageView?
    fileprivate var image: ChatImage?
    
    convenience init(image: ChatImage?) {
        self.init()
        self.image = image
        cachedImageView = nil
    }
    
    override func mediaHash() -> UInt {
        return UInt(self.hash)
    }
    
    override func mediaView() -> UIView! {
        if cachedImageView == nil {
            let size = mediaViewDisplaySize()
            let outgoing = appliesMediaViewMaskAsOutgoing
            
            let imageView = UIImageView()
            imageView.frame = CGRect(origin: .zero, size: size)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.setImageWithURL(image?.srcURL, placeholderImage: R.image.image_default())
            let masker = JSQMessagesMediaViewBubbleImageMasker(bubbleImageFactory: outgoingBubble)
            if outgoing {
                masker?.applyOutgoingBubbleImageMask(toMediaView: imageView)
            } else {
                masker?.applyIncomingBubbleImageMask(toMediaView: imageView)
            }
            self.cachedImageView = imageView
        }
        return self.cachedImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        if let size = image?.size, size != CGSize.zero {
            let ratio = size.width / size.height
            if ratio > fixedRatio {
                let height = maxWidth / ratio
                return CGSize(width: maxWidth, height: height)
            } else if ratio < fixedRatio {
                let width = maxHeight * ratio
                return CGSize(width: width, height: maxHeight)
            } else {
                return CGSize(width: maxWidth, height: maxHeight)
            }
        } else {
            return CGSize(width: maxWidth, height: maxHeight)
        }
    }
    
    override func mediaPlaceholderView() -> UIView! {
        let size = mediaViewDisplaySize()
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imageView.image = R.image.image_default()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return JSQMessagesMediaPlaceholderView(frame: CGRect(origin: .zero, size: size), backgroundColor: UIColor.white, imageView: imageView)
    }
}

//
//  ChatUIHelper.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/26.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ImagePicker

//let bubbleEdgeInsets = UIEdgeInsets(top: 25, left: 5, bottom: 5, right: 10)
let bubbleEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 30, right: 27)
public let outgoingBubble = JSQMessagesBubbleImageFactory(bubble: R.image.bubble_outgoing(), capInsets: bubbleEdgeInsets)
public let ingoingBubble = JSQMessagesBubbleImageFactory(bubble: R.image.bubble_ingoing(), capInsets: bubbleEdgeInsets)

extension ChatWithButlerViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let message = messages[indexPath.item]
        
        return message.jsqMessage
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.jsqMessage?.senderId == senderId {
            return outgoingBubbleImageView
        } else if message.jsqMessage?.senderId == chatEndSenderID {
            return JSQMessagesBubbleImage(messageBubble: UIImage(), highlightedImage: UIImage())
        } else {
            return incomingBubbleImageView 
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.jsqMessage?.senderId == senderId { // 2
            return outgoingAvatar
        } else { // 3
            return ingoingAvatar
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: Date!) {
        
        requestSendMessage(text)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as? JSQMessagesCollectionViewCell else {
                return JSQMessagesCollectionViewCell()
        }
        let message = messages[indexPath.item]
        if (message.jsqMessage?.isMediaMessage) == false {
            if message.jsqMessage?.senderId == senderId {
                cell.textView?.textColor = UIColor.white

            } else {
                cell.textView?.textColor = UIColor.black
            }
        }
        if message.messageType == MessageType.conversationEnd {
            cell.isUserInteractionEnabled = true
            cell.avatarImageView.isHidden = true
        } else {
            cell.avatarImageView.isHidden = false
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        let mes = message.jsqMessage
        if indexPath.item % 3 == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: mes?.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 40
    }
    
}

// MARK: - Image Picker Delegate
extension ChatWithButlerViewController: ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true) {
            self.requestSendPhoto(images)
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

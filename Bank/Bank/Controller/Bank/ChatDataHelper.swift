//
//  ChatHelper.swift
//  Bank
//
//  Created by Koh Ryu on 16/4/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//  swiftlint:disable cyclomatic_complexity

import UIKit
import JSQMessagesViewController
import PromiseKit
import URLNavigator
import ImagePicker
import Alamofire
import AlamofireImage
import MBProgressHUD

extension ChatWithButlerViewController {
    
    internal func initData() {
        MBProgressHUD.loading(view: view)
        requestMessages().then { value -> Promise<Image?> in
            if let user = value.data?.user, let butler = value.data?.butler {
                self.user = user
                self.butler = butler
                
                if let mobile = butler.mobile, !mobile.isEmpty {
                    self.navigationItem.rightBarButtonItem = self.rightItem
                } else {
                    self.navigationItem.rightBarButtonItem = nil
                }
                
                self.messages.append(contentsOf: self.transDataToMessage(value.data?.items))
                return handleDownloadPhoto(user.imageURL)
            } else {
                let error = AppError(code: RequestErrorCode.unknown)
                throw error
            }
            
            }.then { object -> Promise<Image?> in // 获取照片
                if let image = object {
                    self.outgoingAvatar.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: self.diameter)
                    self.outgoingAvatar.avatarHighlightedImage = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: self.diameter)
                }
                return handleDownloadPhoto(self.butler.imageURL)
            }.then { (object) -> Void in // 获取头像
                if let image = object {
                    self.ingoingAvatar.avatarImage = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: self.diameter)
                    self.ingoingAvatar.avatarHighlightedImage = JSQMessagesAvatarImageFactory.circularAvatarImage(image, withDiameter: self.diameter)
                }
            }.always {
                self.finishReceivingMessage()
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
                }
        }
    }
    
    internal func transDataToMessage(_ items: [ButlerChatMessage]?) -> [ButlerMessage] {
        var result: [ButlerMessage] = []
        guard let items = items else {
            return result
        }
        for item in items {
            var senderID: String = ""
            var displayName: String = ""
            let message: ButlerMessage?
            let content = item.message
            if let type = item.type, let date = item.created {
                switch type {
                case .photoFromClient, .videoFromClient, .reviewFromClient:
                    senderID = user.userID
                    displayName = user.name
                    let photoItem = PhotoMediaItem(image: item.image)
                    photoItem.appliesMediaViewMaskAsOutgoing = true
                    if let jsqMessage = JSQMessage(senderId: senderID, senderDisplayName: displayName, date: date, media: photoItem) {
                        message = ButlerMessage(chatEndMessageID: item.messageID, jsqMessage: jsqMessage, messageType: type)
                        if let mes = message {
                            result.append(mes)
                        }
                    }
                case .textFromClient :
                    senderID = user.userID
                    displayName = user.name
                    if let jsqMessage = JSQMessage(senderId: senderID, senderDisplayName: displayName, date: date, text: content) {
                        message = ButlerMessage(chatEndMessageID: item.messageID, jsqMessage: jsqMessage, messageType: type)
                        if let mes = message {
                            result.append(mes)
                        }
                    }
                case .conversationEnd, .replyFromButler, .shareFromButler, .withdrawalFromButler:
                    senderID = butler.butlerID
                    displayName = butler.name
                    let jsqMessage =  creatMediaMessageWithModel(item)
                    message = ButlerMessage(chatEndMessageID: item.messageID, jsqMessage: jsqMessage, messageType: type)
                    if let mes = message {
                        result.append(mes)
                    }
                default:
                    break
                }
                
            }
           
        }
        return result
    }
    
    internal func requestMessages(_ topID: String? = nil, bottomID: String? = nil) -> Promise<ChatDetailData> {
        let param = ButlerParameter()
        if let top = topID {
            param.chatsListTopId = top
        }
        if let bottom = bottomID {
            param.chatsListBottomId = bottom
        }
        let req: Promise<ChatDetailData> = handleRequest(Router.endpoint(endpoint: ButlerPath.chats, param: param))
        return req
    }
    
    internal func requestSendMessage(_ message: String) {
        let param = ButlerParameter()
        param.sendContent = message
        param.type = .textFromClient
        
        MBProgressHUD.loading(view: self.view)
        let req: Promise<SendMessageData> = handleRequest(Router.endpoint(endpoint: ButlerPath.sendMessage, param: param))
        
        req.then { [weak self] (value) -> Void in
            self?.finishedSending(value)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    internal func finishedSending(_ value: SendMessageData) {
        if let items = value.data?.items, !items.isEmpty {
            self.messages.append(contentsOf: self.transDataToMessage(items))
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()
        }
    }
    
    internal func requestSendPhoto(_ photos: [UIImage]) {
        MBProgressHUD.loading(view: view)
        let datas = photos.map { (image) -> Data in
            guard let data =  UIImageJPEGRepresentation(image, 0.5) else {
                return Data()
            }
            return data
        }
        let uploadParam = FileUploadParameter()
        uploadParam.dir = .butlerChat
        let upload: Promise<FileUploadResponse> = handleUpload(Router.upload(endpoint: FileUploadPath.upload), param: uploadParam, fileData: datas)
        upload.then { (uploadResponse) -> Promise<SendMessageData> in
            if let list = uploadResponse.data?.successList, !list.isEmpty {
                let sendParam = ButlerParameter()
                let content = list.flatMap { (object) -> String? in
                    return object.url?.absoluteString
                }
                sendParam.sendContent = content
                sendParam.type = .photoFromClient
                let req: Promise<SendMessageData> = handleRequest(Router.endpoint(endpoint: ButlerPath.sendMessage, param: sendParam))
                return req
            } else {
                let err = AppError(code: RequestErrorCode.unknown, msg: R.string.localizable.error_title_uploa_failure())
                throw err
            }
            }.then { (value) -> Void in
                self.finishedSending(value)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    fileprivate func creatMediaMessageWithModel(_ item: ButlerChatMessage) -> JSQMessage {
        if  let type = item.type {
            switch type {
            case .conversationEnd:
                let chatEndItem =  ChatEndMediaItem()
                chatEndItem.chatEndMessageIDBlock = {
                    guard let vc = R.storyboard.bank.evaluateViewController() else { return}
                    vc.transitioningDelegate = self.animator
                    vc.modalPresentationStyle = UIModalPresentationStyle.custom
                    vc.chatDetailId = item.messageID
                    self.present(vc, animated:true, completion: nil)
                }
                return JSQMessage(senderId: chatEndSenderID, displayName: " ", media: chatEndItem)
            case .replyFromButler:
                return JSQMessage(senderId: butler.butlerID, displayName: butler.name, media: AnswerMediaItem(reply: item.replyContent))
            case .shareFromButler:
                return JSQMessage(senderId: butler.butlerID, displayName: butler.name, media: ProductMediaItem(sharedProduct: item.shareProduct))
            case .withdrawalFromButler:
                return JSQMessage(senderId: butler.butlerID, displayName:  butler.name, media: WithDrawMdeiaItem(title: R.string.localizable.titleLabel_title_revoke_message()))
            default:
                break
            }
        }
    return JSQMessage(senderId: " ", displayName: " ", media: nil)
    }
    
    internal func isEndMessage(_ message: ButlerMessage) -> Bool {
        return message.chatEndMessageID == "6" ? true : false
    }
}

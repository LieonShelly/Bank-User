//
//  ChatWithButlerViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/9.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import PromiseKit
import URLNavigator
import ImagePicker

class ChatWithButlerViewController: JSQMessagesViewController {
    
    internal var rightItem: UIBarButtonItem?
    
    internal var messages: [ButlerMessage] = []
    internal var outgoingBubbleImageView: JSQMessagesBubbleImage!
    internal var incomingBubbleImageView: JSQMessagesBubbleImage!
    internal var outgoingAvatar: JSQMessagesAvatarImage!
    internal var ingoingAvatar: JSQMessagesAvatarImage!
    
    internal var imagePicker: ImagePickerController!
    internal let diameter = UInt(kJSQMessagesCollectionViewAvatarSizeDefault)
    internal let chatEndSenderID = "-1_-2_3_*_%"
    
    internal var user = User() {
        didSet {
            if !user.userID.isEmpty {
                senderId = user.userID
            }
            if !user.name.isEmpty {
                senderDisplayName = user.name
            }
        }
    }
    internal var butler = Butler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.controller_title_contact_butler()
        hidesBottomBarWhenPushed = true
        tabBarController?.tabBar.isHidden = true
        rightItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_callup(), style: .plain, target: self, action: #selector(self.callButler))
        navigationItem.rightBarButtonItem = rightItem
        senderId = "-1"
        senderDisplayName = "  "
        if let userInfo = AppConfig.sharedManager.userInfo {
            user = userInfo
        }
        setupSetting()
        collectionView?.backgroundColor = .colorFromHex(0xF5F5F5)
        
        imagePicker = ImagePickerController()
        imagePicker.delegate = self
        Configuration.doneButtonTitle = R.string.localizable.button_title_finish()
        initData()
    }
    
    @objc fileprivate func callButler() {
        if let mobile = butler.mobile, let URL = URL(string: "tel://\(mobile)") {
            let alertVC = UIAlertController(title: "", message: R.string.localizable.alertTitle_is_call_butler(), preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_call(), style: .default, handler: { (action) in
                UIApplication.shared.openURL(URL)
            }))
            alertVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func setupSetting() {
        
        outgoingBubbleImageView = outgoingBubble?.outgoingMessagesBubbleImage(
            with: .colorFromHex(0x4CC2FE))
        incomingBubbleImageView = outgoingBubble?.incomingMessagesBubbleImage(
            with: UIColor.white)
        
        let placeHolderImage = R.image.btn_avatar_default()
        outgoingAvatar = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: placeHolderImage)
        ingoingAvatar = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: placeHolderImage)
        inputToolbar.contentView.leftBarButtonItem.setImage(UIImage(named: "btn_pick_image" ), for: UIControlState())
        inputToolbar.contentView.leftBarButtonItem.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        inputToolbar.contentView.rightBarButtonItem.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
            inputToolbar.contentView.textView.placeHolder = R.string.localizable.placeHoder_title_enter_question()
            inputToolbar.contentView.leftContentPadding = 15
        
        inputToolbar.contentView.rightContentPadding = 15
        inputToolbar.preferredDefaultHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal lazy var animator: TransitionAnimator = {
        let animator = TransitionAnimator()
        let x: CGFloat = 30
        let height: CGFloat = 150.0
        let y: CGFloat = self.collectionView.center.y - height * 0.5
        let width: CGFloat = self.collectionView.frame.size.width - 30 * 2
        animator.presentFrame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
        return animator
    }()
    
}

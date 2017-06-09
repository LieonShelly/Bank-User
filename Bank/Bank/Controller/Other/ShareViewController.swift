//
//  ShareViewController.swift
//  Bank
//
//  Created by Herb on 16/7/19.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import MonkeyKing
import PromiseKit
import URLNavigator
import MBProgressHUD

public enum ShareType: Int {
    case qqFriends = 0
    case wechatSession
    case wechatTimeline
    
    var channel: String {
        switch self {
        case .qqFriends:
            return "3"
        case .wechatSession:
            return "1"
        case .wechatTimeline:
            return "2"
        }
    }
}

class ShareViewController: BaseViewController {
    
    var sharePage: SharedPage?
    var shareID: String?
    var completeHandle: ((_ result: Bool) -> Void)?
    fileprivate var shareContent: ShareAppContent?
    fileprivate var shareType: ShareType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        MonkeyKing.registerAccount(.weChat(appID: Const.Wechat.appID, appKey: Const.Wechat.appSecret))
        MonkeyKing.registerAccount(.qq(appID: Const.Tencent.appID))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func shareHandle(_ sender: UIButton) {
        shareType = ShareType(rawValue: sender.tag)
        requestShareContentData()
    }
    
    fileprivate func configInfoShare() {
        guard let type = shareType,
            let object = shareContent else { return }
        var message: MonkeyKing.Message? = nil
        var image: UIImage?
        guard let url = object.url, let thumbURL = object.thumb, let title = object.title, let detail = object.detail else {
            if let block = self.completeHandle {
                block(false)
            }
            return
        }
        do {
            let data = try Data(contentsOf: thumbURL)
            image = UIImage(data: data)
        } catch {}
        let info = MonkeyKing.Info(title: title, description: detail, thumbnail: image, media: .url(url))
        switch type {
        case .qqFriends:
            message = MonkeyKing.Message.qq(.friends(info: info))
        case .wechatSession:
            message = MonkeyKing.Message.weChat(.session(info: info))
        case .wechatTimeline:
            message = MonkeyKing.Message.weChat(.timeline(info: info))
        }
        if let message = message {
            MonkeyKing.deliver(message, completionHandler: { [weak self] (result) in
                self?.requestShareCallBackData()
                if let block = self?.completeHandle {
                    block(result)
                }
            })
        }
    }
    
    @IBAction func dismiss() {
        if let presented = presentingViewController {
            presented.dim(.out)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 请求分享的内容
    func requestShareContentData() {
        let param = ShareCallbackParameter()
        param.channel = shareType?.channel
        param.page = sharePage
        param.id = shareID
        let req: Promise<ShareAppData> = handleRequest(Router.endpoint( SharePath.appShareContent, param: param))
        req.then { value -> Void in
            self.shareContent = value.data
            self.configInfoShare()
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }
    
    /// 分享回调
    func requestShareCallBackData() {
        let param = ShareCallbackParameter()
        param.channel = shareType?.channel
        param.page = sharePage
        param.id = shareID
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( SharePath.callback, param: param))
        req.then { value -> Void in
            debugPrint("分享成功")
            }.always {
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }

}

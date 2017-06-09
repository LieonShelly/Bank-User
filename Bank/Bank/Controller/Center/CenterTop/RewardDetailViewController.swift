//
//  RewardDetailViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class RewardDetailViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var awardDetailLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var staffAvatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var awardID: String?
    
    fileprivate var award: Award?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        bgImageView.image = bgImageView.image?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 50, bottom: 30, right: 50), resizingMode: .tile)
        title = R.string.localizable.center_myaward_reward_title()
        contentView.frame = view.bounds
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        awardDetailLabel.adjustsFontSizeToFitWidth = true
        requeseDetailData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configInfo() {
        avatarImageView.setImage(with: award?.avatar)
        if let name = award?.staffName, let storeName = award?.storeName {
            awardDetailLabel.text = "您打赏了\(storeName)\(name)"
            staffNameLabel.text = name
        }
        if let point = award?.point {
            pointLabel.text = point
        }
        if let date = award?.updated?.toString("yyyy-MM-dd HH:mm") {
            dateLabel.text = date
        }
        staffAvatarImageView.setImage(with: award?.staffAvatar)
        if let message = award?.message {
            messageLabel.text = message
            let attribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
            let size = NSString(string: message).boundingRect(with: CGSize(width: screenWidth-70-13-40, height: 1000), options: .usesLineFragmentOrigin, attributes: attribute, context: nil).size
            viewHeight.constant = 120 + size.height
        }
    }
    
    /// 请求打赏详情
    fileprivate func requeseDetailData() {
        let param = AwardParameter()
        param.awardID = awardID
        MBProgressHUD.loading(view: view)
        let req: Promise<AwardData> = handleRequest(Router.endpoint( AwardPath.detail, param: param))
        req.then { (value) -> Void in
            if let data = value.data {
                self.award = data
                self.configInfo()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 分享
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        guard let vc = R.storyboard.main.shareViewController() else {return}
        vc.sharePage = .reward
        vc.shareID = awardID
        vc.completeHandle = { [weak self] result in
            
            self?.dim(.out)
            self?.dismiss(animated: true, completion: nil)
        }
        self.dim(.in)
        self.present(vc, animated: true, completion: nil)
    }
}

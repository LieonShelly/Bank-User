//
//  BankHomeViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/17/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class BankHomeViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var headlineView: VerticalCycleView!
    @IBOutlet fileprivate weak var contactButlerButton: VerticalButton!
    @IBOutlet fileprivate weak var myCreditButton: VerticalButton!
    @IBOutlet fileprivate weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var headlineViewBottom: NSLayoutConstraint!
    
    fileprivate let headlineViewHeightConst: CGFloat = -50.0
    
    fileprivate var rightItem: UIBarButtonItem?
    
    fileprivate var headlines: [News] = []
    fileprivate var timerCount: Int = 0
    var isSigned: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headlineViewBottom.constant = headlineViewHeightConst
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        requestAnnounce()
         self.isSigned = AppConfig.sharedManager.userInfo?.isSigned ?? false
        if self.isSigned == false {
            hiddenContactButlerButton()
            hiddenCreditButton()
            stackViewHeight.constant = 125
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestUnreadCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindBankHome(_ segue: UIStoryboardSegue) {
        
    }

    fileprivate func setupAnnounce() {
        var newsList: [News] = []
        if headlines.isEmpty {
            return
        }
        headlineViewBottom.constant = 0
        headlineView.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.headlineView.layoutIfNeeded()
        })
        
        if headlines.count < 3 {
            for i in 0..<headlines.count {
                newsList.append(headlines[i])
            }
            for _ in headlines.count..<3 {
                newsList.append(headlines[0])
            }
        } else {
            newsList = headlines
        }
        let titles = newsList.map { return $0.title }
        headlineView.setCycleScrollView(titles)
        headlineView.clickHandleBlock = { [weak self] index in
            if let vc = R.storyboard.news.newsDetailsViewController() {
                let news = newsList[index]
                vc.newsID = news.newsID
                vc.hidesBottomBarWhenPushed = true
                vc.title = R.string.localizable.controller_title_public_details()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    fileprivate func requestUnreadCount() {
        let req: Promise<BankHomeData> = handleRequest(Router.endpoint(endpoint: BankCardPath.index, param: nil))
        req.then { (value) -> Void in
            if let unread = value.data?.unRead, unread != 0 {
                self.rightItem = UIBarButtonItem(image: R.image.icon_announce_new(), style: .plain, target: self, action: #selector(self.goAnnounceList))
            } else {
                self.rightItem = UIBarButtonItem(image: R.image.btn_announce(), style: .plain, target: self, action: #selector(self.goAnnounceList))
            }
            self.navigationItem.rightBarButtonItem = self.rightItem
        }.catch { _ in
            
        }
    }
    
    fileprivate func requestAnnounce() {
        let param = NewsParameter()
        param.position = .bankHomeNews
        let req: Promise<TopNewsListData> = handleRequest(Router.endpoint(endpoint: NewsPath.topList, param: param))
        req.then { (value) -> Void in
            if let items = value.data?.topNews, !items.isEmpty {
                self.headlines = items
                self.setupAnnounce()
            }
            }.catch { _ in
                
        }
    }
    
    @IBAction func contactButler() {
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint(endpoint: UserPath.profile, param: nil))
        req.then { (value) -> Void in
            guard let butlerID = value.data?.butlerID else {return}
            if !butlerID.isEmpty {
                guard let vc = R.storyboard.bank.myBulterTableViewController() else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let vc = R.storyboard.bank.bindBulterViewController() else { return  }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }.catch { error in
            if let err = error as? AppError {
                MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)   
            }
        }
        
    }
    
    @objc fileprivate func goAnnounceList() {
        performSegue(withIdentifier: R.segue.bankHomeViewController.showAnnounceListVC, sender: nil)
    }
    
    fileprivate func hiddenContactButlerButton() {
        contactButlerButton.isEnabled = false
        contactButlerButton.setTitle(nil, for: UIControlState())
        contactButlerButton.setImage(nil, for: UIControlState())
    }
    
    fileprivate func hiddenCreditButton() {
        myCreditButton.isEnabled = false
        myCreditButton.setTitle(nil, for: UIControlState())
        myCreditButton.setImage(nil, for: UIControlState())
    }
}

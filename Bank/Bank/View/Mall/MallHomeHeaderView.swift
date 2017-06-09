//
//  MallHomeHeaderView.swift
//  Bank
//
//  Created by yang on 16/3/31.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable private_outlet

import UIKit
import URLNavigator

typealias MenuHandleBlock = (_ segueID: String, _ cat: GoodsCats?) -> Void
typealias NewsHandleBlock = (_ segueID: String) -> Void
typealias SignHandleBlock = (_ sender: UIButton) -> Void

class MallHomeHeaderView: UIView {
    
    @IBOutlet fileprivate weak var bannerView: UIView!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet fileprivate weak var newsCycleView: VerticalCycleView!
    @IBOutlet fileprivate weak var catsStackView: UIStackView!
    @IBOutlet fileprivate weak var lotteryButton: UIButton!
    @IBOutlet fileprivate weak var hotSaleButton: UIButton!
    var menuHandleBlock: MenuHandleBlock?
    var newsHandleBlock: NewsHandleBlock?
    var newsDetailHandleBlock: ((_ newsID: String) -> Void)?
    lazy var pageController: CyclePageViewController = {
        return CyclePageViewController(frame: CGRect(x: 0, y: 0, width: self.bannerView.frame.width, height: 150))
    }()
    var signHandleBlock: SignHandleBlock?
    var lotteryHandleBlock: ((_ segueID: String) -> Void)?
    var hotGoodsHandleBlock: ((_ segueID: String) -> Void)?
    fileprivate var goodsCatsArray: [Banner] = []
    
    override func awakeFromNib() {
        lotteryButton.imageView?.contentMode = .scaleAspectFill
        hotSaleButton.imageView?.contentMode = .scaleAspectFill
        checkInButton.setTitle(R.string.localizable.string_title_sign(), for: UIControlState())
        checkInButton.setTitle(R.string.localizable.string_title_registered(), for: .selected)
        checkInButton.setBackgroundImage(R.image.mall_btn_sign_in(), for: .normal)
    }
    
    func setNews(_ newsArray: [News]) {
        var newsList: [News] = []
        if newsArray.isEmpty == true {
            return
        }
        if newsArray.count < 3 {
            newsList.append(contentsOf: newsArray)
            for _ in 0..<3 {
                newsList.append(newsArray[0])
            }
        } else {
            newsList = newsArray
        }
        let titles = newsList.map { return $0.title }
        newsCycleView.setCycleScrollView(titles)
        newsCycleView.clickHandleBlock = { index in
            if let block = self.newsDetailHandleBlock {
                block(newsList[index].newsID)
            }
        }
    }
    
    func setCats(_ goodsCats: [Banner]) {
        if goodsCats.isEmpty == true {
            return
        }
        self.goodsCatsArray = goodsCats
        let count = min(goodsCats.count, 4)
        
        for i in 0..<count {
            
            guard let button = catsStackView.arrangedSubviews[i] as? UIButton else {
                return
            }
            button.kf.setImage(with: goodsCats[i].imageURL, for: .normal, placeholder: R.image.image_default_small())
            button.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    func setBanner(_ banners: [Banner]) {
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for i in 0..<banners.count {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            let addView = UIImageView()
            addView.setImage(with: banners[i].imageURL, placeholderImage: R.image.image_default_large())
            addViews.append(addView)
        }
        pageController.configDataSource(viewControllers: viewControllers, addViews: addViews)
        if let pageControllerView = pageController.view {
            bannerView.addSubview(pageControllerView)
        }
        //轮播的点击事件
        pageController.tapHandler = { index in
            if index < banners.count {
                let banner = banners[index]
                if let URL = banner.url {
                    Navigator.openInnerURL(URL)
                }
            }

        }
    }
    //签到
    @IBAction func signAction(_ sender: UIButton) {
        sender.isEnabled = false
        if let block = signHandleBlock {
            block(sender)
        }
    }
    
    @IBAction func goodsCatsAction(_ sender: UIButton) {
        if sender.tag == 3 {
            if let block = menuHandleBlock {
                block(R.segue.mallHomeViewController.showAllClassificationVC.identifier, nil)
            }
        } else {
            if let url = self.goodsCatsArray[sender.tag].url {
                Navigator.openInnerURL(url)
            }
        }
    }

//    func tapAction(_ tap: UITapGestureRecognizer) {
//        let tapView = tap.view
//        if let blcok = menuHandleBlock {
//            if tapView?.tag == self.goodsCatsArray.count {
//                
//            } else {
//                if let tag = tapView?.tag {
//                    if let url = self.goodsCatsArray[tag].url {
//                        Navigator.openInnerURL(url)
//                    }
//                }
//            }
//        }
//    }
    
    //头条
    @IBAction func pushToNewsHomeAction(_ sender: UIButton) {
        if let block = newsHandleBlock {
            block(R.segue.mallHomeViewController.showNewsHomeVC.identifier)
        }
    }

    //抽奖
    @IBAction func pushToLottroyAction(_ sender: UIButton) {
        if let block = lotteryHandleBlock {
            block(R.segue.mallHomeViewController.showLotteryVC.identifier)
        }
    }
    
    //热卖
    @IBAction func pushToHotGoodsAction(_ sender: UIButton) {
        if let block = hotGoodsHandleBlock {
            block(R.segue.mallHomeViewController.showHotGoodsVC.identifier)
        }
    }
    
}

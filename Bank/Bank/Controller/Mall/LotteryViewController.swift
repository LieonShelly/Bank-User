//
//  LotteryViewController.swift
//  Bank
//
//  Created by yang on 16/6/28.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

// swiftlint:disable force_unwrapping

import UIKit
import URLNavigator
import PromiseKit
import MBProgressHUD

class LotteryViewController: BaseViewController {

    @IBOutlet fileprivate var lotteryView: UIView!
    @IBOutlet weak fileprivate var scrollView: UIScrollView!
    @IBOutlet weak fileprivate var winInfoView: UIView!
    @IBOutlet weak fileprivate var prizeView: UIView!
    @IBOutlet weak fileprivate var stackView: UIStackView!
    
    lazy fileprivate var winInfoPageViewController: CyclePageViewController = {
        return CyclePageViewController(frame: self.winInfoView.bounds)
    }()
    lazy fileprivate var prizeGoodsPageViewController: CyclePageViewController = {
        return CyclePageViewController(frame: self.prizeView.bounds)
    }()
    fileprivate var winInfoList: [WinInfo] = []
    fileprivate var poolList: [Prize] = []
    fileprivate var thePoolList: [[Prize]] = []
    fileprivate var selectedPrizeID: String?
    fileprivate var getPrize: Prize?
    fileprivate var selectedImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        requestLotteryHomeData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PrizeDetailViewController {
            vc.giftID = self.selectedPrizeID
        }
    }
    
    fileprivate func setScrollView() {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: lotteryView.frame.height)
        lotteryView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: lotteryView.frame.height)
        scrollView.addSubview(lotteryView)
        title = R.string.localizable.controller_title_lottery()
        let shareBarButtonItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_share(), style: .plain, target: self, action: #selector(shareAction(_:)))
        navigationItem.rightBarButtonItem = shareBarButtonItem
    }
    
    //设置活动未开始的信息
    fileprivate func setNoneEventView() {
        let noneEventView = UIImageView(image: R.image.icon_noneEvent())
        view.addSubview(noneEventView)
        title = R.string.localizable.controller_title_not_star()
        
        noneEventView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(100)
            make.centerX.equalTo(view.snp.centerX)
        }
        
    }
    
    //设置奖品信息
    fileprivate func setPrizeView() {
        setList()
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for prizes in thePoolList {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            guard let addView = R.nib.prizePoolView.firstView(owner: nil) else {
                return
            }
            addView.prizeDetailHandleBlock = { (prizeID, segueID) in
                self.selectedPrizeID = prizeID
                self.performSegue(withIdentifier: segueID, sender: nil)
            }
            addView.configInfo(prizes)
            addViews.append(addView)
        }
        prizeGoodsPageViewController.postion = .vertical
        prizeGoodsPageViewController.timeInterval = 4
        prizeGoodsPageViewController.view.backgroundColor = UIColor.clear
        prizeGoodsPageViewController.hiddenPageControl = true
        prizeGoodsPageViewController.configDataSource(viewControllers: viewControllers, addViews: addViews)
        prizeView.addSubview(prizeGoodsPageViewController.view)
        prizeGoodsPageViewController.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
        self.addChildViewController(prizeGoodsPageViewController)
        
    }
    
    //设置获奖信息
    fileprivate func setWinInfoView() {
        var viewControllers: [UIViewController] = []
        var addViews: [UIView] = []
        for winInfo in winInfoList {
            let viewController = UIViewController()
            viewControllers.append(viewController)
            guard let addView = R.nib.winInfoView.firstView(owner: nil) else {
                return
            }
            addView.configInfo(winInfo)
            addViews.append(addView)
        }
        winInfoPageViewController.postion = .vertical
        winInfoPageViewController.timeInterval = 3
        winInfoPageViewController.view.isUserInteractionEnabled = false
        winInfoPageViewController.hiddenPageControl = true
        winInfoPageViewController.configDataSource(viewControllers: viewControllers, addViews: addViews)
        winInfoView.addSubview(winInfoPageViewController.view)
        winInfoPageViewController.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
        self.addChildViewController(winInfoPageViewController)
    }
    
    fileprivate func setList() {
        let group = poolList.count%3 == 0 ? poolList.count/3 : poolList.count/3 + 1
        for i in 0..<group {
            var prizeList: [Prize] = []
            var j = i * 3
            while j < 3*(i+1) && j < poolList.count {
                prizeList.append(poolList[j])
                j += 1
            }
            thePoolList.append(prizeList)
        }
//        for (index, prize) in poolList.enumerate() {
//            prizeList.append(prize)
//            if index % 3 == 2 {
//                thePoolList.append(prizeList)
//                prizeList.removeAll()
//            }
//            
//        }
    }
    
    //砸金蛋的提示框
    fileprivate func showAlertView(_ isShareGetTime: Bool = false, isStart: Bool = true) {
        guard let alertView = R.nib.lotteryResultView.firstView(owner: nil) else {
            return
        }
        alertView.configUI(isStart, isShareGetTime: isShareGetTime)
//        alertView.configUsedOut()
        if let prize = self.getPrize {
            alertView.configInfo(prize)
        }
        alertView.cancelHandleBlock = {
            alertView.removeFromSuperview()
        }
        alertView.shareHandleBlock = { [weak self] in
            alertView.removeFromSuperview()
            self?.shareAction(nil)
        }
        alertView.backHandleBlock = { [weak self] in
            _ = self?.navigationController?.popViewController(animated: true)
        }
        alertView.frame = UIScreen.main.bounds
        view.addSubview(alertView)
    }
    
    //弹框
    fileprivate func showAlertWithoutAction(_ title: String = "", message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_okay(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //砸金蛋
    @IBAction func eggTapAction(_ sender: UITapGestureRecognizer) {
        view.isUserInteractionEnabled = false
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        selectedImageView = imageView
        requestLotteryData()
    }
    
    /// 开始动画
    fileprivate func startAnimation() {
        selectedImageView?.animationImages = [R.image.animation_01()!, R.image.animation_02()!, R.image.animation_03()!, R.image.animation_04()!]
        selectedImageView?.animationRepeatCount = 1
        selectedImageView?.animationDuration = 0.5 * 4
        selectedImageView?.startAnimating()
        self.perform(#selector(animationDone), with: nil, afterDelay: 2)
    }
    
    /// 动画结束
    @objc func animationDone() {
        view.isUserInteractionEnabled = true
        selectedImageView?.image = R.image.animation_04()
        self.showAlertView()
    }

    //分享
    func shareAction(_ sender: UIBarButtonItem?) {
        guard let vc = R.storyboard.main.shareViewController() else {return}
        vc.sharePage = .lottery
        vc.completeHandle = { [weak self] result in
            self?.dim(.out)
            vc.dismiss(animated: true, completion: nil)
            if result {
                self?.requestShareData()
            }
        }
        dim(.in)
        present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: Request
extension LotteryViewController {
    /**
     请求首页数据
     */
    func requestLotteryHomeData() {
        MBProgressHUD.loading(view: self.view)
        let req: Promise<LotteryHomeData> = handleRequest(Router.endpoint(GiftPath.index, param: nil))
        req.then { value -> Void in
            if value.isValid {
                self.setScrollView()
                if let winList = value.data?.winList {
                    self.winInfoList = winList
                    self.setWinInfoView()
                }
                if let pools = value.data?.poolList {
                    self.poolList = pools
                    self.setPrizeView()
                }
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    // 没有正在进行的活动
                    if err.errorCode.errorCode() == RequestErrorCode.noneLottery.errorCode() {
                        self.setNoneEventView()
//                        self.getPrize = nil
//                        self.showAlertView(isStart: false)
                        
                    } else {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
                }
        }
    }
    
    /**
     砸金蛋
     */
    func requestLotteryData() {
        MBProgressHUD.loading(view: self.view)
        let req: Promise<PrizeDetailData> = handleRequest(Router.endpoint(GiftPath.lottery, param: nil))
        req.then { value -> Void in
            if value.isValid {
                self.getPrize = value.data
                self.startAnimation()
            }
            }.always {
                self.view.isUserInteractionEnabled = true
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    if err.errorCode.errorCode() == RequestErrorCode.countsRunOut.errorCode() {
                        // 抽奖次数已用完
                        self.getPrize = nil
                        self.showAlertView(false)
                    } else if err.errorCode.errorCode() == RequestErrorCode.runOutShare.errorCode() {
                        //抽奖次数已用完，但是分享可以再抽一次
                        self.getPrize = nil
                        self.showAlertView(true)
                    } else {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
                    
                }
        }
    }

    /**
     分享
     */
    fileprivate func requestShareData() {
        MBProgressHUD.loading(view: self.view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint(GiftPath.share, param: nil))
        req.then { value -> Void in
                self.showAlertWithoutAction(message: R.string.localizable.alertTitle_share_success())
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }

}

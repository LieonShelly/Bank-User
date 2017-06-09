//
//  CyclePageViewController.swift
//  PageControllerDemo
//
//  Created by yang on 16/3/24.
//  Copyright © 2016年 yang. All rights reserved.
//

import UIKit

class CyclePageViewController: UIViewController {
    
    fileprivate let imgViewOriginTag = 100
    fileprivate var nextIndex: Int = 0
    fileprivate var controllers: [UIViewController] = []
    fileprivate var timer: Timer?
    fileprivate var addViews: [UIView] = []
    /// 是否隐藏小圆点
    var hiddenPageControl: Bool = false
    /// 轮播方向，默认为水平方向
    var postion: UIPageViewControllerNavigationOrientation = .horizontal
    /// 是否自动滚动
    var isAutoScroller: Bool = true
    /// 是否能够无限滚动
    var canCarousel: Bool = true
    /// 轮播的点击事件
    var tapHandler: ((_ index: Int) -> Void)?
    /// 轮播时间
    var timeInterval: TimeInterval = 2.0
    /// 图片列表
    var imageURL: [URL]!
    /// 非当前的圆点的颜色
    var pageColor: UIColor = UIColor(hex: 0xe5e5e5)
    /// 当前圆点颜色
    var currentColor: UIColor = UIColor(hex: 0xb3b3b3)
    /// 当前图片的下标
    var currentIndex: Int = 0 {
        didSet {
            guard self.currentIndex < 0 && self.currentIndex >= self.controllers.count else {
                return
            }
            currentIndex = 0
        }
    }
    fileprivate var pageViewController: UIPageViewController?
    fileprivate lazy var pageControl: UIPageControl = UIPageControl()
    fileprivate lazy var imageView: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
    }
    
    func configDataSource(viewControllers: [UIViewController], addViews: [UIView], isAutoScroller: Bool = true) {
        self.controllers = viewControllers
        self.addViews = addViews
        self.isAutoScroller = isAutoScroller
        if viewControllers.isEmpty {
            imageView.image = R.image.image_default_large()
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
        } else {
            imageView.removeFromSuperview()
        }
        if controllers.isEmpty == false {
            if isAutoScroller == true {
                startTimer()
            }
            configurePageViewController()
            configurePageControl()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        pageControl.removeFromSuperview()
        pageViewController?.removeFromParentViewController()
        pageViewController?.view.removeFromSuperview()
        if controllers.isEmpty == false {
            controllers.removeAll()
        }
        stopTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     图片的点击事件
     */
    @objc fileprivate func tapAction() {
        if let tapHandler = tapHandler {
            tapHandler(pageControl.currentPage)
        }
    }
    
    /**
     自动轮播的时候图片
     */
    @objc fileprivate func scrollImage() {
        pageViewController?.setViewControllers([controllers[currentIndex]], direction: .forward, animated: true, completion: nil)
        pageControl.currentPage = currentIndex
        currentIndex = (currentIndex + 1) % controllers.count
    }
    
    /**
     定时器重启
     */
    fileprivate func resumeTimer() {
        if let timer = self.timer {
            timer.fireDate = Date.distantPast
        }
    }
    
    /**
     定时器暂停
     */
    fileprivate func pauseTimer() {
        if let timer = self.timer {
            timer.fireDate = Date.distantFuture
        }
    }
    
    /**
     定时器停止
     */
    fileprivate func stopTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    /**
     定时器开始
     */
    fileprivate func startTimer() {
        if let timer = self.timer {
            timer.fireDate = Date.distantPast
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(CyclePageViewController.scrollImage), userInfo: nil, repeats: true)
            self.timer?.fireDate = Date.distantPast
        }
        if let timer = self.timer {
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        }
        
    }
    
    /**
     返回控制器的下标
     */
    fileprivate func indexOfViewController(_ controller: UIViewController) -> Int {
        guard let index = controllers.index(of: controller) else {
            return NSNotFound
        }
        return index
        
    }
    
    /**
     返回当前控制器
     */
    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        return controllers[index]
    }
    
    /**
     设置UIPageControl
     */
    fileprivate func configurePageControl() {
        pageControl.bounds = CGRect(x: 0, y: 0, width: 200, height: 15)
        pageControl.center = CGPoint(x: self.view.center.x, y: view.frame.size.height - 15)
        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = currentIndex
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = pageColor
        pageControl.currentPageIndicatorTintColor = currentColor
        pageControl.backgroundColor = UIColor.clear
        if controllers.count <= 1 {
            hiddenPageControl = true
        }
        pageControl.isHidden = hiddenPageControl
        self.view.addSubview(pageControl)
    }
    
    /**
     设置UIPageViewController
     */
    fileprivate func configurePageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: postion, options: nil)
        pageViewController?.view.frame = self.view.bounds
        for (index, viewController) in zip(controllers.indices, controllers) {
            viewController.view.frame = view.bounds
            viewController.view.clipsToBounds = true
            let theview = addViews[index]
            theview.clipsToBounds = true
            viewController.view.addSubview(theview)
            theview.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(0)
                make.right.equalToSuperview().offset(0)
                make.top.equalToSuperview().offset(0)
                make.bottom.equalToSuperview().offset(0)
            })
            if theview is UIImageView {
                guard let imageView = theview as? UIImageView else {
                    return
                }
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CyclePageViewController.tapAction))
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFill
                imageView.tag = imgViewOriginTag + index
                imageView.addGestureRecognizer(tapGesture)
            }
        }
        if controllers.count > 1 {
            pageViewController?.delegate = self
            pageViewController?.dataSource = self
        }
        pageViewController?.setViewControllers([controllers[currentIndex]], direction: .forward, animated: true, completion: nil)
        pageViewController?.didMove(toParentViewController: self)
        if let vc = pageViewController, let view = vc.view {
            addChildViewController(vc)
            view.clipsToBounds = true
            self.view.addSubview(view)
        }
        view.gestureRecognizers = pageViewController?.gestureRecognizers
    }
}

extension CyclePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController)
        if index == NSNotFound {
            return nil
        }
        if canCarousel {
            index = (index + 1) % controllers.count
        } else {
            index += 1
        }
        if index == controllers.count {
            return nil
        }
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = indexOfViewController(viewController)
        if index == NSNotFound {
            return nil
        }
        if canCarousel {
            index = (index - 1 + controllers.count) % controllers.count
        } else {
            if index == 0 {
                return nil
            }
            index -= 1
            
        }
        return viewControllerAtIndex(index)
    }
    
}

extension CyclePageViewController: UIPageViewControllerDelegate {
    // 即将完成翻页
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let controller = pendingViewControllers.first {
            nextIndex = indexOfViewController(controller)
        }
        self.pauseTimer()
    }
    
    // 已经完成翻页
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let _ = previousViewControllers.first {
//                for subview in controller.view.subviews {
//                    guard let view = subview as? UIScrollView else {
//                        break
//                    }
////                    view.zoomScale = 1.0
//                }
            }
            currentIndex = nextIndex
        }
        nextIndex = 0 // 复位
        pageControl.currentPage = currentIndex
        self.resumeTimer()
    }
}

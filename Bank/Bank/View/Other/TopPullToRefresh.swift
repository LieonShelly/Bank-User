//
//  TopPullToRefresh.swift
//  Bank
//
//  Created by 杨锐 on 2017/2/27.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PullToRefresh

class TopPullToRefresh: PullToRefresh {
    convenience init(height: CGFloat = 40, position: Position = .top) {
        let refreshView = TopRefreshView()
        refreshView.backgroundColor = UIColor.clear
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        refreshView.autoresizingMask = [.flexibleWidth]
        refreshView.frame.size.height = height
        let animator = MyAnimator(refreshView: refreshView)
        self.init(refreshView: refreshView, animator: animator, height: height, position: position)
    }
}

class MyAnimator: RefreshViewAnimator {
    private let refreshView: TopRefreshView
    
    init(refreshView: TopRefreshView) {
        self.refreshView = refreshView
    }
    
    func animate(_ state: State) {
        switch state {
        case .initial:
            refreshView.titleLabel.text = "下拉可以刷新"
            refreshView.imageView.image = R.image.icon_drop_down()
        case .releasing(let progress):
            if progress == 1 {
                refreshView.titleLabel.text = "松开立即刷新"
                refreshView.imageView.image = R.image.icon_pull()
            } else {
                refreshView.titleLabel.text = "下拉可以刷新"
                refreshView.imageView.image = R.image.icon_drop_down()
            }
        case .loading:
            refreshView.titleLabel.text = "加载中..."
            refreshView.imageView.image = R.image.icon_in_loading()
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Double.pi * 2.0
            rotationAnimation.duration = 1
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = 1000
            refreshView.imageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        case .finished:
            refreshView.imageView.layer.removeAnimation(forKey: "rotationAnimation")
            refreshView.titleLabel.text = "加载成功"
            refreshView.imageView.image = R.image.icon_load_success()
        }
    }
}

class TopRefreshView: UIView {
    
    lazy var imageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.addSubview(imageView)
        return imageView
    }()
    lazy var titleLabel: UILabel! = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.bounds = CGRect(x: 0, y: 0, width: 100, height: 30)
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(hex: 0xa1a1a1)
        self.addSubview(titleLabel)
        return titleLabel
    }()
    
    override func layoutSubviews() {
        setupFrame(in: superview)
        super.layoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setupFrame(in: superview)
    }
    
}

private extension TopRefreshView {
    func setupFrame(in newSuperView: UIView?) {
        guard let superview = newSuperView else { return }
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.frame.width, height: frame.height)
        titleLabel.center = CGPoint(x: self.center.x + 40, y: self.bounds.height/2)
        imageView.center = CGPoint(x: self.center.x - 40, y: self.bounds.height/2)
    }
    
}

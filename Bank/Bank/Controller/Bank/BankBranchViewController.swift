//
//  BankBranchViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator

class BankBranchViewController: BaseViewController {
    
    fileprivate enum ViewMode {
        case map
        case list
    }
    
    @IBOutlet fileprivate weak var contentView: UIView!
    fileprivate var rightItem: UIBarButtonItem!
    fileprivate var listVC: BranchListViewController?
    fileprivate var mapVC: BranchMapViewController?
    
    fileprivate var viewMode: ViewMode = .list
    fileprivate var datas: [Branch] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = R.storyboard.bank.branchListViewController() {
            listVC = vc
            addChildViewController(vc)
            view.addSubview(vc.view)
            listVC?.didMove(toParentViewController: self)
        }
        if let vc = R.storyboard.bank.branchMapViewController() {
            mapVC = vc
            addChildViewController(vc)
        }
        setupViewMode(.list, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc fileprivate func toggleViewMode() {
        if viewMode == .list {
            setupViewMode(.map)
        } else {
            setupViewMode(.list)
        }
    }
    
    fileprivate func setupViewMode(_ mode: ViewMode, animated: Bool = true) {
        var duration = 0.5
        if !animated {
            duration = 0.0
        }
        guard let listVC = listVC else { return }
        guard let mapVC = mapVC else { return }
        if mode == .list {
            rightItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_map(), style: .plain,
                                        target: self, action: #selector(self.toggleViewMode))
            transition(from: mapVC,
                                         to: listVC,
                                         duration: duration,
                                         options: .transitionFlipFromLeft,
                                         animations: nil,
                                         completion: { (finished) in
                                            if finished {
                                                self.viewMode = .list
                                                listVC.didMove(toParentViewController: self)
                                            }
            })
        } else {
            rightItem = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_list(), style: .plain,
                                        target: self, action: #selector(self.toggleViewMode))
            
            transition(from: listVC,
                                         to: mapVC,
                                         duration: duration,
                                         options: .transitionFlipFromLeft,
                                         animations: nil,
                                         completion: { (finished) in
                                            if finished {
                                                self.viewMode = .map
                                                mapVC.didMove(toParentViewController: self)
                                            }
            })
        }
        navigationItem.rightBarButtonItem = rightItem
    }
    
}

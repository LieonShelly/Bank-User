//
//  RefundReasonTableViewController.swift
//  Bank
//
//  Created by kilrae on 2017/4/21.
//  Copyright © 2017年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class RefundReasonTableViewController: BaseTableViewController {
    
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var supplyLabel: UILabel!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    var refundDetail: RefundDetail?

    override func viewDidLoad() {
        super.viewDidLoad()
        stackViewHeight.constant = (view.frame.width - 34 - 30) / 4
        tableView.configBackgroundView()
        configInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configInfo() {
        reasonLabel.text = refundDetail?.reason
        supplyLabel.text = refundDetail?.remark
        if refundDetail?.images?.isEmpty == false {
            guard let urls = refundDetail?.images else { return }
            for i in 0..<min(urls.count, 4) {
                let url = urls[i]
                guard let imageView = stackView.arrangedSubviews[i] as? UIImageView else {
                    return
                }
                imageView.layer.borderColor = UIColor(hex: 0xe5e5e5).cgColor
                imageView.setImage(with: url, placeholderImage: R.image.image_default_small())
            }
            tableView.tableFooterView = footerView
        } else {
            tableView.tableFooterView = UIView()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if refundDetail?.remark != nil && refundDetail?.remark != "" {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 17
    }

}

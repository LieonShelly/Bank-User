//
//  CenterViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/17/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable empty_count

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import Kingfisher
import MBProgressHUD

class CenterHomeViewController: BaseTableViewController {
    
    @IBOutlet weak fileprivate var headImageView: UIImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var phoneLabel: UILabel!
    @IBOutlet fileprivate weak var leftItem: UIBarButtonItem!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var phoneLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var allButton: OrderButton!
    @IBOutlet weak var paymentButton: OrderButton!
    @IBOutlet weak var takeButton: OrderButton!
    @IBOutlet weak var sendButton: OrderButton!
    @IBOutlet weak var returnButton: OrderButton!
    var isSigned: Bool = false
    var user: User?
    var statusModels = [StatusNum]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isSigned = AppConfig.shared.isUserSigned
        tabBarController?.tabBar.isHidden = false
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        requestUserData()
        requestOrderNumber()
    }
    /// 用户数据加载
    func setAccountInfo(_ user: User?) {
        if let url = user?.imageURL {
            headImageView.setImage(with: url,
                                   placeholderImage: R.image.head_default())
        } else {
            headImageView.image = R.image.head_default()
        }
        
        DispatchQueue.main.async {
            if let phoneString = user?.mobile {
                self.phoneLabel.text = phoneString.replaceWith(range: NSRange(location: 3, length: 4))
            }
            self.nameLabel.text = user?.nickname
            if user?.staffID == "0" {
                self.typeButton.isHidden = true
                self.phoneLabelTopConstraint.constant = 25
                self.typeButton.setTitle("", for: .normal)
                
            } else {
                self.typeButton.isHidden = false
                self.phoneLabelTopConstraint.constant = 3
                self.typeButton.setTitle("我是店员 >", for: .normal)
                self.typeButton.cornerRadius = 10
                self.typeButton.borderColor = UIColor.white
                self.typeButton.borderWidth = 1
            }
            
            self.tableView?.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 请求用户基本数据
    func requestUserData() {
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint( UserPath.profile, param: nil))
        req.then(on: DispatchQueue.global()) { (value) -> Void in
            self.user = value.data
            if let count = value.data?.informationCount, count > 0 {
                self.leftItem.image = R.image.btn_news_on()
            } else {
                self.leftItem.image = R.image.btn_news()
            }
            self.setAccountInfo(value.data)
            }.catch { error in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }

    func requestOrderNumber() {
            let req: Promise<OrderNumData> = handleRequest(Router.endpoint( OrderPath.order(.orderNum), param: nil))
        
            req.then { (value) -> Void in
                guard let model = value.data else {return}
                    self.statusModels = model.statusNum
                    self.paymentButton.tapButton.setTitle(self.returnOrderNum(type: OrderStatus.waitingPay))
                    self.sendButton.tapButton.setTitle(self.returnOrderNum(type: OrderStatus.waitingShip))
                    self.takeButton.tapButton.setTitle(self.returnOrderNum(type: OrderStatus.shipped))
                    self.returnButton.tapButton.setTitle("\(model.refundNum)")
                
                self.tableView.reloadData()
                }.always {
                }.catch { _ in }
        
    }
    
    func returnOrderNum(type: OrderStatus) -> String {
        for model in self.statusModels where model.status == type {
            return "\(model.num)"
        }
        return "0"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let personDataVC = segue.destination as? ProfileViewController {
            personDataVC.user = self.user
        }
        
        if let vc = segue.destination as? ContributePointViewController {
            vc.tag = user?.fatherID == "0" ? 0 : 1
        }
     }
}

extension CenterHomeViewController {
    @IBAction func orderDeatailAction(_ sender: UIButton) {
        guard let vc = R.storyboard.myOrder.myOrderViewController() else {return}
        switch sender.tag {
        case 1000:
            vc.index = 0
        case 1001:
            vc.index = 1
        case 1002:
            vc.index = 2
        case 1003:
            vc.index = 3
        case 1004:
            vc.index = 4
        default:
            break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: Table View Delegate
extension CenterHomeViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (section, row) = (indexPath.section, indexPath.row)
        switch (section, row) {
        case (1, 0):
            return 71.0
        case (0, 0):
            return 100.0
        case (2, 0):
            return isSigned == true ? 50.0 : CGFloat.leastNonzeroMagnitude
        case (2, 1):
            return isSigned == true ? CGFloat.leastNonzeroMagnitude : 50.0
        case (2, 3):
            return isSigned == true ? 9.0 : CGFloat.leastNonzeroMagnitude
        case (2, 4):
            return isSigned == true ? 50.0 : CGFloat.leastNonzeroMagnitude
        default:
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 9.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (section, row) = (indexPath.section, indexPath.row)
        switch (section, row) {
        case (2, 4):
            guard let vc = R.storyboard.credit.myCreditViewController() else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        case (2, 5):
            guard let vc = R.storyboard.bank.cardsListViewController() else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
}

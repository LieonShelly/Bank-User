//
//  MyCreditViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//
//  swiftlint:disable private_outlet

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

private let kTableHeaderHeight: CGFloat = 150.0
class MyCreditViewController: BaseTableViewController {
    
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet fileprivate weak var availableLabel: UILabel!
    @IBOutlet fileprivate weak var creditLabel: UILabel!
    fileprivate var myCredit: MyCredit?
    fileprivate var creditGood: CreditGoods?
    fileprivate var creditGoodList: [CreditGoods]?
    
    fileprivate lazy var hud: MBProgressHUD = {
        let hud = MBProgressHUD()
        hud.center = CGPoint(x: UIScreen.main.bounds.width*0.5, y: UIScreen.main.bounds.height*0.5-2*kTableHeaderHeight)
        hud.backgroundColor = UIColor.white
        self.tableView.addSubview(hud)
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        clearsSelectionOnViewWillAppear = true
        updateHeaderView()
        helpHtmlName = "EMyCreditAccount"
    }

    @IBAction func helpHandle(_ sender: AnyObject) {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else {return}
        vc.tag = HelpCenterTag.credit
        Navigator.push(vc)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestMyCreditData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI() {
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        tableView.register(R.nib.creditTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.configBackgroundView()
    }
    
    // MARK: Method
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.myCreditViewController.showDebtDetailVC.identifier {
            if let vc = segue.destination as? DebtDetailViewController {
                vc.goodID = myCredit?.creditGoodsList?.first?.goodsID
                vc.creditGood = self.creditGoodList?.first
            }
        }
    }
}

// MARK: - RequestData  financing/my_credit
extension MyCreditViewController {
    /**
     我的信用
     */
    func requestMyCreditData() {
        self.hud.show(animated: true)
            let req: Promise<MyCreditData> = handleRequest(Router.endpoint( EAccountPath.credit, param: nil))
            req.then { (value) -> Void in
                if value.isValid {
                    self.setupMyCreditData(value)
                    
                    if let creditGoodList = value.data?.creditGoodsList {
                        self.creditGoodList = creditGoodList
                    }
                    self.tableView.reloadData()
                }
                }.always {
                    self.hud.hide(animated: true)
                }.catch { (error) in
                    if let err = error as? AppError {
                        MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                    }
                }
            }
    
    func setupMyCreditData(_ value: MyCreditData) {
        
        guard let data = value.data else {return}
        self.availableLabel.amountWithUnit(data.availableCredit, color: UIColor.white, amountFontSize: 25, unitFontSize: 13, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
        self.creditLabel.amountWithUnit(data.totalCredit, color: UIColor.white, amountFontSize: 13, unitFontSize: 13, strikethrough: false, fontWeight: UIFontWeightRegular, unit: "元", decimalPlace: 2, useBigUnit: false)
    }
}

// MARK: Scroll View Delegate
extension MyCreditViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
}

// MARK: Table View Data Source
extension MyCreditViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = self.creditGoodList?.count else {return 1}
        return count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.creditTableViewCell, for: indexPath) else {
           return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        if let goods = self.creditGoodList {
            cell.configInfo((goods[indexPath.row]))
        }
        
        cell.checkBlock = {
        self.performSegue(withIdentifier: R.segue.myCreditViewController.showDebtDetailVC, sender: nil)
        }
        cell.cashPayBlock = {
        self.performSegue(withIdentifier: R.segue.myCreditViewController.showCashPayVC, sender: nil)
        }
        cell.statePayBlock = {
            self.performSegue(withIdentifier: R.segue.myCreditViewController.showIntegralVC, sender: nil)
        }
        
        return cell
    }

}

// MARK: Table View Delegate
extension MyCreditViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 215
    }
}

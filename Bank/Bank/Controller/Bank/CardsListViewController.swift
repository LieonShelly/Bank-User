//
//  BankCarViewController.swift
//  Bank
//
//  Created by Mac on 15/11/23.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import URLNavigator
import Device
import MBProgressHUD

protocol ChooseCardProtocol {
    func dismissFromAddNewCard()
}

class CardsListViewController: BaseViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var footerView: UIView!
    
    fileprivate lazy var blankBackView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .bank) }()
    
    fileprivate var datas: [BankCard] = [] {
        didSet {
            ownBankDatas = datas.filter({$0.bankID == .mccb})
        }
    }
    fileprivate var ownBankDatas: [BankCard] = []
    fileprivate var choosedCard: BankCard?
    fileprivate var password: String?
    fileprivate var button: UIButton!
    fileprivate var isSigned: Bool = false
    fileprivate var isLogout: Bool = false
    fileprivate var name: String = ""
    var lastViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        blankBackView.frame = CGRect(origin: CGPoint.zero, size: tableView.frame.size)
        blankBackView.buttonHandleBlock = { [weak self] in
            self?.addCardHandle()
        }
        let isSigned = AppConfig.shared.isUserSigned
        self.isSigned = isSigned
        button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        button.contentHorizontalAlignment = .right
        button.setImage(R.image.mall_brandZone_btn_more_menu(), for: UIControlState())
        button.addTarget(self, action: #selector(self.moreMenuAction(_:)), for: .touchUpInside)
        let item = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = item
        setBlankBackground(false)
        requestQueryCard()
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: fileprivate function
    
    /// 显示更多菜单
    @objc fileprivate func moreMenuAction(_ sender: UIButton) {
        var imageArray: [UIImage?] = []
        var dataSourceArray: [String] = []
        
        switch (datas.isEmpty, isSigned, isLogout) {
        case (_, _, true), (true, true, false):
            imageArray = [R.image.btn_help1()]
            dataSourceArray = [R.string.localizable.barButtonItem_title_help()]
        case (false, false, false):
            imageArray = [R.image.btn_help1(), R.image.btn_unbind(), R.image.icon_logout()]
            dataSourceArray = [R.string.localizable.barButtonItem_title_help(), R.string.localizable.barButtonItem_title_unbind(), R.string.localizable.barButtonItem_title_logout()]
        case (true, false, false):
            imageArray = [R.image.btn_help1(), R.image.icon_logout()]
            dataSourceArray = [R.string.localizable.barButtonItem_title_help(), R.string.localizable.barButtonItem_title_logout()]
        case (false, true, false):
            imageArray = [R.image.btn_help1(), R.image.btn_unbind()]
            dataSourceArray = [R.string.localizable.barButtonItem_title_help(), R.string.localizable.barButtonItem_title_unbind()]
        }
        let menuView = MenuView(frame: UIScreen.main.bounds)
        navigationController?.view.addSubview(menuView)
        menuView.imagesArray = imageArray
        menuView.dataSorceArray = dataSourceArray
        menuView.menuTableView.frame = CGRect(x: view.bounds.width - 133, y: 60, width: 123, height: CGFloat(imageArray.count) * 40)
        menuView.showTableView()
        menuView.actionBlock = { index in
            switch index {
            case 0:
                self.goHelpCenter()
            case 1:
                if !self.datas.isEmpty && !self.isLogout {
                    self.verifyPayPassword()
                } else {
                    self.gotoLogout()
                }
            case 2:
                self.gotoLogout()
            default:
                break
            }
        }

    }
    
    /// 验证支付密码
    fileprivate func verifyPayPassword() {
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.resultHandle = { [weak self] (result, pass) in
                
                switch result {
                case .passed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.requestUnbind(payPass: pass)
                case .failed:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                    self?.setFundPassAlertController()
                default:
                    self?.dim(.out, coverNavigationBar: true)
                    vc.dismiss(animated: true, completion: nil)
                }
            }
            self.dim(.in, coverNavigationBar: true)
            self.present(vc, animated: true, completion: nil)
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                guard let err = error as? AppError else {
                    return
                }
                if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    self.setFundPassAlertController(message: err.toError().localizedDescription)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    /// 前往帮助中心
    @objc fileprivate func goHelpCenter() {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else { return }
        vc.tag = HelpCenterTag.card
        Navigator.push(vc)
    }
    
    fileprivate func gotoLogout() {
        guard let vc = R.storyboard.bank.cardLogoutViewController() else {
            return
        }
        Navigator.push(vc)
    }
    
    fileprivate func setupTableView() {
        if Device.size() == .screen5_5Inch {
            tableView.rowHeight = 120
        } else {
            tableView.rowHeight = 110
        }
        tableView.register(R.nib.bankCardTableViewCell)
        tableView.configBackgroundView()
        tableView.tableFooterView = footerView
    }
    
    fileprivate func setBlankBackground(_ hidden: Bool) {
        if hidden {
            tableView.backgroundView = nil
            tableView.tableFooterView = nil
        } else {
            tableView.backgroundView = blankBackView
            tableView.tableFooterView = nil
        }
    }
    
    fileprivate func dismissVerifyVC(_ result: VerifyPayPassResult) {
        dim(.out, coverNavigationBar: true)
        dismiss(animated: true) { [weak self] in
            switch result {
            case .passed:
                self?.performSegue(withIdentifier: R.segue.cardsListViewController.showBindCardVC, sender: nil)
            case .failed:
                self?.setFundPassAlertController()
            default:
                break
            }
        }
    }
    
    @IBAction func addCardHandle() {
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.payPassStatus, param: nil))
        req.then { (value) -> Void in
            guard let vc = R.storyboard.main.verifyPayPassViewController() else { return }
            vc.resultHandle = { [weak self] (result, string) in
                self?.dismissVerifyVC(result)
                self?.password = string
            }
            self.dim(.in, coverNavigationBar: true)
            self.present(vc, animated: true, completion: nil)
            }.catch { (error) in
                guard let err = error as? AppError else {
                    return
                }
                if err.errorCode.errorCode() == RequestErrorCode.payPassLock.errorCode() {
                    self.setFundPassAlertController(message: err.toError().localizedDescription)
                } else {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.cardsListViewController.showBindCardVC.identifier {
            guard let vc = segue.destination as? BindCardViewController else {
                    return
            }
            vc.lastViewController = lastViewController
            vc.verifyPayPassword = self.password
            vc.name = self.name
            vc.isSigned = self.isSigned
        }
    }
    
    @IBAction func unwindFromBindCard(_ segue: UIStoryboardSegue) {
        requestData()
        requestQueryCard()
    }
    
    @IBAction func unwindFromLogout(_ segue: UIStoryboardSegue) {
        requestQueryCard()
        requestData()
    }

}

// MARK: - Request
extension CardsListViewController {
    
    /// 请求上次绑卡身份信息
    fileprivate func requestQueryCard() {
        let req: Promise<GetUserInfoData> = handleRequest(Router.endpoint( BankCardPath.queryCard, param: nil))
        req.then { (value) -> Void in
            if let isSigned = value.data?.isSigned {
                self.isSigned = isSigned
            }
            if let name = value.data?.name {
                self.name = name
                self.isLogout = name == "" ? true : false
            }
        }.catch { _ in
            self.requestQueryCard()
        }
    }
    
    /// 请求银行卡列表
    fileprivate func requestData() {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList {
                self.datas = items
                self.tableView.reloadData()
                self.setBlankBackground(!items.isEmpty)
            } else {
                self.setBlankBackground(false)
            }
            }.catch { _ in }
    }
    
    /// 解除绑定
    fileprivate func requestUnbind(payPass: String?) {
        let param = BankCardParameter()
        if !datas.isEmpty {
            param.cardID = datas.first?.cardID
        }
        param.payPass = payPass
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( BankCardPath.unbind, param: param))
        req.then { (_) -> Void in
            self.requestData()
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
}

// MARK: - UITableViewDataSource
extension CardsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ownBankDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.bankCardTableViewCell, for: indexPath) else { return UITableViewCell() }
        cell.configCard(ownBankDatas[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CardsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 17
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 17)
        view.backgroundColor = UIColor.clear
        return view
    }
}

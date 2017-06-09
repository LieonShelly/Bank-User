//
//  ChoosePaymentViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/7/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class ChoosePaymentViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var confirmButton: UIButton!
    
    var dismiss: (() -> Void)?
    var addNewCard: (() -> Void)?
    var confirm: ((BankCard?) -> Void)?
    
    /// 需要支付的金额
    var amount: Double = 0 {
        didSet {
            self.amountString = amount.numberToString()
        }
    }
    fileprivate var amountString: String = ""
    
    fileprivate var cards: [BankCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        tableView.register(R.nib.choosePaymentTableViewCell)
        tableView.register(R.nib.choosePaymentAddNewCardCell)
        tableView.rowHeight = 50.0
        confirmButton.setTitle(R.string.localizable.bank_payment_confirm_pay(amountString))
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func requestData() {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        
        MBProgressHUD.loading(view: view)
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList, !items.isEmpty {
                self.cards = items
                self.tableView.reloadData()

                DispatchQueue.main.async {
                    self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
                }
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let window = UIApplication.shared.keyWindow {
                    MBProgressHUD.errorMessage(view: window, message: error.localizedDescription)
                    self.dismissHandle()
                }
        }
    }
    
    @IBAction fileprivate func dismissHandle() {
        if let block = dismiss {
            block()
        }
    }
    
    fileprivate func addHandle() {
        dismissHandle()
        if let block = addNewCard {
            block()
        }
    }
    
    @IBAction fileprivate func confirmHandle() {
        if cards.isEmpty {
            showAlert(message: R.string.localizable.alertTitle_not_bind_card())
            return
        }
        if let indexPath = tableView.indexPathForSelectedRow {
            if indexPath.row < cards.count {
                dismissHandle()
                if let block = confirm {
                    block(cards[indexPath.row])
                }
            } else {
               Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_choose_bank())
            }
        }
    }
    
    fileprivate func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "去绑卡", style: .default, handler: { (action) in
            self.addHandle()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ChoosePaymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cards.count {
            self.addHandle()
        }
    }
}

extension ChoosePaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == cards.count {
            // add new card
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.choosePaymentAddNewCardCell, for: indexPath) else { return UITableViewCell() }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.choosePaymentTableViewCell, for: indexPath) else { return UITableViewCell() }
            if indexPath.row < cards.count {
                let card = cards[indexPath.row]
                cell.configCard(card)
            }
            return cell
        }
    }
}

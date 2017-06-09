//
//  ChooseCardViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/4.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator

class ChooseCardViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var descLabel: UILabel!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var backButton: UIButton!
    
    var pushMode: Bool = true
    var dismiss: ((BankCard?) -> Void)?
    var addNewCard: (() -> Void)?
    fileprivate var cards: [BankCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        tableView.register(R.nib.chooseCardTableViewCell)
        tableView.rowHeight = 50.0
        backButton.tintColor = UIColor(hex: 0x00a8fe)
        if pushMode {
        backButton.setTitle(R.string.localizable.button_title_back(), for: UIControlState())
            backButton.setImage(R.image.btn_left_arrow(), for: .normal)
            backButton.tintColor = UIColor(hex: 0x00a8fe)
        } else {
            backButton.setTitle(R.string.localizable.alertTitle_cancel(), for: UIControlState())
            backButton.setImage(nil, for: UIControlState())
        }
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func requestData() {
        let parameter = BankCardParameter()
        parameter.bankType = .all
        
        let req: Promise<BankCardListData> = handleRequest(Router.endpoint( BankCardPath.list, param: parameter))
        req.then { (value) -> Void in
            if let items = value.data?.cardList, !items.isEmpty {
                self.cards = items
                self.tableView.reloadData()
            }
        }.catch { _ in }
    }
    
    @IBAction fileprivate func dismissHandle() {
        if let block = dismiss {
            block(nil)
        }
    }
    
    @IBAction fileprivate func addHandle() {
        dismissHandle()
        if let block = addNewCard {
            block()
        }
    }

}

extension ChooseCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < cards.count {
            if let block = dismiss {
                block(cards[indexPath.row])
            }
        }
    
    }
}

extension ChooseCardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.chooseCardTableViewCell, for: indexPath) else { return UITableViewCell() }
        if indexPath.row < cards.count {
            let card = cards[indexPath.row]
            cell.configCard(card)
        }
        return cell
    }
}

//
//  TransViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/26/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import Eureka
import PromiseKit
import ObjectMapper
import URLNavigator

class TransViewController: FormViewController {
    
    @IBOutlet fileprivate weak var footerView: UIView!
    
    fileprivate var choosedCard: BankCard?
    fileprivate var choosedBank: Bank?
    var isCrossBank: Bool = false
    
    fileprivate var transParam = BankCardParameter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.controller_title_transfer_other()
        if !isCrossBank {
            title = R.string.localizable.controller_title_transfer_same()
        }
        let item = UIBarButtonItem(title: R.string.localizable.barButtonItem_title_help(), style: .plain, target: self, action: #selector(self.goHelpCenter))
        navigationItem.rightBarButtonItem = item
        setBackBarButton()
        setupTableView()
    }
    
    func setupTableView() {
        
        form =
            Section(R.string.localizable.eureka_section_pay_account_title())
            <<< TextRow() {
                $0.title = R.string.localizable.eureka_textrow_title_card_title()
                $0.tag = R.string.localizable.eureka_textrow_title_card_tag()
                }.cellSetup { (cell, row) in
                    cell.textField.isUserInteractionEnabled = false
                    cell.accessoryView = UIImageView(image: R.image.icon_card())
                }.onCellSelection { (cell, row) in
                    self.showChooseCard()
                }
            <<< DecimalRow() {
                $0.title = R.string.localizable.eureka_textrow_title_balance_title()
                $0.tag = R.string.localizable.eureka_textrow_title_balance_tag()
                }.cellSetup { (cell, row) in
                    cell.textField.isUserInteractionEnabled = false
                }
            +++ Section(R.string.localizable.eureka_section_pay_money())
            <<< DecimalRow() {
                $0.title = R.string.localizable.eureka_textrow_title_money_title()
                $0.tag = R.string.localizable.eureka_textrow_title_money_tag()
                $0.placeholder = R.string.localizable.eureka_textrow_title_money_paceholder()
                }.cellSetup { (cell, row) in
                    let label = UILabel()
                    label.text = "元"
                    label.sizeToFit()
                    cell.accessoryView = label
                }
            <<< DecimalRow() {
                $0.title = R.string.localizable.eureka_decimalrow_title_factorage()
                $0.value = 0.00
                $0.useFormatterDuringInput = true
                let formatter = CurrencyFormatter()
                formatter.locale = Locale(identifier: "zh_Hans_CN")
                formatter.numberStyle = .currency
                $0.formatter = formatter
                }.cellSetup { (cell, row) in
                    cell.textField.isUserInteractionEnabled = false
                    let label = UILabel()
                    label.text = "元"
                    label.sizeToFit()
                    cell.accessoryView = label
                }
            +++ Section(R.string.localizable.eureka_section_receiver_info_title()) {
                $0.tag = R.string.localizable.eureka_section_receiver_info_tag()
            }
            <<< TextRow() {
                $0.title = R.string.localizable.eureka_textrow_title_to_name_title()
                $0.tag = R.string.localizable.eureka_textrow_title_to_name_tag()
                $0.placeholder = R.string.localizable.eureka_textrow_title_to_name_paceholder()
            }
            <<< TextRow() {
                $0.title = R.string.localizable.eureka_textrow_title_to_number_title()
                $0.tag = R.string.localizable.eureka_textrow_title_to_number_tag()
                $0.placeholder = R.string.localizable.eureka_textrow_title_to_number_paceholder()
                }.cellSetup { (cell, row) in
                    cell.textField.keyboardType = .numberPad
                }
        
        guard let receiverInfoSection = form.sectionBy(tag: "receiver_info") else { return }
        if isCrossBank {
            receiverInfoSection
                <<< TextRow() {
                    $0.title = R.string.localizable.eureka_textrow_title_bank_title()
                    $0.tag = R.string.localizable.eureka_textrow_title_bank_tag()
                    $0.placeholder = R.string.localizable.eureka_textrow_title_bank_paceholder()
                    }.cellSetup { (cell, row) in
                        cell.textField.isUserInteractionEnabled = false
                        cell.accessoryView = UIImageView(image: R.image.bank_ico_bank())
                    }.onCellSelection { (cell, row) in
                        self.showChooseBank()
                    }
        }
        receiverInfoSection
            <<< TextRow() {
                $0.title = R.string.localizable.eureka_textrow_title_to_mobile_title()
                $0.tag = R.string.localizable.eureka_textrow_title_to_mobile_tag()
                $0.placeholder = R.string.localizable.eureka_textrow_title_to_mobile_paceholder()
                }.cellSetup { (cell, row) in
                    cell.textField.keyboardType = .numberPad
            }
            <<< TextRow() {
                $0.title = R.string.localizable.eureka_textrow_title_remark_title()
                $0.tag = R.string.localizable.eureka_textrow_title_remark_tag()
                $0.placeholder = R.string.localizable.eureka_textrow_title_remark_paceholder()
        }
        
        tableView?.configBackgroundView()
        tableView?.tableFooterView = footerView
        tableView?.reloadData()
    }
    
    fileprivate func showChooseBank() {
        guard let vc = R.storyboard.bank.bankListViewController() else { return }
        vc.dismiss = { bank in
            if let bank = bank {
                self.choosedBank = bank
                self.form.setValues(["bank": bank.name])
                self.tableView?.reloadData()
            }
            self.dim(.out, coverNavigationBar: true)
            self.dismiss(animated: true, completion: nil)
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func goHelpCenter() {
        guard let vc = R.storyboard.center.helpCenterHomeViewController() else { return }
        vc.tag = HelpCenterTag.transfer
        Navigator.push(vc)
    }
    
    internal func showChooseCard() {
        guard let vc = R.storyboard.main.chooseCardViewController() else { return }
        vc.pushMode = false
        vc.dismiss = { card in
            if let card = card {
                self.choosedCard = card
                self.form.setValues(["card": card.number, "balance": card.blance])
                self.tableView?.reloadData()
            }
            self.dim(.out, coverNavigationBar: true)
            self.dismiss(animated: true, completion: nil)
        }
        vc.addNewCard = {
            guard let vc = R.storyboard.bank.cardsListViewController() else { return }
            vc.lastViewController = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        dim(.in, coverNavigationBar: true)
        present(vc, animated: true, completion: nil)
    }
    
    fileprivate func validInputs() -> Promise<BankCardParameter> {
        // 转账必填项3个, 金额 姓名 卡号
        // 还需要验证 是否选择了付款帐号,跨行时还需要多验证是否选择了对方银行
        return Promise { fulfill, reject in
            let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
            let values = form.values()
            if let money = values["money"] as? Double,
                let name = values["to_name"] as? String,
                let number = values["to_number"] as? String,
                let card = choosedCard {
                let param = BankCardParameter()
                param.amount = Double(money)
                param.receiverName = name
                param.receiverCardNo = number
                param.cardID = card.cardID
                param.cardNo = card.number
                param.crossTrans = self.isCrossBank
                param.receiverMobile = values["to_mobile"] as? String
                param.remark = values["remark"] as? String
                if isCrossBank {
                    if let bank = choosedBank {
                        param.receiverBankID = bank.bankID
                        param.receiverBankName = bank.name
                        fulfill(param)
                    } else {
                        reject(error)
                    }
                } else {
                    fulfill(param)
                }
            } else {
                reject(error)
            }
        }
    }
    
    @IBAction func transHandle() {
        validInputs().then { (param) -> Void in
            self.transParam = param
            self.performSegue(withIdentifier: R.segue.transViewController.showTransConfirmVC, sender: nil)
        }.catch { (error) in
            if let err = error as? AppError {
                Navigator.showAlertWithoutAction(nil, message: err.toError().localizedDescription)
            }
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == R.segue.transViewController.showTransConfirmVC.identifier {
            guard let vc = segue.destination as? TransConfirmViewController else { return }
            vc.isCrossBank = isCrossBank
            vc.transParam = transParam
        }
    }
    
    override func textInput<T>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: Cell<T>) -> Bool {
        if cell.row.tag != "to_mobile" {
            return true
        } else {
            guard let textField = textInput as? UITextField else { return false }
            return validatePhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
        }
    }
}

extension TransViewController: ChooseCardProtocol {
    func dismissFromAddNewCard() {
        _ = self.navigationController?.popToViewController(self, animated: true)
        DispatchQueue.main.async { 
            self.showChooseCard()
        }
    }
}

extension TransViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return Const.TableView.SectionHeight.Header40
        } else {
            return 53
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return Const.TableView.SectionHeight.Header17
        } else {
            return Const.TableView.SectionHeight.Header0
        }
    }
}

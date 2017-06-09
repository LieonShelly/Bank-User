//
//  MyCollectionViewController.swift
//  Bank
//
//  Created by yang on 16/1/20.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
//  swiftlint:disable cyclomatic_complexity

import UIKit
import URLNavigator
import PromiseKit
import PullToRefresh
import MBProgressHUD

class MyCollectionViewController: BaseViewController {

    var myCollectionTableView: UITableView!
    
    @IBOutlet fileprivate weak var deleteButton: UIButton!
    @IBOutlet fileprivate weak var selectAllButton: UIButton!
    @IBOutlet fileprivate var editToolView: UIView!
    @IBOutlet fileprivate weak var editBarButtonItem: UIBarButtonItem!
    
    fileprivate var selectedGoods: Goods!
    fileprivate var goodsArray: [Goods] = []
    fileprivate var lastGoodsArray: [Goods] = []
    fileprivate var selectedArray: [Goods] = []
    fileprivate var currentPage: Int = 1
    fileprivate var removeArray: [Collectable] = []
    //手势组
    fileprivate var gesArray: [UIGestureRecognizer] = []
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.view.frame, type: .collection)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        view.addSubview(editToolView)
        selectAllButton.setImage(R.image.btn_choice_no(), for: .normal)
        selectAllButton.setImage(R.image.btn_choice_yes(), for: .selected)
        setTableView()
        addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isReload = currentPage == 1 ? false : true
        requestList(currentPage, isReload: isReload)
    }
    
    deinit {
        if let tableView = myCollectionTableView {
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let bottomRefresh = PullToRefresh(position: .bottom)
        myCollectionTableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestList((self?.currentPage ?? 1) + 1)
            self?.myCollectionTableView.endRefreshing(at: .bottom)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let refresh = myCollectionTableView.bottomPullToRefresh {
            myCollectionTableView.removePullToRefresh(refresh)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = self.selectedGoods.goodsID
        }
    }
    
    fileprivate func setTableView() {
        myCollectionTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), style: .plain)
        view.addSubview(myCollectionTableView)
        myCollectionTableView.register(R.nib.myCollectionTableViewCell)
        myCollectionTableView.allowsMultipleSelectionDuringEditing = true
        myCollectionTableView.tableFooterView = UIView()
        myCollectionTableView.configBackgroundView()
        myCollectionTableView.separatorStyle = .none
        myCollectionTableView.rowHeight = UITableViewAutomaticDimension
        self.editToolView.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(50)
            make.height.equalTo(50)
        })
        self.myCollectionTableView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.editToolView.snp.top).offset(0)
        })
        myCollectionTableView.delegate = self
        myCollectionTableView.dataSource = self
    }
    
    @IBAction func editBarButtonItem(_ sender: UIBarButtonItem) {
        if sender.title == "编辑" {
            sender.title = "完成"
            self.navigationItem.hidesBackButton = true
            myCollectionTableView.isEditing = true
            UIView.animate(withDuration: 0.3, animations: {
                self.editToolView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(0)
                })
            })
        } else {
            sender.title = "编辑"
            selectedArray.removeAll()
            selectAllButton.isSelected = false
            self.navigationItem.hidesBackButton = false
            myCollectionTableView.isEditing = false
            UIView.animate(withDuration: 0.3, animations: {
                self.editToolView.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(self.view).offset(50)
                })
                }, completion: { (finished) in
                    if finished == true {
                        
                    }
            })
            
        }
        myCollectionTableView.reloadData()
    }
    
    //全选
    @IBAction func selectAllAction(_ sender: UIButton) {
        selectedArray.removeAll()
        sender.isSelected = !sender.isSelected
        for i in 0..<goodsArray.count {
            let good = goodsArray[i]
            good.isChecked = sender.isSelected
            let indexPath = IndexPath(row: i, section: 0)
            if sender.isSelected {
                myCollectionTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                selectedArray.append(good)
            } else {
                myCollectionTableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    //批量删除
    @IBAction func deleteAction(_ sender: UIButton) {
        removeArray.removeAll()
        for goods in selectedArray {
            let collectable = Collectable()
            collectable.collectType = .goods
            collectable.collectId = goods.goodsID
            removeArray.append(collectable)
        }
        if removeArray.isEmpty {
            Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_choose_delete_goods())
            return
        }
        self.showAlertController(R.string.localizable.alertTitle_is_delete_goods(), array: removeArray)
    }
    
    //弹框提示是否删除宝贝
    fileprivate func showAlertController(_ message: String, array: [Collectable]) {
        let alert = UIAlertController(title: R.string.localizable.alertTitle_tip(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_confirm(), style: .default, handler: { (action) in
            self.requestRemoveCollect(array)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func selectRow() {
        for index in 0..<goodsArray.count where goodsArray[index].isChecked == true {
            let indexPath = IndexPath(row: index, section: 0)
            myCollectionTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
}

// MARK: request
extension MyCollectionViewController {
    
    /**
     请求收藏列表
     
     */
    func requestList(_ page: Int = 1, isReload: Bool = false) {
        MBProgressHUD.loading(view: view)
        let param = CollectionParameter()
        param.page = page
        param.perPage = 10
        let req: Promise<CollectionData> = handleRequest(Router.endpoint( CollectionPath.goodsList, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                if let array = value.data?.items {
                    self.currentPage = page
                    if self.currentPage == 1 {
                        self.goodsArray = array
                    } else {
                        if isReload == false {
                            self.lastGoodsArray = self.goodsArray
                        } else {
                            self.goodsArray = self.lastGoodsArray
                        }
                        self.goodsArray.append(contentsOf: array)
                    }
                    if self.goodsArray.isEmpty {
                        self.noneView.buttonHandleBlock = {
                                guard let vc = R.storyboard.mall.goodsListViewController() else {return}
                            vc.goodsType = .merchandise
                                Navigator.push(vc)
                        }
                        self.myCollectionTableView.addSubview(self.noneView)
                    } else {
                        self.noneView.removeFromSuperview()
                        self.myCollectionTableView.reloadData()
                        self.selectRow()
                    }
                }
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    //删除收藏
    func requestRemoveCollect(_ removeGoods: [Collectable]) {
        MBProgressHUD.loading(view: view)
        let param = CollectionParameter()
        param.goodsArray = removeGoods
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( CollectionPath.remove, param: param))
        req.then { (value) -> Void in
            if value.isValid {
                self.selectAllButton.isSelected = false
                if self.goodsArray.count == removeGoods.count {
                    self.goodsArray.removeAll()
                } else if removeGoods.count == 1 {
                    
                    for i in 0..<self.goodsArray.count {
                        guard let removeGood = removeGoods.first else {return}
                        guard let collectID = removeGood.collectId else {return}
                        if self.goodsArray[i].goodsID == collectID {
                            self.goodsArray.remove(at: i)
                            break
                        }
                    }
                    
                } else {
                    for good in self.goodsArray {
                        for index in 0..<removeGoods.count where good.goodsID == removeGoods[index].collectId {
                            self.goodsArray.remove(at: index)
                        }
                    }
                }
                self.selectedArray.removeAll()
                if self.myCollectionTableView.isEditing == true {
                    self.editBarButtonItem(self.editBarButtonItem)
                }
                self.myCollectionTableView.reloadData()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
        
    }
}

// MARK: UITableViewDataSource

extension MyCollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.myCollectionTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.deleteHandleBlock = {
            let collectable = Collectable()
            collectable.collectType = .goods
            collectable.collectId = self.goodsArray[indexPath.row].goodsID
            self.showAlertController(R.string.localizable.alertTitle_is_delete_goods(), array: [collectable])
        }
        cell.isEditing = tableView.isEditing
        cell.configGoods(goodsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

// MARK: UITableViewDelegate
extension MyCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            let goods = goodsArray[indexPath.row]
            goods.isChecked = true
            selectedArray.append(goods)
            selectAllButton.isSelected = selectedArray.count == goodsArray.count ? true : false
        } else {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "changeFrame"), object: nil)
            
            self.selectedGoods = goodsArray[indexPath.row]
            self.performSegue(withIdentifier: R.segue.myCollectionViewController.showGoodsDetailVC, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {

            for i in 0..<selectedArray.count where selectedArray[i].goodsID == goodsArray[indexPath.row].goodsID {
                selectedArray.remove(at: i)
                goodsArray[indexPath.row].isChecked = false
            }

            selectAllButton.isSelected = selectedArray.count == goodsArray.count ? true : false
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

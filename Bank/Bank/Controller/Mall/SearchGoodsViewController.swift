//
//  SearchGoodsViewController.swift
//  Bank
//
//  Created by yang on 16/4/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import PullToRefresh
import MBProgressHUD

public enum SearchType: Int {
    case allGoods = 0
    case merchantGoods = 1
}
class SearchGoodsViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    var searchType: SearchType?
    var storeCatID: String?
    var listView: ListView?
    var merchantID: String?
    var goodsArray: [Goods] = []
    
    fileprivate var currentPage = 1
    fileprivate var selectedGoods: Goods?
    fileprivate var selectedCat: GoodsCats?
    fileprivate var goodsCatArray: [GoodsCats] = []
    fileprivate var goodsSortArray: [GoodsSort] = []
    fileprivate var selectedSort: GoodsSort! = nil
    fileprivate var titleView: UITextField!
    fileprivate lazy var noneView: NoneView = { return NoneView(frame: self.tableView.bounds, type: .search)}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configUI()
        addPullToRefresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GoodsDetailViewController {
            vc.goodsID = selectedGoods?.goodsID
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleView.resignFirstResponder()
    }
    
    deinit {
        if let tableView = tableView {
            if let bottomRefresh = tableView.bottomPullToRefresh {
                tableView.removePullToRefresh(bottomRefresh)
            }
        }
    }
    
    fileprivate func addPullToRefresh() {
        let bottomRefresh = PullToRefresh(position: .bottom)
        tableView.addPullToRefresh(bottomRefresh) { [weak self] in
            self?.requestList((self?.currentPage ?? 1) + 1)
            self?.tableView.endRefreshing(at: .bottom)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configUI() {
        //搜索框
        titleView = UITextField(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        titleView.backgroundColor = UIColor.white
        titleView.placeholder = R.string.localizable.placeHoder_title_enter_search_keywords()
        titleView.clearButtonMode = .whileEditing
        titleView.layer.cornerRadius = 3
        titleView.tintColor = UIColor(hex: 0x00a8fe)
        titleView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 30))
        titleView.leftViewMode = .always
        titleView.delegate = self
        titleView.returnKeyType = .search
        self.setTitleView(view: titleView)
        setTableView()
        if storeCatID != nil {
            requestList()
        }
    }
    
    fileprivate func setListView(_ goodsCatArray: [GoodsCats]) {
        let listTitleArray = [R.string.localizable.string_title_all_cats(), R.string.localizable.string_title_default()]
        listView = ListView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40), titleArray: listTitleArray)
        listView?.titleColor = UIColor(hex: 0x666666)
        listView?.image = R.image.btn_open()
        if goodsCatArray.isEmpty == false {
            listView?.createDataSource(goodsCatArray, secondDatas: goodsCatArray[0].subCats, thirdDatas: goodsSortArray, firstIsCat: true)
        } else {
            listView?.createDataSource(goodsCatArray, secondDatas: [], thirdDatas: goodsSortArray, firstIsCat: true)
        }
        listView?.borderWidth = 0.3
        listView?.borderColor = UIColor(hex: 0xf7f7f7)
        if let view = listView {
           self.view.addSubview(view)
        }
        listView?.selectedCatHandleBlock = { [weak self] (cat, isAll) in
            self?.selectedCat = cat
            self?.requestList()
        }
        listView?.selectedSortHandleBlock = { [weak self] sort in
            self?.selectedSort = sort
            self?.requestList()
        }

    }
    
    @IBAction func searchGoodsAction(_ sender: UIBarButtonItem?) {
        titleView.resignFirstResponder()
        if titleView.text != nil {
            storeCatID = nil
        }
        goodsArray.removeAll()
        requestList()
        if searchType == .allGoods {
            //选择菜单
            requestSortData()
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(view).offset(50)
                make.left.equalTo(view).offset(0)
                make.right.equalTo(view).offset(0)
                make.bottom.equalTo(view).offset(0)
            }
        }
        
    }
    
    fileprivate func setTableView() {
        tableView.configBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.mallGoodsTableViewCell)
    }

}

// Request
extension SearchGoodsViewController {
    //请求商品列表
    fileprivate func requestList(_ page: Int = 1) {
        vaildInput(page).then { (param) -> Promise<GoodsListData> in
            MBProgressHUD.loading(view: self.view)
            let req: Promise<GoodsListData> = handleRequest(Router.endpoint( GoodsPath.list, param: param), needToken: .default)
            return req
            }.then { (value) -> Void in
                if value.isValid {
                    if let array = value.data?.items {
                        self.currentPage = page
                        if self.currentPage == 1 {
                            self.goodsArray = array
                        } else {
                            self.goodsArray.append(contentsOf: array)
                        }
                        self.tableView.reloadData()
                        self.storeCatID = nil
                    }
                    if self.goodsArray.isEmpty == true, let view = self.navigationController?.view {
                        self.tableView.tableFooterView = self.noneView
                        MBProgressHUD.errorMessage(view: view, message: "没有找到相关商品，建议精简关键词再试！")
                    } else {
                        self.tableView.tableFooterView = UIView()
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
    
    fileprivate func vaildInput(_ page: Int = 1) ->Promise<GoodsParameter> {
        return Promise { fulfill, reject in
            let count = titleView.text?.characters.isEmpty == false || storeCatID != nil
            switch count {
            case true:
                let param = GoodsParameter()
                param.page = page
                param.perPage = 20
                param.keyword = titleView.text
                if searchType == .allGoods {
                    if selectedSort != nil {
                        param.sortType = selectedSort.sortID
                    }
                    if selectedCat != nil {
                        param.catID = selectedCat?.catID
                    }
                }
                if searchType == .merchantGoods {
                    param.merchantID = self.merchantID
                    param.storeCategoryID = storeCatID
                }
                fulfill(param)
            case false:
                let error = AppError(code: ValidInputsErrorCode.empty, msg: nil)
                reject(error)
            }
        }
    }
    
    /**
     请求分类信息
     */
    fileprivate func requestCatData() {
        let req: Promise<GoodsCatsListData> = handleRequest(Router.endpoint( GoodsPath.category, param: nil), needToken: .default)
        req.then { (value) -> Void in
            if value.isValid {
                if var items = value.data?.cats {
                    let wholeCat = GoodsCats()
                    wholeCat.catID = "0"
                    wholeCat.catName = R.string.localizable.string_title_all_cats()
                    wholeCat.catType = .merchandise
                    for item in items {
                        wholeCat.subCats.append(contentsOf: item.subCats)
                    }
                    items.insert(wholeCat, at: 0)
                    self.goodsCatArray = items
                    self.setListView(items)
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
    
    /**
     请求排序信息
     */
    fileprivate func requestSortData() {
        let req: Promise<GoodsSortListData> = handleRequest(Router.endpoint( GoodsPath.sort, param: nil), needToken: .default)
        req.then { [weak self] (value) -> Void in
            if value.isValid {
                if let items = value.data?.orderbyList {
                    self?.goodsSortArray = items
                    self?.requestCatData()
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
}

// MARK: - UITableViewDataSource
extension SearchGoodsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goodsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MallGoodsTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.mallGoodsTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.configInfo(goodsArray[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchGoodsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        titleView.resignFirstResponder()
        selectedGoods = goodsArray[indexPath.row]
        self.performSegue(withIdentifier: R.segue.searchGoodsViewController.showGoodsDetailVC.identifier, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        titleView.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension SearchGoodsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchGoodsAction(nil)
        return true
    }
}

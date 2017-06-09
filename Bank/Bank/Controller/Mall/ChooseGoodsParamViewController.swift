//
//  ChooseGoodsParamViewController.swift
//  Bank
//
//  Created by 杨锐 on 2016/10/25.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

public enum ActionMode {
    case determin
    case addCart
    case buyNow
}

class ChooseGoodsParamViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var goodsImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    fileprivate var selectedButton: UIButton?
    fileprivate var goodsList: [Goods] = []
    fileprivate var titleArray: [GoodsProperty] = []
    fileprivate var propertySet: Set<GoodsProperty> = []
    fileprivate var selectedPropertys: Set<GoodsProperty> = []
    fileprivate var selectedPro: GoodsProperty?
    fileprivate var selectedGoods: Goods?
    
    var goods: Goods?
    var goodsConfigID: String?
    weak var lastController: GoodsDetailViewController?
    var dismissHandleBlock: (() -> Void)?
    var buttonHandleBlock: ((_ actionMode: ActionMode, _ selectedGoods: Goods?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        selectedGoods = goods
        requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 设置UI
    fileprivate func configUI() {
        setChooseView()
        let addCartBtn = UIButton(type: .custom)
        addCartBtn.setTitle(R.string.localizable.button_title_join_shop_car(), for: .normal)
        addCartBtn.backgroundColor = UIColor(hex: 0x00a8fe)
        addCartBtn.addTarget(self, action: #selector(addCartAction(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(addCartBtn)
            
        let buyNowBtn = UIButton(type: .custom)
        buyNowBtn.setTitle(R.string.localizable.button_title_buy_now(), for: .normal)
        buyNowBtn.backgroundColor = UIColor.orange
        buyNowBtn.addTarget(self, action: #selector(buyNowAction(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(buyNowBtn)
    }
    
    /// 加入购物车
    @objc fileprivate func addCartAction(_ sender: UIButton) {
        sender.isEnabled = false
        if selectedPropertys.count != goods?.propertyList.count {
            Navigator.showAlertWithoutAction(nil, message: "请选择完整的规格参数")
            sender.isEnabled = true
            return
        }
        dismissAction(nil)
        if let block = buttonHandleBlock {
            block(ActionMode.addCart, selectedGoods)
        }
    }
    
    /// 立刻购买
    @objc fileprivate func buyNowAction(_ sender: UIButton) {
        sender.isEnabled = false
        if selectedPropertys.count != goods?.propertyList.count {
            Navigator.showAlertWithoutAction(nil, message: "请选择完整的规格参数")
            sender.isEnabled = true
            return
        }
        dismissAction(nil)
        if let block = buttonHandleBlock {
            block(ActionMode.buyNow, selectedGoods)
        }
    }
    
    /// 取消
    @IBAction func dismissAction(_ sender: UIButton?) {
        if let block = dismissHandleBlock {
            block()
        }
    }

    fileprivate func setChooseView() {
        var maxY: CGFloat = 0
        var height: CGFloat = 0
        for title in titleArray {
            let array = propertySet.filter { return $0.id == title.id }
            let goodsParamView = GoodsParamView(frame: CGRect(x: 0, y: maxY, width: screenWidth, height: height), title: title, valueArray: array)
            goodsParamView.buttonHandleBlock = { [weak self] (title, property, isSelected) in
                self?.selectedPro = property
                if self?.selectedPropertys.contains(where: { (pro) -> Bool in
                    if isSelected == true {
                        if pro.id == property.id {
                            let goodsProperty = GoodsProperty()
                            goodsProperty.id = property.id
                            goodsProperty.title = property.title
                            goodsProperty.value = property.value
                            self?.selectedPropertys.insert(goodsProperty)
                            _ = self?.selectedPropertys.remove(pro)
                            return true
                        }
                        return false
                    } else {
                        if pro.id == property.id && pro.value == property.value {
                            _ = self?.selectedPropertys.remove(pro)
                            return true
                        }
                        return false
                    }
                }) == false {
                    let goodsProperty = GoodsProperty()
                    goodsProperty.id = property.id
                    goodsProperty.title = property.title
                    goodsProperty.value = property.value
                    self?.selectedPropertys.insert(goodsProperty)
                }
                self?.foundValueWithTitle(title: title, isSelected: isSelected)
                self?.checkGoodsID()
            }
            maxY = goodsParamView.frame.maxY
            height += goodsParamView.frame.height
            scrollView.addSubview(goodsParamView)
        }
        scrollView.contentSize = CGSize(width: screenWidth, height: height)
        for title in titleArray {
            self.foundValueWithTitle(title: title, isSelected: true)
        }
    }
    
    /// 创建TitleArray 和 商品规格数组
    func createArray() {
        for goods in goodsList {
            if goods.goodsID == self.goods?.goodsID {
                self.setGoodsInfo(goods: goods)
            }
            for param in goods.propertyList {
                if self.propertySet.contains(where: { (pro) -> Bool in
                    if pro.id == param.id {
                        return true
                    }
                    return false
                }) == false {
                }
                _ = self.propertySet.insert(param)
            }
        }
        if let list = goods?.propertyList {
            self.titleArray = list
        }
        if let pros = goods?.propertyList {
            selectedPropertys = Set(pros)
        }
    }

    /// 通过选中的一项规格对button视图重载
    fileprivate func foundValueWithTitle(title: GoodsProperty, isSelected: Bool?) {
        for subview in scrollView.subviews {
            if let view = subview as? GoodsParamView {
                let pros = self.selectedPropertys.filter { return $0.id != view.title.id }
                let goodsArray = goodsList.filter({ (goods) -> Bool in
                    let proSet: Set<GoodsProperty> = Set(pros)
                    return proSet.isSubset(of: goods.propertyList)
                })
                var propertys: [GoodsProperty] = []
                for goods in goodsArray {
                    propertys.append(contentsOf: goods.propertyList)
                }
                view.reloadViewWithData(propertys: propertys, isSelected: isSelected)
            }
        }
    }
    
    /// 找到选中的规格的商品
    fileprivate func checkGoodsID() {
        selectedGoods = nil
        for goods in self.goodsList where goods.propertyList.count == selectedPropertys.count {
            var proSet: Set<GoodsProperty> = []
            proSet = proSet.union(goods.propertyList)
            if selectedPropertys.isSubset(of: proSet) || proSet.isSubset(of: selectedPropertys) {
                selectedGoods = goods
                self.setGoodsInfo(goods: selectedGoods)
                lastController?.requestGoodsDetailData(goodsID: goods.goodsID)
            }
        }
    }
    
    /// 设置商品的封面和价格
    ///
    /// - Parameter goods: 选中的商品
    fileprivate func setGoodsInfo(goods: Goods?) {
        if let price = goods?.price.numberToString() {
            priceLabel.text = "¥\(price)"
        }
        goodsImageView.setImage(with: goods?.imageURL, placeholderImage: R.image.image_default_midden())
    }
    
}

extension ChooseGoodsParamViewController {
    /// 请求同一货号下的商品
    fileprivate func requestData() {
        let param = GoodsParameter()
        param.goodsConfigID = goodsConfigID
        MBProgressHUD.loading(view: view)
        let req: Promise<PropetryListData> = handleRequest(Router.endpoint( GoodsPath.alternativeGoods, param: param), needToken: .default)
        req.then { (value) -> Void in
            if let goodsList = value.data?.goodsList {
                self.goodsList = goodsList
            }
            self.createArray()
            self.configUI()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }

    }

}

//
//  ListView.swift
//  Bank
//
//  Created by yang on 16/4/5.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//
// swiftlint:disable force_unwrapping

import UIKit
class ListView: UIView {
    fileprivate var titleView: LScrollView!
    fileprivate var btnSet: [UIButton] = []
    fileprivate var firstOpenView: UITableView?
    fileprivate var secondOpenView: UITableView?
    fileprivate var thirdOpenView: UITableView?
    fileprivate var firstDatas: [GoodsCats] = []
    fileprivate var secondDatas: [GoodsCats] = []
    fileprivate var thirdDatas: [GoodsSort] = []
    fileprivate var isCat: Bool = true
    fileprivate var rect: CGRect!
    fileprivate var blackView: UIView!
    fileprivate var section: NSInteger = 0
    fileprivate var titleButtons: [LButton] = []

    var titles: [String] = []
    var selectedGoodsCat: GoodsCats!
    var selectedGoodsSubCat: GoodsCats!
    var selectedSortType: GoodsSort!
    var selectedCatID: String?
    var image: UIImage? {
        didSet {
            for btn in titleButtons {
                btn.image = image
            }
        }
    }
    var selectedCatHandleBlock: ((_ cat: GoodsCats, _ isAll: Bool) -> Void)?
    var selectedSortHandleBlock: ((_ sort: GoodsSort) -> Void)?
    var titleColor: UIColor = UIColor(hex: 0x00a8fe) {
        didSet {
            for btn in titleButtons {
                btn.setTitleColor(titleColor, for: .normal)
            }
        }
    }
    
    init(frame: CGRect, titleArray: [String]) {
        super.init(frame: frame)
        titles = titleArray
        titleView = LScrollView(frame: bounds)
        addSubview(titleView)
        
        blackView = UIView(frame: CGRect(x: 0, y: 40, width: frame.width, height: 0))
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tap = UITapGestureRecognizer(target: self, action: #selector(ListView.tapAction))
        blackView.addGestureRecognizer(tap)
        blackView.alpha = 1
        addSubview(blackView)
        sendSubview(toBack: blackView)
        setButtonTitles(titleArray)
        let line = UIView(frame: CGRect(x: 0, y: 39, width: frame.width, height: 1))
        line.backgroundColor = UIColor(hex: 0xe5e5e5)
        addSubview(line)
        self.rect = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createFirstTableView() {
        if isCat == true {
            firstOpenView = UITableView(frame: CGRect(x: 0, y: frame.height, width: frame.width/2, height: 0), style: .plain)
            firstOpenView?.register(R.nib.listViewFirstMenuTableViewCell)
        } else {
            firstOpenView = UITableView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: 0), style: .plain)
            firstOpenView?.register(R.nib.listViewSecondMenuTableViewCell)
        }
        firstOpenView?.separatorStyle = .none
        firstOpenView?.tag = 0
        firstOpenView?.delegate = self
        firstOpenView?.dataSource = self
        firstOpenView?.tableFooterView = UIView()
        if let view = firstOpenView {
            addSubview(view)
        }
    }
    
    func createSecondTableView() {
        secondOpenView = UITableView(frame: CGRect(x: frame.width/2, y: frame.height, width: frame.width/2, height: 0), style: .plain)
        secondOpenView?.tag = 1
        secondOpenView?.delegate = self
        secondOpenView?.dataSource = self
        secondOpenView?.tableFooterView = UIView()
        secondOpenView?.register(R.nib.listViewSecondMenuTableViewCell)
        if let view = secondOpenView {
            addSubview(view)
        }
    }
    
    func createThirdTableView() {
        thirdOpenView = UITableView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: 0), style: .plain)
        thirdOpenView?.tag = 2
        thirdOpenView?.delegate = self
        thirdOpenView?.dataSource = self
        thirdOpenView?.tableFooterView = UIView()
        thirdOpenView?.separatorStyle = .none
        thirdOpenView?.register(R.nib.listViewSecondMenuTableViewCell)
        if let view = thirdOpenView {
            addSubview(view)
        }
    }
    
    func createDataSource(_ firstDatas: [GoodsCats] = [], secondDatas: [GoodsCats] = [], thirdDatas: [GoodsSort] = [], firstIsCat: Bool) {
        self.firstDatas = firstDatas
        self.secondDatas = secondDatas
        self.thirdDatas = thirdDatas
        self.isCat = firstIsCat
        if !firstDatas.isEmpty {
            self.selectedGoodsCat = firstDatas[0]
        }
        if !secondDatas.isEmpty {
            self.selectedGoodsSubCat = secondDatas[0]
        }
        if !thirdDatas.isEmpty {
            self.selectedSortType = thirdDatas[0]
        }
        if firstDatas.isEmpty == false {
            for cat in firstDatas {
                if cat.catID == self.selectedCatID {
                    selectedGoodsCat = cat
                    selectedGoodsSubCat = selectedGoodsCat.subCats[0]
                    self.secondDatas = selectedGoodsCat.subCats
                    break
                } else {
                    for subcat in cat.subCats where subcat.catID == self.selectedCatID {
                        selectedGoodsCat = cat
                        selectedGoodsSubCat = subcat
                        self.secondDatas = selectedGoodsCat.subCats
                        break
                    }
                }
            }
        }
        if firstIsCat == true {
            createFirstTableView()
            createSecondTableView()
            createThirdTableView()
        } else {
            createThirdTableView()
        }
    }
    
    func setButtonTitles(_ titles: [String]) {
        if titles.count < 1 {
            return
        }
        self.titles = titles
        var count = titles.count
        count = titles.count > 3 ? 3 : count
        let btnWidth = titleView.frame.width / CGFloat(count)
        titleView.contentSize = CGSize(width: btnWidth * CGFloat(titles.count), height: titleView.contentSize.height)
        for i in 0..<titles.count {
            let frame = CGRect(x: CGFloat(i) * btnWidth, y: 0, width: btnWidth, height: titleView.frame.height)
            let title = titles[i]
            let btn = LButton(frame: frame)
            btn.tag = i
            btn.setTitle(title, for: UIControlState())
            btn.setTitleColor(UIColor(hex: 0x00A8FE), for: .selected)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            if i < 1 {
                btn.addLineWithLineSpacing(10)
            }
            titleButtons.append(btn)
            self.titleView.addSubview(btn)
        }
    }
    
    func tapAction() {
        click(btnSet[0])
    }
    
    func click(_ sender: UIButton) {
        
        section = sender.tag
        for view in titleView.subviews where view is LButton {
            guard let btn = view as? LButton else { return }
            if btn == sender {
//                    if btn.isSelected == true {
//                        btn.rightImageView.image = btn.image
//                    } else {
//                        btn.rightImageView.image = R.image.mall_goodslist_btn_more_up()
//                    }
                continue
            }
            btn.rightImageView.image = btn.image
            btn.isSelected = false
        }
        if btnSet.isEmpty == false {
            if btnSet[0] == sender {
                sender.isSelected = !sender.isSelected
                showAnyView(sender)
                return
            }
            btnSet.removeAll()
        }
        sender.isSelected = !sender.isSelected
        btnSet.append(sender)
        showAnyView(sender)
    }
    
    func showAnyView(_ sender: UIButton) {
        close()
        if sender.isSelected == true {
            if section == 0 {
                if isCat == true {
                    open(firstOpenView)
                    open(secondOpenView)
                } else {
                    open(thirdOpenView)
                }
            } else {
                open(thirdOpenView)
            }
        } else {
            close()
        }
        
    }
    
    func open(_ openView: UITableView?) {
        self.frame = UIScreen.main.bounds
        var blackFrame = self.blackView.frame
        blackFrame.size.height = self.frame.height
        self.blackView.frame = blackFrame
        UIView.animate(withDuration: 0.2, animations: { 
            var theFrame = openView?.frame
            if self.isCat == true {
                theFrame?.size.height = 6 * 40
            } else {
                theFrame?.size.height = CGFloat(self.thirdDatas.count) * 40
            }
            if let frame = theFrame {
                openView?.frame = frame
            }
        })
        openView?.reloadData()
    }
    
    func close() {
        self.frame = rect
        var blackFrame = self.blackView.frame
        blackFrame.size.height = 0
        blackView.frame = blackFrame
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            if self.firstOpenView != nil && self.secondOpenView != nil {
                var frame1 = self.firstOpenView?.frame
                frame1?.size.height = 0
                
                var frame2 = self.secondOpenView?.frame
                frame2?.size.height = 0
                if let rect1 = frame1, let rect2 = frame2 {
                    self.firstOpenView?.frame = rect1
                    self.secondOpenView?.frame = rect2
                }
            }
            var frame3 = self.thirdOpenView?.frame
            frame3?.size.height = 0
            if let rect3 = frame3 {
                self.thirdOpenView?.frame = rect3
            }
        }) 
    }
    
}

extension ListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == firstOpenView {
            guard let cell: ListViewFirstMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.listViewFirstMenuTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configInfo(firstDatas[indexPath.row])
            if selectedGoodsCat.catID == firstDatas[indexPath.row].catID {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return cell
        } else if tableView == secondOpenView {
            guard let cell: ListViewSecondMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.listViewSecondMenuTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            if indexPath.row == 0 {
                let allCat = GoodsCats()
                allCat.catName = R.string.localizable.label_title_all()
                allCat.catID = selectedGoodsCat.catID
                cell.configCatInfo(allCat)
                if selectedCatID == allCat.catID {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    cell.selectedImageView.isHidden = false
                }
            } else {
                cell.configCatInfo(secondDatas[indexPath.row - 1])
                if selectedCatID != nil && secondDatas[indexPath.row - 1].catID == selectedCatID {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    cell.selectedImageView.isHidden = false
                }
            }
            return cell
        } else {
            guard let cell: ListViewSecondMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.listViewSecondMenuTableViewCell, for: indexPath) else {
                return UITableViewCell()
            }
            cell.configSortInfo(thirdDatas[indexPath.row])
            
            if selectedSortType.name == thirdDatas[indexPath.row].name {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == firstOpenView {
            return firstDatas.count
        } else if tableView == secondOpenView {
            return secondDatas.count + 1
        } else {
            return thirdDatas.count
        }
    }

}

extension ListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == firstOpenView {
            selectedGoodsCat = firstDatas[indexPath.row]
            secondDatas = selectedGoodsCat.subCats
            secondOpenView?.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            secondOpenView?.reloadData()
        } else if tableView == secondOpenView {
            guard let cell = tableView.cellForRow(at: indexPath) as? ListViewSecondMenuTableViewCell else {
                return
            }
            if let block = selectedCatHandleBlock {
                if indexPath.row == 0 {
                    selectedCatID = cell.catID
                    btnSet[0].setTitle(selectedGoodsCat?.catName, for: UIControlState())
                    block(selectedGoodsCat, true)
                } else {
                    selectedGoodsSubCat = secondDatas[indexPath.row - 1]
                    selectedCatID = selectedGoodsSubCat.catID
                    btnSet[0].setTitle(selectedGoodsSubCat?.catName, for: UIControlState())
                    block(selectedGoodsSubCat, false)
                }
                
            }
            cell.isSelected = true
            cell.selectedImageView.isHidden = false
                        click(btnSet[0])
            self.close()
        } else {
            selectedSortType = thirdDatas[indexPath.row]
            guard let cell = tableView.cellForRow(at: indexPath) as? ListViewSecondMenuTableViewCell else {
                return
            }
            cell.isSelected = true
            if let block = selectedSortHandleBlock {
                block(selectedSortType)
            }
            btnSet[0].setTitle(self.selectedSortType.name, for: UIControlState())
            click(btnSet[0])
            self.close()
        }

    }
}

class LScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LButton: UIButton {
    var image: UIImage? = R.image.btn_open() {
        didSet {
            rightImageView.image = image
        }
    }
    var rightImageView: UIImageView = UIImageView()
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected == true {
                rightImageView.image = R.image.mall_goodslist_btn_more_up()
            } else {
                rightImageView.image = image
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = UIFont.systemFont(ofSize: 15)
        setTitleColor(UIColor.black, for: UIControlState())
//        setTitleColor(UIColor(hex: 0x00a8fe), for: .selected)
        rightImageView.bounds = CGRect(x: 0, y: 0, width: 8, height: 7)
        rightImageView.center = CGPoint(x: frame.width / 2 + 40, y: frame.height / 2)
        rightImageView.image = image
        addSubview(rightImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let titleLabel = titleLabel else {
            return
        }
        let titleLabelFrame = titleLabel.frame
        rightImageView.bounds = CGRect(x: 0, y: 0, width: 8, height: 7)
        rightImageView.center = CGPoint(x: titleLabelFrame.origin.x + titleLabelFrame.width + 20, y: frame.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLineWithLineSpacing(_ lineSpacing: CGFloat) {
        let view = UIView(frame: CGRect(x: frame.width - 1, y: lineSpacing, width: 1, height: frame.height - lineSpacing * 2))
        view.backgroundColor = UIColor(hex: 0xe5e5e5)
        addSubview(view)
    }
    
}

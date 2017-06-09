//
//  QuickMenuViewController.swift
//  Bank
//
//  Created by Mac on 15/11/24.
//  Copyright © 2015年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import PromiseKit
import URLNavigator
import MBProgressHUD

class QuickMenuViewController: BaseViewController {
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    fileprivate var allItems: [QuickMenu] = []
    // 选中的
    fileprivate var selectedItems: [QuickMenu] = []
    // 待选的
    fileprivate var otherItems: [QuickMenu] = []
    fileprivate var cell: UICollectionViewCell?
    fileprivate var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    fileprivate var selectedPoint: CGPoint = CGPoint(x: 0, y: 0)
    @IBOutlet fileprivate weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        longPressGesture = UILongPressGestureRecognizer(target: self, action:#selector(handleLongGesture(_:)))
        collectionView.addGestureRecognizer(longPressGesture)

        tabBarController?.tabBar.isHidden = true
        collectionView.register(R.nib.shortcutsViewCell)
        requestShortcuts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestSetShortcuts()
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            if (indexPath.section == 0 && indexPath.row < 4) || indexPath.section == 1 {
                break
            }
            cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = UIColor(hex: 0xe5e5e5)
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            cell?.backgroundColor = UIColor.white
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    //待选item
    func requestShortcuts() {
        MBProgressHUD.loading(view: view)
        let req: Promise<GetQuickMenuData> = handleRequest(Router.endpoint( UserPath.getShortcuts, param: nil))
        req.then { (value) -> Void in
            if let array = value.data?.menuList {
                self.allItems = array
                self.selectedItems = array.filter { return $0.isSelected }
                self.otherItems = array.filter { return !$0.isSelected }
                self.collectionView.reloadData()
            }
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    // 选中的items
    func requestSetShortcuts() {
        let param = UserParameter()
        param.menuIDs = selectedItems.flatMap { return $0.menuID }
        MBProgressHUD.loading(view: view)
        let req: Promise<NullDataResponse> = handleRequest(Router.endpoint( UserPath.setShortcuts, param: param))
        req.then { (value) -> Void in
            self.collectionView.reloadData()
            }.always {
                MBProgressHUD.hide(for: self.view, animated: true)
            }.catch { (error) in
                if let err = error as? AppError {
                    MBProgressHUD.errorMessage(view: self.view, message: err.toError().localizedDescription)
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension QuickMenuViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return selectedItems.count
        } else {
            if otherItems.isEmpty {
                return 1
            }
            return otherItems.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ShortcutsViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.shortcutsViewCell, for: indexPath) else { return UICollectionViewCell() }
        cell.backgroundColor = UIColor.white
        if indexPath.section == 0 {       
            cell.configShortcuts(selectedItems[indexPath.item], index: indexPath as NSIndexPath, isHome: false)
        } else {
            if otherItems.isEmpty {
                let noneCell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickMenuCollectionCell", for: indexPath)
                noneCell.backgroundColor = UIColor.white
                return noneCell
            }
            cell.backgroundColor = UIColor.white
            cell.configShortcuts(otherItems[indexPath.item], index: indexPath as NSIndexPath, isHome: false)
        }
        cell.button.isEnabled = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0 && indexPath.row < 4) || indexPath.section == 1 {
            return false
        }
        return true
    }
    
    //移动item
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: sourceIndexPath)
        cell?.backgroundColor = UIColor.white
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 && destinationIndexPath.item >= 4 {
            let item = selectedItems[sourceIndexPath.item]
            selectedItems.remove(at: sourceIndexPath.item)
            selectedItems.insert(item, at: destinationIndexPath.item)
            requestSetShortcuts()
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reuseID: String!
        if kind == UICollectionElementKindSectionHeader {
            reuseID = "header"
        } else {
            reuseID = "footer"
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseID, for: indexPath)
        return view
    }
}

extension QuickMenuViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 选中item
        if indexPath.section == 0 {
            if indexPath.row >= 4 {
                let otherItem = selectedItems[indexPath.row]
                otherItems.append(otherItem)
                selectedItems.remove(at: indexPath.row)
            } else {
                Navigator.showAlertWithoutAction(nil, message: R.string.localizable.alertTitle_quickmenu_cannotfix())
            }
        } else {
            
            if !otherItems.isEmpty {
                // 待选item
                selectedIndexPath = indexPath
                let selItem = otherItems[indexPath.row]
                // 选中item+1
                selectedItems.append(selItem)
                otherItems.remove(at: indexPath.row)
            }
        }
        collectionView.reloadData()

    }
    
}

extension QuickMenuViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 && otherItems.isEmpty {
            return CGSize(width: 300, height: 80)
        }
        return CGSize(width: 85, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.zero
        }
        
        return CGSize(width: view.frame.width, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize.zero
        }
        return CGSize(width: view.frame.width, height: 120)
    }
    
}

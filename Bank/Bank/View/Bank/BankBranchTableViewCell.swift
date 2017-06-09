//
//  BankBranchTableViewCell.swift
//  Bank
//
//  Created by Koh Ryu on 16/3/7.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit
import CoreLocation

private enum MapsType {
    case baidu
    case gaode
    case apple
}

class BankBranchTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var addressLabel: UILabel!
    
    fileprivate var branch: Branch?
    weak var controller: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func telHandle() {
        if let number = branch?.tel, !number.isEmpty, let URL = URL(string: "tel://\(number)") {
            let alertVC = UIAlertController(title: R.string.localizable.alertTitle_nil(), message: R.string.localizable.alertTitle_is_call_Service(), preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_call(), style: .default, handler: { (_) in
                UIApplication.shared.openURL(URL)
            }))
            alertVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
            controller?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func navigateHandle() {
        if let coordinate = branch?.coordinate {
            let sheetVC = UIAlertController(title: R.string.localizable.alertTitle_navigation(), message: nil, preferredStyle: .actionSheet)
            if let URL = URL(string: "baidumap://map/") {
                if UIApplication.shared.canOpenURL(URL) {
                    sheetVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_baidu_map(), style: .default, handler: { (_) in
                        self.openMaps(coordinate, type: .baidu, destination: self.branch?.name)
                    }))
                }
            }
            if let URL = URL(string: "iosamap://") {
                if UIApplication.shared.canOpenURL(URL) {
                    sheetVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_gaode_map(), style: .default, handler: { (_) in
                        self.openMaps(coordinate, type: .gaode)
                        
                    }))
                }
            }
            
            sheetVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_apple_map(), style: .default, handler: { (_) in
                self.openMaps(coordinate, type: .apple)
            }))
            sheetVC.addAction(UIAlertAction(title: R.string.localizable.alertTitle_cancel(), style: .cancel, handler: nil))
            controller?.present(sheetVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func openMaps(_ coordinate: CLLocationCoordinate2D, type: MapsType, destination: String? = nil) {
        var string: String = ""
        switch type {
        case .baidu:
            let dest = destination ?? "目的地"
            string = "baidumap://map/direction?origin={{我的位置}}&destination=latlng:\(coordinate.latitude),\(coordinate.longitude)|name=\(dest)&mode=driving&coord_type=wgs84"
        case .gaode:
            string = "iosamap://navi?sourceApplication= &backScheme= &lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&dev=0&style=2"
        case .apple:
            string = "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.latitude)&dirflg=d"
        }
        let URLString = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if let string = URLString, let URL = URL(string: string) {
            UIApplication.shared.openURL(URL)
        }
    }
    
    func configData(_ branch: Branch, keyword: String? = nil) {
        self.branch = branch
        if let name = branch.name, let keyword = keyword {
            var aName = NSMutableAttributedString(string: name)
            aName = apply(aName, word: keyword)
            nameLabel.attributedText = aName
        } else {
            nameLabel.text = branch.name
        }
        addressLabel.text = branch.address
    }
    
}

//
//  PurchasedProductViewController.swift
//  Bank
//
//  Created by Koh Ryu on 11/30/15.
//  Copyright © 2015 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class PurchasedProductViewController: BaseViewController {

    @IBOutlet private weak var webView: UIWebView!
    
    var product: Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let URL = product?.detailLink {
            webView.loadRequest(NSURLRequest(URL: URL))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == R.segue.purchasedProductViewController.showTotalProfitVC.identifier {
//            if let vc = segue.destinationViewController as? ProfitDetailViewController {
//                vc.product = product
//            }
//        }
    }
  
}

extension PurchasedProductViewController: UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
}

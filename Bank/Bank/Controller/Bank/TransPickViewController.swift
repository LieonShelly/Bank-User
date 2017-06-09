//
//  TransPickViewController.swift
//  Bank
//
//  Created by Koh Ryu on 16/1/8.
//  Copyright © 2016年 ChangHongCloudTechService. All rights reserved.
//

import UIKit

class TransPickViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.configBackgroundView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.transPickViewController.showTransVC.identifier {
            guard let vc = segue.destination as? TransViewController else {
                return
            }
            vc.isCrossBank = tableView.indexPathForSelectedRow?.row == 1
        }
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func unwindToTransPick(_ segue: UIStoryboardSegue) {
        
    }

}

extension TransPickViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: R.segue.transPickViewController.showTransVC, sender: nil)
    }
}

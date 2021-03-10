//
//  MoreViewController.swift
//  duTest
//
//  Created by Prateek Kansara on 10/03/21.
//

import Foundation
import UIKit

//TODO: Added only for Logout button
class MoreViewController: UIViewController {
    
    @IBOutlet weak var optionsTable : UITableView!
    
    private let options = ["Logout"]
    
    override func viewDidLoad() {
        optionsTable.reloadData()
        
        optionsTable.tableFooterView = UIView(frame: .zero)
    }
    
}

extension MoreViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
}

extension MoreViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let parentAsTab = self.parent as? BaseTabBarViewController{
                parentAsTab.dismiss(animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
}

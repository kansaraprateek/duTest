//
//  FavoriteViewController.swift
//  duTest
//
//  Created by Prateek Kansara on 10/03/21.
//

import Foundation
import UIKit

class FavoriteViewController: UIViewController {
    @IBOutlet weak var container : UIView!
    
    override func viewDidLoad() {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postList" {
            if let destinaton = segue.destination as? PostTableViewController{
                destinaton.isFavorite = true
            }
        }
    }
}

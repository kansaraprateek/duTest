//
//  PostsTableViewCell.swift
//  duTest
//
//  Created by Prateek Kansara on 10/03/21.
//

import UIKit

class PostsTableViewCell : UITableViewCell{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
        self.detailTextLabel?.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var post: Post! {
        didSet {
            self.textLabel?.text = post.title
            self.detailTextLabel?.text = post.body
        }
    }
}

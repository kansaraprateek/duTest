//
//  PostTableViewController.swift
//  duTest
//
//  Created by Prateek Kansara on 10/03/21.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import CoreData
class PostTableViewController: UIViewController, UIScrollViewDelegate {
 
    @IBOutlet private weak var postsTableView: UITableView!
    @IBOutlet private weak var searchBar : UISearchBar!
    
    var isFavorite : Bool = false
    
    let postViewModel = PostViewModel()
    
    let disposeBag = DisposeBag()
    
    public var posts = PublishSubject<[Post]>()
    public var searchPosts = PublishSubject<String>()
    
    override func viewDidLoad() {
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchPosts.onNext(searchBar.text ?? "")
    }
    
    /// Setup bindings
    private func setupBindings(){
        self.postViewModel.isFavorite = isFavorite
        postViewModel.bindSearch(searchBinding: searchPosts)
        
        postViewModel.getPosts(posts: posts)
                
        postsTableView.register(PostsTableViewCell.self, forCellReuseIdentifier: String(describing: PostsTableViewCell.self))
        
        posts.bind(to: postsTableView.rx.items(cellIdentifier: "PostsTableViewCell", cellType: PostsTableViewCell.self)) {  (row,post,cell) in
            cell.post = post
            }.disposed(by: disposeBag)
        
        
        postsTableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        postsTableView.rx.modelSelected(Post.self).subscribe(onNext : { [weak self] post in
            guard let self = self else { return }
            post.isFavorite = !post.isFavorite
            DatabaseManager.shared.persistentContainer.viewContext.mergePolicy = NSOverwriteMergePolicy
            DatabaseManager.shared.saveContext()
            self.searchPosts.onNext(self.searchBar.text ?? "")
            self.updateBadge()
        }).disposed(by: disposeBag)
    }
    
    /// Update badge for  favorite tab
    func updateBadge(){
        if let tabbarVc = self.parent?.parent as? UITabBarController, let tabItems = tabbarVc.tabBar.items {
            let tabItem = tabItems[1]
            tabItem.badgeValue = (postViewModel.getFavCount() != nil ? "\(postViewModel.getFavCount() ?? 0)" : nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PostTableViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchPosts.onNext(searchBar.text ?? "")
    }
}

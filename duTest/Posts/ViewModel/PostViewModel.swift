//
//  PostViewModel.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

import Foundation
import RxSwift
import RxCocoa
import CoreData

class PostViewModel: BaseViewModel {
    
    private var searchPosts : PublishSubject<String>?
    private var postsUpdate : PublishSubject<[Post]>?
    
    private var postURL : String{
        return baseURL + "/posts"
    }
    
    public var isFavorite : Bool = false
    
    func getPosts(posts : PublishSubject<[Post]>){
        postsUpdate = posts
        if isFavorite {return}
        requestData(url: postURL, method: .get, parameters: Post?.none, response: [Post].self, completion: {[weak self]
            allPosts in
            DatabaseManager.shared.saveContext()
            self?.searchPosts?.onNext("")
            print(posts as Any)
        }, failed: { [weak self]
            errorMessage in
            
        })
    }
    
    let disposeBag = DisposeBag()
    
    /// Method to bind search subject
    /// - Parameter searchBinding:
    func bindSearch(searchBinding : PublishSubject<String>){
        self.searchPosts = searchBinding
        self.searchPosts!.bind{ [weak self] searchText in
            let fetchedPosts = self?.getSearchPost(searchText: searchText)
            self?.postsUpdate?.onNext(fetchedPosts!)
        }.disposed(by: disposeBag)
    }
    
    /// Method to get all the posts wth search text entered in search bar, if empty, returns all the data
    /// - Parameter searchText: text to be searched
    /// - Returns: All the resulted post from search
    private func getSearchPost(searchText : String) -> [Post]{
        let query:NSFetchRequest<Post> = Post.fetchRequest()
        query.returnsObjectsAsFaults = false
        var searchPredicate = [NSPredicate]()
        if !searchText.isEmpty{
            searchPredicate.append(NSPredicate(format: "title contains[c] %@", searchText))
        }
        if (self.isFavorite){
            let predicateIsFav = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            searchPredicate.append(predicateIsFav)
        }
        if searchPredicate.count > 0{
            let andPredicate = NSCompoundPredicate(type: .and, subpredicates: searchPredicate)
            query.predicate = andPredicate
        }
        
        do{
            let fetchedPosts = try DatabaseManager.shared.persistentContainer.viewContext.fetch(query)
            return fetchedPosts
        }catch let err as NSError{
            print(err.debugDescription)
        }
        return []
    }
    
    /// Method to get favorite posts count
    /// - Returns: Number of Favorites
    func getFavCount() -> Int?{
        
        let query:NSFetchRequest<Post> = Post.fetchRequest()
        query.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        do{
            let fetchedPosts = try DatabaseManager.shared.persistentContainer.viewContext.fetch(query)
            return fetchedPosts.count
        }catch let err as NSError{
            print(err.debugDescription)
        }
        return nil
    }
}

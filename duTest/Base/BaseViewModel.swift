//
//  BaseModel.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

import Foundation
import RxSwift
import RxCocoa

/// Base View Model to handle common methods among all View Models
class BaseViewModel {
    
    let baseURL = "https://jsonplaceholder.typicode.com"
    
    var errorMessage : Observable<String?>   = Observable.just(nil)
    let loading : PublishSubject<Bool> = PublishSubject()
    
    func requestData<T, U>(url : String, method : APIManager.HTTPMethod, parameters : T?, response : U.Type, completion: @escaping (U?)->Void, failed : @escaping (String?) -> Void) where T : Encodable, U: Decodable{
        APIManager.request(url: url, method: method, parameters: parameters, response: response, completion: completion, failed: failed)
    }
}

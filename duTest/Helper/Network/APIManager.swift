//
//  APIManager.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

import Foundation
import Alamofire

/// Class to handle request with AlarmOfire
class APIManager {
    
    enum HTTPMethod: String {
        case get     = "GET"
        case post    = "POST"
        case put     = "PUT"
        case delete  = "DELETE"
    }
    
    enum RequestError: Error {
        case unknownError
        case connectionError
        case authorizationError(String)
        case invalidRequest
        case notFound
        case invalidResponse
        case serverError
        case serverUnavailable
    }
    
    enum ApiResult {
        case success(Codable)
        case failure(RequestError)
    }
    
    static func request<T, U>(url : String, method : HTTPMethod, parameters : T?, response : U.Type, completion: @escaping (U?)->Void, failed : @escaping (String?) -> Void) where T : Encodable, U: Decodable{
        AF.request(url, method: AFMethod(method: method), parameters: parameters ?? nil, encoder: JSONParameterEncoder.default, headers: nil, interceptor: nil, requestModifier: nil)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: U.self) { response in
                switch response.result {
                case .success:
                    completion(response.value)
                    print("Validation Successful")
                case let .failure(error):
                    failed(response.error?.errorDescription)
                    print(error)
            }
        }
    }
    
    
    private static func AFMethod(method : HTTPMethod) -> Alamofire.HTTPMethod{
        return Alamofire.HTTPMethod.init(rawValue: method.rawValue)
    }
}

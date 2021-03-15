//
//  LoginViewModel.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

/// Login View Model
class LoginViewModel : BaseViewModel{
    
    let loginURL = ""
    var credentialsErrorMessage     = PublishSubject<String>()
    var isUsernameFieldHighlighted  = PublishSubject<Bool>()
    var isPasswordFieldHighlighted  = PublishSubject<Bool>()
    var loginSuccess                = BehaviorRelay<Bool>(value: false)
    
    let usernameRelay = PublishSubject<String?>()
    let passwordRelay = PublishSubject<String?>()

    let autoLoginBinding = PublishSubject<Credentials>()
    
    var isValid: Observable<CredentialsInputStatus>{

//        Had to provide a startWith value as combineLatest would only be occured if all the observable has emitted at least one value
        return Observable.combineLatest(usernameRelay.asObservable().startWith(nil), passwordRelay.asObservable().startWith(nil)){
            (username, password) in
            
            switch (true){
            case username == nil && password == nil:
                return .Ignore
            case username?.isEmpty ?? true && password?.isEmpty ?? true:
                return .Incorrect("Please provide username and password.")
            case username?.isEmpty ?? true:
                return .Incorrect("Username field is empty.")
            case !NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: username):
                return .Incorrect("Invalid Email.")
            case password?.isEmpty ?? true:
                return .Incorrect("Password field is empty.")
            case !(8...15).contains(password!.trimmingCharacters(in: .whitespacesAndNewlines).count):
                return .Incorrect("Password should be minimum 8 charters, and maximum 15 characters")
            default:
                break
            }
            self.credentials = Credentials(username: username!, password: password!)
            return .Correct
        }

    }
    
    /// Credentials object to store username and passwords
    private var credentials = Credentials() {
            didSet {
                username = credentials.username
                password = credentials.password
            }
        }
        
    private var username = ""
    private var password = ""

    override init() {}
    
    /// Update existing credential object
    /// - Parameters:
    ///   - username: username entered in email field
    ///   - password: pasword entered in password field
    func updateCredentials(username: String, password: String) {
            credentials.username = username
            credentials.password = password
    }
    
    /// Updating credentials object with new values
    /// - Parameter credentials: credentials type object
    func updateCredentials(credentials : Credentials) {
        self.credentials = credentials
    }
    
    /// Method to call login API
    func login() {
        
        self.loading.onNext(true)
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
//          Store login credentials
            let data = self.credentials.password.data(using: .utf8)
            DefaultsManager.set(for: "username", value: self.credentials.username)
            _ = KeyChainManager.save(key: self.credentials.username, data: data!)
            
            self.loading.onNext(false)
            DefaultsManager.set(for: defaults.autoLogin.rawValue, value: true)
            self.loginSuccess.accept(true)
        }
        
        
//        TODO: Uncomment After implementing login with API
//        requestData(url: loginURL, method: .post, parameters: credentials, response: LoginResponse.self, completion: { [weak self]
//            (response) in
//
//            print(response as Any)
//        }, failed: { error in
//            print("Request Failed \(error ?? "")")
//        })
            
    }
    
    func checkAutoLogin(){
        if let username = DefaultsManager.get(for: "username"){
            if let loginDetails = KeyChainManager.load(key: username){
                if let password = String(data: loginDetails, encoding: .utf8){
                    let lCredentials = Credentials(username: username, password: password)
                       self.credentials = lCredentials
                    self.autoLoginBinding.onNext(lCredentials)
                       login()
                }
            }
        }
    }
    
    // Refactored as per the new changes
    /// Credentials Input check
    /// - Returns: .Correct, if credentials are correct, else .Incorrect
//    func credentialsInput(_ username : String = "", password : String = "") -> CredentialsInputStatus {
//        if username.isEmpty && password.isEmpty {
//            credentialsErrorMessage.onNext("Please provide username and password.")
//            return .Incorrect
//        }
//        if username.isEmpty {
//            credentialsErrorMessage.onNext("Username field is empty.")
//            isUsernameFieldHighlighted.onNext(true)
//            return .Incorrect
//        }
//        if password.isEmpty {
//            credentialsErrorMessage.onNext("Password field is empty.")
//            isPasswordFieldHighlighted.onNext(true)
//            return .Incorrect
//        }
//
//        if !isValidEmail(username){
//            credentialsErrorMessage.onNext("Invalid Email.")
//            isUsernameFieldHighlighted.onNext(true)
//            return .Incorrect
//        }
//
//        if password.trimmingCharacters(in: .whitespacesAndNewlines).count <= 8 || password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 15 {
//            credentialsErrorMessage.onNext("Password should be minimum 8 charters, and maximum 15 characters")
//            isPasswordFieldHighlighted.onNext(true)
//            return .Incorrect
//        }
//
//        return .Correct
//    }
    
    /// Valid Email check
    /// - Parameter email: email address to be check against regex
    /// - Returns: true if email address is valid, else false
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    
}

extension LoginViewModel {
    enum CredentialsInputStatus{
        case Correct
        case Ignore
        case Incorrect(String)
    }
    
    enum defaults : String{
        case autoLogin = "AutoLogin"
    }
}

//
//  ViewController.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField        : UITextField!
    @IBOutlet weak var passwordTextField        : UITextField!
    @IBOutlet weak var errorDescriptionLabel    : UILabel!
    @IBOutlet weak var loginButton              : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        setupBindings()
        setDelegates()
        
    }
    
    var loginViewModel = LoginViewModel()
    let disposeBag = DisposeBag()

    /// Updating view elements properties
    func setupView() {
        usernameTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 20
        
        loginButton.isEnabled = false
    }
    
    /// Setting text field delegates
    func setDelegates() {
            usernameTextField.delegate = self
            passwordTextField.delegate = self
        }
    
    /// Setting Bindings from Model
    func setupBindings(){
        loginViewModel.loading.bind(to: self.rx.isAnimating).disposed(by: disposeBag)
        
        loginViewModel.credentialsErrorMessage.bind { [weak self] in
            self?.showErrorMessage(message: $0)
        }
        .disposed(by: disposeBag)
                
        loginViewModel.isUsernameFieldHighlighted.bind { [weak self] in
                    if $0 { self?.highlightTextField(self?.usernameTextField)}
        }
        .disposed(by: disposeBag)
                
        loginViewModel.isPasswordFieldHighlighted.bind { [weak self] in
                if $0 { self?.highlightTextField(self?.passwordTextField)}
        }
        .disposed(by: disposeBag)
                
        loginViewModel.errorMessage.bind { [weak self] in
            self?.showErrorMessage(message: $0)
        }
        .disposed(by: disposeBag)
        
        loginViewModel.loginSuccess.observe(on: MainScheduler.instance).bind { [weak self] success in
            if success{ self?.pushToDashboard() }
        }
        .disposed(by: disposeBag)
    }
    
    /// Showing error message or invalid credentials
    /// - Parameter message: message to be displayed
    func showErrorMessage(message : String?){
        self.errorDescriptionLabel.isHidden = false
        self.errorDescriptionLabel.text = message
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        login()
      }
    
    /// Method to check login on
    func checkLogin()  {
        self.view.endEditing(true)
        let credentials = Credentials(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "")
        loginViewModel.updateCredentials(credentials: credentials)
          //Here we check user's credentials input - if it's correct we call login()
          switch loginViewModel.credentialsInput() {
          case .Correct:
            loginButton.isEnabled = true
          case .Incorrect:
            loginButton.isEnabled = false
              return
          }
    }
    
    func login() {
            loginViewModel.login()
        }
    
    func pushToDashboard() {
        performSegue(withIdentifier: "loginSuccess", sender: self)
    }
    
    /// Method to update text field border on invalid input
    /// - Parameter textField: text field to be updated
    func highlightTextField(_ textField: UITextField?) {
           textField?.resignFirstResponder()
           textField?.layer.borderWidth = 1.0
           textField?.layer.borderColor = UIColor.red.cgColor
           textField?.layer.cornerRadius = 3
       }
}

// Text Field Delegates
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorDescriptionLabel.isHidden = true
        usernameTextField.layer.borderWidth = 0
        passwordTextField.layer.borderWidth = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        checkLogin()
    }
}

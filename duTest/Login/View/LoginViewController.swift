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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loginViewModel.autoLoginBinding
            .observe(on: MainScheduler.instance)
            .bind{ [weak self]
            loginDetails in
                self?.usernameTextField.rx.text.onNext(loginDetails.username)
                self?.passwordTextField.rx.text.onNext(loginDetails.password)
        }
        .disposed(by: disposeBag)
        loginViewModel.checkAutoLogin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // TODO: Remove bindings
        
        self.usernameTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    var loginViewModel = LoginViewModel()
    let disposeBag = DisposeBag()

    /// Updating view elements properties
    func setupView() {
        usernameTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        
        
        loginButton.layer.cornerRadius = 20
        
        loginButton.isEnabled = false
        loginButton.backgroundColor = .systemGray
        
        errorDescriptionLabel.isHidden = true
    }
    
    /// Setting text field delegates
    func setDelegates() {
            usernameTextField.delegate = self
            passwordTextField.delegate = self
        }
    
    /// Setting Bindings from Model
    func setupBindings(){
        loginViewModel.loading.bind(to: self.rx.isAnimating).disposed(by: disposeBag)
        
//        Not Required after binding with text field
//
//        loginViewModel.credentialsErrorMessage.bind { [weak self] in
//            self?.showErrorMessage(message: $0)
//        }
//        .disposed(by: disposeBag)
                
        loginViewModel.isUsernameFieldHighlighted
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                    if $0 { self?.highlightTextField(self?.usernameTextField)}
        }
        .disposed(by: disposeBag)
                
        loginViewModel.isPasswordFieldHighlighted
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                if $0 { self?.highlightTextField(self?.passwordTextField)}
        }
        .disposed(by: disposeBag)
        
        loginViewModel
            .loginSuccess
            .observe(on: MainScheduler.instance)
            .bind { [weak self] success in
                if success{ self?.pushToDashboard() }
        }
        .disposed(by: disposeBag)
        
        
        usernameTextField.rx.text
            .orEmpty
            .bind(to: loginViewModel.usernameRelay)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .bind(to: loginViewModel.passwordRelay)
            .disposed(by: disposeBag)
        
        
        // Could have bind with isEnabled property directly, but needed to update color and error message with the same binding.
        loginViewModel.isValid
            .observe(on: MainScheduler.instance)
            .bind{[weak self] status in
            switch status {
            case .Correct:
                self?.loginButton.isEnabled = true
                self?.loginButton.backgroundColor = UIColor.systemTeal
                self?.errorDescriptionLabel.isHidden = true
                break
            case .Incorrect(let message):
                self?.loginButton.isEnabled = false
                self?.loginButton.backgroundColor = .systemGray
                self?.showErrorMessage(message: message)
                break
            case .Ignore:
                self?.errorDescriptionLabel.isHidden = true
                break
            }
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
        self.view.endEditing(true)
        login()
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
//        errorDescriptionLabel.isHidden = true
//        usernameTextField.layer.borderWidth = 0
//        passwordTextField.layer.borderWidth = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

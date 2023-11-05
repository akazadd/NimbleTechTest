//
//  LoginViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 2/11/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    var router: LoginRouter!
    var viewModel: LoginViewModel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var loginButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUIActions()
        configureUI()
    }
    
    private func configureUI() {
        [emailTextField,passwordTextField] .forEach { textfield in
            textfield?.addBorder(withColor: .white, cornerRadius: 12.0, borderWidth: 0.2)
        }
        loginButton.layer.cornerRadius = 12.0
        emailTextField.setPlaceholderColor(.white)
    }

    private func configureUIActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordLabelTapped))
                passwordTextField.forgotPasswordLabel.addGestureRecognizer(tapGesture)
        loginButton.addTarget(self, action: #selector(onLoginButtonTap), for: .touchUpInside)
    }
    
    @objc func onLoginButtonTap() {
        self.view.endEditing(true)
        loginButton.showLoading()
        viewModel.validateInput(emailTextField.text, password: passwordTextField.text) { [weak self] (valid, message) in
            guard let self = self else { return }
            
            switch valid {
            case true:
                let loginRequestInfo = LoginRequestInfo(email: self.emailTextField.text!, password: self.passwordTextField.text!)
                self.viewModel.login(loginRequestInfo) { result in
                    switch result {
                    case .success:
                        print("Login Successful")
                        self.loginButton.hideLoading()
                        DispatchQueue.main.async {
                            self.router.perform(.login, from: self)
                        }
                    case .failure:
                        self.loginButton.hideLoading()
                        print("Login failed")
                    }
                }
            case false:
                //Show Error
                self.loginButton.hideLoading()
                print(message!)
            }
        }
    }
}

extension LoginViewController {
    @objc private func forgotPasswordLabelTapped() {
        // Handle "Forgot Password" action
        print("Forgot Password tapped")
        
        // Call your forgot password functionality here
        // Example: viewModel.forgotPassword()
        self.router.perform(.forgotPassword, from: self)
    }
}


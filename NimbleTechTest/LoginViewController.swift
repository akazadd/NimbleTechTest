//
//  LoginViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 2/11/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    private var viewModel = LoginViewModel()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUIActions()
    }

    private func configureUIActions() {
        loginButton.addTarget(self, action: #selector(onLoginButtonTap), for: .touchUpInside)
    }
    
    @objc func onLoginButtonTap() {
        self.view.endEditing(true)
        viewModel.validateInput(emailTextField.text, password: passwordTextField.text) { [weak self] (valid, message) in
            guard let self = self else { return }
            
            switch valid {
            case true:
                let loginRequestInfo = LoginRequestInfo(email: self.emailTextField.text!, password: self.passwordTextField.text!)
                self.viewModel.login(loginRequestInfo) { (result: Result<Bool, Error>) in
                    switch result {
                    case .success:
                        print("Login Successful")
                    case .failure:
                        print("Login failed")
                    }
                }
            case false:
                //Show Error
                print(message!)
            }
        }
    }
}


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
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUIActions()
        configureUI()
        registerForKeyboardNotifications()
    }
    
    private func configureUI() {
        [emailTextField,passwordTextField] .forEach { textfield in
			textfield?.setPlaceholderColor(.lightGray)
        }
        loginButton.layer.cornerRadius = 12.0
		emailTextField.layer.cornerRadius = 12.0
		passwordTextField.layer.cornerRadius = 12.0
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
                        self.showAlert(title: "Ooops!", message: "Login failed, please try again!", completionHandler: nil)
                    }
                }
            case false:
                //Show Error
                self.loginButton.hideLoading()
                self.showAlert(title: "Ooops!", message: "Invalid email, please try again!", completionHandler: nil)
            }
        }
    }
}

extension LoginViewController {
    @objc private func forgotPasswordLabelTapped() {
        // Handle "Forgot Password" action
        self.router.perform(.forgotPassword, from: self)
    }
}

//MARK: Keyboard Handler
extension LoginViewController {
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Handle keyboard notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let bottomInset = keyboardSize.height
            stackViewBottomConstraint.constant = bottomInset
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        stackViewBottomConstraint.constant = 260
    }
}


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
		
		// Set up ViewModel callbacks
		viewModel.onLoginSuccess = { [weak self] in
			guard let self = self else { return }
			self.loginButton.hideLoading()
			self.router.perform(.login, from: self)
		}
		
		viewModel.onLoginFailure = { [weak self] errorMessage in
			guard let self = self else { return }
			self.loginButton.hideLoading()
			self.showAlert(title: "Ooops!", message: errorMessage, completionHandler: nil)
		}
		
    }
    
    private func configureUI() {
        [emailTextField,passwordTextField] .forEach { textfield in
			textfield?.setPlaceholderColor(.lightGray)
			textfield?.delegate = self
        }
        loginButton.layer.cornerRadius = 12.0
		loginButton.titleLabel?.letterSpacing = -0.41
		
		emailTextField.addCornerRadius(cornerRadius: 12.0)
		emailTextField.font = UIFont(name: "NeuzeitSLTStd-Book", size: 17)?.withWeight(UIFont.Weight(rawValue: 400))
		emailTextField.letterSpacing = -0.41
		
		passwordTextField.addCornerRadius(cornerRadius: 12.0)
    }

    private func configureUIActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordLabelTapped))
                passwordTextField.forgotPasswordLabel.addGestureRecognizer(tapGesture)
        loginButton.addTarget(self, action: #selector(onLoginButtonTap), for: .touchUpInside)
    }
    
    @objc func onLoginButtonTap() {
        self.view.endEditing(true)
        loginButton.showLoading()
		
		viewModel.validateAndLogin(email: emailTextField.text, password: passwordTextField.text)
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

extension LoginViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}


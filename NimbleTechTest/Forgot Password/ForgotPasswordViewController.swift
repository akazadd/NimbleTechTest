//
//  ForgotPasswordViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 6/11/23.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButtn: LoadingButton!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    var viewModel: ForgotPasswordViewModel!
    var router: DefaultForgotPasswordRouter!
    
    static func instantiate() -> ForgotPasswordViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! ForgotPasswordViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()
        registerForKeyboardNotifications()
    }
    
    private func configureUI() {
        resetButtn.layer.cornerRadius = 12.0
		emailTextField.addCornerRadius(cornerRadius: 12.0)
        emailTextField.setPlaceholderColor(.lightGray)
		emailTextField.delegate = self
		emailTextField.font = UIFont(name: "NeuzeitSLTStd-Book", size: 17)?.withWeight(UIFont.Weight(rawValue: 400))
        
        resetButtn.addTarget(self, action: #selector(resetPasswordButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc
    func resetPasswordButtonTapped(_ sender: UIButton) {
        resetButtn.showLoading()
        guard let email = emailTextField.text, !email.isEmpty else {
            // Show error: Email field is empty
            self.showAlert(title: "Empty Email", message: "The email is empty, Provide an email please", completionHandler: nil)
            resetButtn.hideLoading()
            return
        }
        
        guard email.isValidEmail() else {
            // Show error: Invalid email format
            self.showAlert(title: "Invalid Email", message: "The mail is in invalid format, Please check!", completionHandler: nil)
            resetButtn.hideLoading()
            return
        }
        
        viewModel.forgotPassword(email: email) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    // Show success message to the user
                    self.resetButtn.hideLoading()
                    self.showAlert(title: "Check your email", message: message) {
                        self.router.perform(.login, from: self)
                    }
                    print("Success: \(message)")
                case .failure(let error):
                    self.resetButtn.hideLoading()
                    // Show error message to the user based on the APIError enum
                    self.showAlert(title: "Ooops!", message: "The query is unsuccssful, please try again!", completionHandler: nil)
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

//MARK: Keyboard Handler
extension ForgotPasswordViewController {
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

extension ForgotPasswordViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

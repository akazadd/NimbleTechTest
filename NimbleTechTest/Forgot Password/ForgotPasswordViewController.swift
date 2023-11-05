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
    }
    
    private func configureUI() {
        resetButtn.layer.cornerRadius = 12.0
        emailTextField.addBorder(withColor: .white, cornerRadius: 12, borderWidth: 0.2)
        emailTextField.setPlaceholderColor(.white)
        
        resetButtn.addTarget(self, action: #selector(resetPasswordButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc
    func resetPasswordButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            // Show error: Email field is empty
            self.showAlert(title: "Empty Email", message: "The email is empty, Provide an email please", completionHandler: nil)
            return
        }
        
        guard email.isValidEmail() else {
            // Show error: Invalid email format
            self.showAlert(title: "Invalid Email", message: "The mail is in invalid format, Please check!", completionHandler: nil)
            return
        }
        
        viewModel.forgotPassword(email: email) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    // Show success message to the user
                    self.showAlert(title: "Check your email", message: message) {
                        self.router.perform(.login, from: self)
                    }
                    print("Success: \(message)")
                case .failure(let error):
                    // Show error message to the user based on the APIError enum
                    self.showAlert(title: "Ooops!", message: "The query is unsuccssful, please try again!", completionHandler: nil)
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

}

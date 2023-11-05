//
//  PasswordTextField.swift
//  NimbleTechTest
//
//  Created by A K Azad on 6/11/23.
//

import UIKit

class PasswordTextField: UITextField {
    var forgotPasswordLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isSecureTextEntry = true
        
        // Forgot Password label
        forgotPasswordLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: frame.height))
        forgotPasswordLabel.text = "Forgot?  "
        forgotPasswordLabel.textColor = .white
        forgotPasswordLabel.textAlignment = .center
        forgotPasswordLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
        
        rightView = forgotPasswordLabel
        rightViewMode = .always
        
        // Set placeholder text color to white
        attributedPlaceholder = NSAttributedString(string: "Password",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    @objc private func forgotPasswordTapped() {
        // Handle "Forgot Password" action
        print("Forgot Password tapped")
    }
}

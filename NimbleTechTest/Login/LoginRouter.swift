//
//  LoginRouter.swift
//  NimbleTechTest
//
//  Created by A K Azad on 4/11/23.
//

import UIKit

enum LoginSegue {
    case login
    case forgotPassword
    case signUp
}

protocol LoginRouter {
    func perform(_ segue: LoginSegue, from source: LoginViewController)
}

class DefaultLoginRouter: LoginRouter {
    
    func perform(_ segue: LoginSegue, from source: LoginViewController) {
        switch segue {
        case .login:
            UIApplication.shared.keyWindow?.rootViewController = DefaultLoginRouter.makeHomeViewController()
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        case .forgotPassword:
            print("forgotPassword")
        case .signUp:
            print("signup")
        }
    }
}

// MARK: Helpers

private extension DefaultLoginRouter {
    
    static func makeHomeViewController() -> UIViewController {
        let vc = HomeViewController.instantiate()
        vc.viewModel = HomeViewModel()
        vc.router = DefaultHomeRouter()
        return vc
    }
}

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
//            UIApplication.shared.keyWindow?.rootViewController = DefaultLoginRouter.makeHomeViewController()
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            let vc = DefaultLoginRouter.makeHomeViewController()
//            source.navigationController.setro
            UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: vc)
            UIApplication.shared.windows.first?.makeKeyAndVisible()
//            source.navigationController = UINavigationController(rootViewController: vc)
        case .forgotPassword:
            let vc = DefaultLoginRouter.makeForgotPasswordViewController()
            source.navigationController?.pushViewController(vc, animated: true)
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
    
    static func makeForgotPasswordViewController() -> UIViewController {
        let vc = ForgotPasswordViewController.instantiate()
        vc.viewModel = ForgotPasswordViewModel()
        vc.router = DefaultForgotPasswordRouter() 
        return vc
    }
}

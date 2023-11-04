//
//  Launcher.swift
//  NimbleTechTest
//
//  Created by A K Azad on 4/11/23.
//

import UIKit

class Launcher {
    
    static func launch(with window: UIWindow?) {
        if let nc = window?.rootViewController as? UINavigationController,
            let loginVC = nc.viewControllers.first as? LoginViewController {
            let viewModel = LoginViewModel()
            loginVC.viewModel = viewModel
            loginVC.router = DefaultLoginRouter()
        }
    }
}

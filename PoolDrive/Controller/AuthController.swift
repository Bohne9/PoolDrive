//
//  SignInViewController.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 08.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class AuthController: UIViewController {
    
    
    private var signInCardView: SignInCardView!
    private var signUpCardView: SignUpCardView!
    
    private var signInTopAnchorConstraint: NSLayoutConstraint!
    private var signUpTopAnchorConstraint: NSLayoutConstraint!
    private var signInBottomAnchorConstraint: NSLayoutConstraint!
    private var signUpBottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .antiFlashWhite
        
        setupUserInterface()
        
        AppDelegate.default.supportedInterfaceOrientations = .portrait
        // Do any additional setup after loading the view.
    }
    
    
    private func setupUserInterface(){
        setupSignInView()
        
        setupSignUpView()
        
        configureActions()
    }
    
    
    private func setupSignInView(){
        signInCardView = SignInCardView()
        
        view.addSubview(signInCardView)
        signInCardView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        signInTopAnchorConstraint = signInCardView.topAnchor.constraint(equalTo: safeArea.topAnchor)
        signInTopAnchorConstraint.isActive = true
        signInCardView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        signInCardView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        signInBottomAnchorConstraint = signInCardView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        signInBottomAnchorConstraint.isActive = true
    }
    
    
    private func setupSignUpView(){
        signUpCardView = SignUpCardView()
        print(view.frame)
        view.addSubview(signUpCardView)
        signUpCardView.translatesAutoresizingMaskIntoConstraints = false
        let offset = (self.view.frame.height / 3)
        signUpCardView.alpha = 0.0
        let safeArea = view.safeAreaLayoutGuide
        signUpTopAnchorConstraint = signUpCardView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: offset)
        signUpTopAnchorConstraint.isActive = true
        signUpCardView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        signUpCardView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        signUpBottomAnchorConstraint = signUpCardView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: offset)
        signUpBottomAnchorConstraint.isActive = true
    }
    
    private func configureActions(){
        signInCardView.signUpButton.addTarget(self, action: #selector(showSignUpView), for: .touchUpInside)
        
        signUpCardView.signInButton.addTarget(self, action: #selector(showSignInView), for: .touchUpInside)
        
    }
    
    
    /// Animates and shows the signIn user interface.
    /// Animation duration: 0.2s
    @objc func showSignUpView(){
        
        UIView.animate(withDuration: 0.2) {
            self.signInCardView.alpha = 0.0
            self.signUpCardView.alpha = 1.0
            
            self.signInTopAnchorConstraint.constant = -(self.view.frame.height / 3)
            self.signUpTopAnchorConstraint.constant = 0
            self.signInBottomAnchorConstraint.constant = -(self.view.frame.height / 3)
            self.signUpBottomAnchorConstraint.constant = 0
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// Animates and shows the registration user interface
    /// Animation duration: 0.2s
    @objc func showSignInView(){
        
        UIView.animate(withDuration: 0.2) {
            self.signInCardView.alpha = 1.0
            self.signUpCardView.alpha = 0.0
            
            self.signInTopAnchorConstraint.constant = 0
            self.signUpTopAnchorConstraint.constant = (self.view.frame.height / 3)
            self.signInBottomAnchorConstraint.constant = 0
            self.signUpBottomAnchorConstraint.constant = (self.view.frame.height / 3)
            
            self.view.layoutIfNeeded()
        }
    }
    
}

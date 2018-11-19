//
//  SignUpCardView.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 10.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpCardView: UIView {

    private var titleLabel: UILabel!
    private var errorLabel: UILabel!
    
    private var usernameTextField: AuthTextField!
    private var passwordTextField: AuthTextField!
    private var passwordConfimTextField: AuthTextField!
    
    var signInButton: UIButton!
    var signUpButton: AuthButton!
    
    private var email: String? {
        return usernameTextField.text
    }
    
    private var password: String? {
        return passwordTextField.text
    }
    
    init() {
        super.init(frame: .zero)
        
        setupShadow()
        
        setupUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupShadow()
        
    }
    
    
    private func setupShadow(){
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 20
    }
    
    
    private func setupUserInterface(){
        
        setupTitleLabel()
        
        usernameTextField = AuthTextField()
        passwordTextField = AuthTextField()
        passwordConfimTextField = AuthTextField()
        
        usernameTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        passwordConfimTextField.placeholder = "Confirm password"
        
        passwordTextField.isSecureTextEntry = true
        passwordConfimTextField.isSecureTextEntry = true
        
        addSubview(usernameTextField)
        addSubview(passwordTextField)
        addSubview(passwordConfimTextField)
        
        usernameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        passwordConfimTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        
        usernameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        passwordConfimTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        usernameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordConfimTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        usernameTextField.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -75).isActive = true
        passwordTextField.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        passwordConfimTextField.topAnchor.constraint(equalTo: centerYAnchor, constant: 25).isActive = true
        
        setupSignUpButton()
        
        setupSignInButton()
    }
    
    private func setupSignUpButton(){
        signUpButton = AuthButton()
        
        signUpButton.setTitle("SIGN UP", for: .normal)
        
        
        addSubview(signUpButton)
        
        let font = UIFont.sourceSansProBold(of: 13)
        
        signUpButton.titleLabel?.font = font
        
        signUpButton.setTitleColor(.antiFlashWhite, for: .normal)
        signUpButton.setTitleColor(UIColor.antiFlashWhite.withAlphaComponent(0.5), for: .highlighted)
        
        signUpButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 100).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        signUpButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        signUpButton.setBackgroundGradient()
    }
    
    private func setupTitleLabel(){
        titleLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        titleLabel.textAlignment = .center
        
        titleLabel.font = UIFont.sourceSansProBold(of: 40)
        titleLabel.text = "Sign Up"
        titleLabel.textColor = .blueYonder
        
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 75).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 5
        titleLabel.layer.shadowOpacity = 0.1
        
    }
    
    @objc func signIn(){
        guard let email = email, let password = password else {
            print("No email or password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                print("Error while signing in user: \(error!.localizedDescription)")
                return
            }
            print("Succesfully signed in user: \(result.user)")
        }
    }
    
    
    private func setupSignInButton(){
        signInButton = UIButton(type: .system)
        signInButton.setTitle("Already have an account?", for: .normal)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        let font = UIFont.sourceSansProBold(of: 16)
        
        signInButton.titleLabel?.font = font
        
        signInButton.setTitleColor(.blueYonder, for: .normal)
        
        addSubview(signInButton)
        
        signInButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signInButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        
        signInButton.layer.shadowRadius = 5
        signInButton.layer.shadowOpacity = 0.2
        signInButton.layer.shadowColor = UIColor.darkGray.cgColor
        
    }
    
    
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 15.0
    private var fillColor: UIColor = .white // the color applied to the shadowLayer, rather than the view's backgroundColor
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        if shadowLayer == nil {
//            shadowLayer = CAShapeLayer()
//            
//            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
//            shadowLayer.fillColor = fillColor.cgColor
//            
//            shadowLayer.shadowColor = UIColor.darkGray.cgColor
//            shadowLayer.shadowPath = shadowLayer.path
//            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//            shadowLayer.shadowOpacity = 0.2
//            shadowLayer.shadowRadius = 10
//            
//            layer.insertSublayer(shadowLayer, at: 0)
//            
//        }else {
//            shadowLayer.frame = bounds
//        }
//    }
    
    
}


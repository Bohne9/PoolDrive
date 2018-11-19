//
//  SignInCardView.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 08.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//
import FirebaseAuth
import UIKit

class SignInCardView: UIView {

    private var titleLabel: UILabel!
    private var errorLabel: UILabel!
    
    private var usernameTextField: AuthTextField!
    private var passwordTextField: AuthTextField!
    
    var signUpButton: UIButton!
    var signInButton: AuthButton!
    
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
        
        usernameTextField.placeholder = "username or email"
        passwordTextField.placeholder = "Password"
        
        passwordTextField.isSecureTextEntry = true
        
        addSubview(usernameTextField)
        addSubview(passwordTextField)
        
        usernameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        
        usernameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        
        usernameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        usernameTextField.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -75).isActive = true
        passwordTextField.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        
        setupSignInButton()
        
        setupSignUpButton()
    }
    
    private func setupSignInButton(){
        signInButton = AuthButton()
        
        signInButton.setTitle("SIGN IN", for: .normal)
        
        
        addSubview(signInButton)
        
        let font = UIFont.sourceSansProBold(of: 13)
        
        signInButton.titleLabel?.font = font
        
        signInButton.setTitleColor(.antiFlashWhite, for: .normal)
        signInButton.setTitleColor(UIColor.antiFlashWhite.withAlphaComponent(0.5), for: .highlighted)
        
        signInButton.topAnchor.constraint(equalTo: centerYAnchor, constant: 25).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        signInButton.setBackgroundGradient()
    }
    
    private func setupTitleLabel(){
        titleLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        titleLabel.textAlignment = .center
        
        titleLabel.font = UIFont.sourceSansProBold(of: 40)
        titleLabel.text = "Sign In"
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
    
    
    private func setupSignUpButton(){
        signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        let font = UIFont.sourceSansProBold(of: 16)
        
        signUpButton.titleLabel?.font = font
        
        signUpButton.setTitleColor(.blueYonder, for: .normal)
    
        addSubview(signUpButton)
        
        signUpButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signUpButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        
        signUpButton.layer.shadowRadius = 5
        signUpButton.layer.shadowOpacity = 0.2
        signUpButton.layer.shadowColor = UIColor.darkGray.cgColor
        
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
//            shadowLayer.shadowColor = UIColor.black.cgColor
//            shadowLayer.shadowPath = shadowLayer.path
//            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//            shadowLayer.shadowOpacity = 0.1
//            shadowLayer.shadowRadius = 10
//
//            layer.insertSublayer(shadowLayer, at: 0)
//
//        }else {
//            shadowLayer.frame = bounds
//        }
//    }
    
    
}

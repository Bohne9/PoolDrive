//
//  SignInTextField.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 08.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class AuthTextField: UITextField {

    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 15.0
    private var fillColor: UIColor = .white // the color applied to the shadowLayer, rather than the view's backgroundColor
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = cornerRadius
        
        textColor = .blueYonder
        
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.sourceSansProBold(of: 18)
        
        
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.1
            shadowLayer.shadowRadius = 10
            
            layer.insertSublayer(shadowLayer, at: 0)
            
        }else {
            shadowLayer.frame = bounds
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awake \(bounds)")
        if shadowLayer != nil {
            shadowLayer.frame = bounds
        }
    }

}


extension AuthTextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}



extension AuthTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

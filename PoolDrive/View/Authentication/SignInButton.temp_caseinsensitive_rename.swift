//
//  SIgnInButton.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 08.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class SignInButton: UIButton {

    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 15.0
    private var fillColor: UIColor = .white
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    private func setBackgroundGradient(){
        
    }
    
    
    func setCornerRadius(radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 10
            
            layer.insertSublayer(shadowLayer, at: 0)
            
        }
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

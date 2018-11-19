//
//  SIgnInButton.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 08.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 15.0
    private var fillColor: UIColor = .white
    
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        backgroundColor = .clear
    }
    
    
    func setBackgroundGradient(){
        
        let colorLeft = UIColor.blueYonder.cgColor
        let colorRight = UIColor.dazzledBlue.cgColor
        
        let gl = CAGradientLayer()
        gl.colors = [colorLeft, colorRight]
        gl.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        gl.locations = [0.0, 1.0]
        
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        
        gl.backgroundColor = UIColor.white.cgColor
        
        layer.insertSublayer(gl, at: 0)
        
    }
    
    
    func setCornerRadius(radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 150, height: 40), cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.1
            shadowLayer.shadowRadius = 10
            
            layer.insertSublayer(shadowLayer, at: 0)
            
        }
    }

    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

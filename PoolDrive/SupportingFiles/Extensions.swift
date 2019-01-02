//
//  Extensions.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 08.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func exo2Bold(of size: CGFloat) -> UIFont {
        return UIFont(name: "Exo2-Bold", size: size)!
    }
    
    static func sourceSansProBold(of size: CGFloat) -> UIFont {
        return UIFont(name: "SourceSansPro-Bold", size: size)!
    }
    
}

extension UIColor {
    static let blueYonder = UIColor(red:0.33, green:0.48, blue:0.65, alpha:1.0)
    
    static let dazzledBlue = UIColor(red:0.20, green:0.36, blue:0.51, alpha:1.0)
    
    static let antiFlashWhite = UIColor(red:0.94, green:0.96, blue:0.99, alpha:1.0)
}


extension UIView {
    
    func fillSuperview(){
        guard let view = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    
}




//
//  PoolNavigationBar.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 10.12.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class PoolNavigationBar: UINavigationBar {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 200))
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

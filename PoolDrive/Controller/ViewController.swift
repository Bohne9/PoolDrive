//
//  ViewController.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 02.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import FirebaseFunctions


class ViewController: UINavigationController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !DataManager.default.isLoggedIn {
            performSegue(withIdentifier: "signIn", sender: self)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.antiFlashWhite
        
    }
    
}


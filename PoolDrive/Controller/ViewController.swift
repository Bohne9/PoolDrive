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
            print("not logged in")
            performSegue(withIdentifier: "signIn", sender: self)
        }else {
            DataManager.default.getRootPoolsFromFirestore { (error) in
                DataManager.default.processInfo("Got Root Pools")
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
       
        view.backgroundColor = UIColor.antiFlashWhite
        
    }
    
    
    
    private func writePoolToFirestore(){
        var data: [String : Any] = [Pool.POOLNAME : "Programming"]
        DataManager.default.writeUserIdAndTimestamp(&data)
        
        let pool = Pool(data)
        
        pool.hasChanged = true
        print(pool)
        pool.pushToFirestore { (error) in
            if error != nil {
                DataManager.default.processError(error!)
            }else {
                DataManager.default.processInfo("Succesfully pushed a pool to firestore")
            }
        }
        
    }
    
}


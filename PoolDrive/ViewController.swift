//
//  ViewController.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 02.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import FirebaseFunctions


class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func onSubmit(_ sender: Any) {
        let functions = Functions.functions()
        print("onSubmit")
        functions.httpsCallable("addMessage").call(["text": textField.text]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("Ups there was an error: \(message)")
                }
                // ...
            }
//            if let text = (result?.data as? [String: Any])?["text"] as? String {
//                self.resultField.text = text
//            }
        }
        
    }
    

}


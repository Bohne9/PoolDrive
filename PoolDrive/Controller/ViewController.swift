//
//  ViewController.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 02.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import FirebaseFunctions


class ViewController: UINavigationController, UIImagePickerControllerDelegate {

    private lazy var poolController: PoolCollectionViewController = PoolCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        self.pushViewController(poolController, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !DataManager.default.isLoggedIn {
            print("not logged in")
            pushViewController(AuthController(), animated: true)
            //            performSegue(withIdentifier: "signIn", sender: self)
        }
//        }else {
//            DataManager.default.getRootPoolsFromFirestore { (error) in
//                DataManager.default.processInfo("Got Root Pools")
//                let pool = DataManager.default.rootPools.first!
//
//                pool.getPoolContent({ (error) in
//                    guard error == nil else {
//                        DataManager.default.processError(error!)
//                        return
//                    }
//                }, {
//                    print("File count: \(pool.files.count) \n \(pool.files.first!)")
//                    print("Comments: \(pool.comments.count)")
//
//                    self.poolController.pool = pool
//                    pool.getByOldest()
//                    self.poolController.collectionView.reloadData()
//                })
//            }
//        }
        

        setupNavigationBar()
        
        view.backgroundColor = UIColor.white
        
    }
    
    
    
    
    private func setupNavigationBar(){
        navigationBar.tintColor = .black
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        navigationBar.shadowImage = UIImage()
    }
    
    
    
    
//    func writeDataToPool(_ pool: Pool) {
//        var fileData: [String : Any] = ["fileName": "MyImage.jpg",
//                                    "storageUrl" : "some-url"]
//        DataManager.default.writeUserIdAndTimestamp(&fileData)
//
//        let file = PoolFile(fileData)
//        pool.addFile(file)
//
//        var commentData: [String : Any] = ["comment": "my comment"]
//        DataManager.default.writeUserIdAndTimestamp(&commentData)
//
//        let comment = PoolComment(commentData)
//
//        pool.addComment(comment)
//
//        var urlData: [String : Any] = ["url": "some-url"]
//        DataManager.default.writeUserIdAndTimestamp(&urlData)
//
//        let url = PoolURL(urlData)
//        pool.addUrl(url)
//
//        pool.pushToFirestore { (error) in
//            guard error == nil else {
//                DataManager.default.processError(error!)
//                return
//            }
//            print("Succesfully pushed something to firestore")
//        }
//    }
//
//    private func writePoolToFirestore() -> Pool{
//        var data: [String : Any] = [Pool.POOLNAME : "Programming"]
//        DataManager.default.writeUserIdAndTimestamp(&data)
//
//        let pool = Pool(data)
//
//        pool.hasChanged = true
//        print(pool)
//        pool.pushToFirestore { (error) in
//            if error != nil {
//                DataManager.default.processError(error!)
//            }else {
//                DataManager.default.processInfo("Succesfully pushed a pool to firestore")
//            }
//        }
//
//        return pool
//    }
    
}


extension ViewController: DataManagerDelegate {
    
    func dataManager(_ recievedRootPools: [Pool]) {
        print("fenwjio")
        guard let pool = recievedRootPools.first else{
            DataManager.default.processWarning("Recieved root pools. No pools available!")
            return
        }
        pool.getPoolContent(nil) {
            self.poolController.pool = pool
            self.poolController.collectionView.reloadData()
        }
        DataManager.default.processInfo("Recieved root pools.")
    }
    
}

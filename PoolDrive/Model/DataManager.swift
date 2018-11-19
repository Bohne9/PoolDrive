//
//  DataManager.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 14.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class DataManager {
    
    static var `default`: DataManager!
    
    static func initDataManager(){
        if DataManager.default == nil {
            DataManager.default = DataManager()
        }
    }
    
    private init() {
        print("DataManager initalised...")
        
        firestore = Firestore.firestore()
        storage = Storage.storage()
    }
    
    // Default max. storage download size of 50MB
    var maxStorageDownloadSize: Int64 = 50 * 1024 * 1024
    
    var userID: String {
        return auth.currentUser!.uid
    }
    
    var auth: Auth{
        return Auth.auth()
    }
    
    var isLoggedIn: Bool{
        return auth.currentUser == nil
    }
    
    var firestore: Firestore!
    var storage: Storage!
    
    func collection(path: String) -> CollectionReference{
        return firestore.collection(path)
    }
    
    func document(path: String) -> DocumentReference{
        return firestore.document(path)
    }
    
    func storageReference(for path: String) -> StorageReference {
        return storage.reference(withPath: path)
    }
    
    func storageReference(for url: URL) -> StorageReference {
        return storage.reference(forURL: url.absoluteString)
    }
    
    func storageDownload(path: String, completion: @escaping ((Data?, Error?) -> Void)) -> StorageReference {
        let storageReference = self.storageReference(for: path)
        storageReference.getData(maxSize: maxStorageDownloadSize, completion: completion)
        return storageReference
    }
    
    
    
}

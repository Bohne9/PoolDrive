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
    
    var delegate: DataManagerDelegate?
    
    private init() {
        print("DataManager initalised...")
        
        firestore = Firestore.firestore()
        storage = Storage.storage()
        
        configureFirestore()
    }
    
    private func configureFirestore(){
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // Default max. storage download size of 50MB
    var maxStorageDownloadSize: Int64 = 50 * 1024 * 1024
    
    var userID: String? {
        return auth.currentUser?.uid
    }
    
    var userPoolDir: String? {
        guard let userID = self.userID else {
            return nil
        }
        return "pools/\(userID)/pools"
    }
    
    var rootPools: [Pool] = []
    
    var auth: Auth{
        return Auth.auth()
    }
    
    var isLoggedIn: Bool{
        return auth.currentUser != nil
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
    
    func storageDownload(path: String, to url: URL, completion: @escaping ((URL?, Error?) -> Void)) -> StorageDownloadTask {
        let storageReference = self.storageReference(for: path)
        return storageReference.write(toFile: url, completion: completion)
    }
    
    func storageDownloadMetadata(path: String, completion: @escaping ((StorageMetadata?, Error?) -> Void)) -> StorageReference {
        let storageReference = self.storageReference(for: path)
        storageReference.getMetadata(completion: completion)
        return storageReference
    }
    
    
    /// Downloads the 'root'-pools of the user (in case he is logged in)
    /// 'root'-pools := /pools/{userID}/pools/...
    /// - Parameter completion: Callback for UI-update and error handling
    func getRootPoolsFromFirestore(_ completion: @escaping ((Error?) -> Void)){
        guard let path = userPoolDir  else {
            return
        }
        // Reference to the root pool collection
        let collection = self.collection(path: path)
        // Get the documents
        collection.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            let documentChanges = snapshot.documentChanges
            
            for documentChange in documentChanges {
                let document = documentChange.document
                let pool = Pool(document.data())
                pool.documentId = document.documentID
                self.rootPools.append(pool)
                DataManager.default.processInfo("Pool: \(pool)")
            }
            
            completion(error)
            
            self.delegate?.dataManager(self.rootPools)
        }
    }
    
    
    func writeUserIdAndTimestamp(_ timestamp: Timestamp, _ data: inout [String : Any]){
        data[NoSQLConstants.USERID.rawValue] = userID
        data[NoSQLConstants.TIMESTAMP.rawValue] = timestamp
    }
    
    func writeUserIdAndTimestamp(_ data: inout [String : Any]){
        writeUserIdAndTimestamp(Timestamp(date: Date()), &data)
    }
}

// Error handling
extension DataManager {
    func processError(_ error: Error, _ info: String = "") {
        print("[ERROR] - \(error.localizedDescription)")
        if info != "" {
            print("\t[INFO] - \(info)")
        }
    }
    
    func processInfo(_ info: String) {
        print("[INFO] - \(info)")
    }
    
    func processWarning(_ warning: String) {
        print("[WARNING] - \(warning)")
    }
}


extension DataManager {
    
    
    func writeToTemporaryFile(_ url: URL, _ completion: @escaping (URL) -> Void){
        
        let urlString = url.absoluteString
        
        DispatchQueue.global(qos: .default).async(execute: {
            //All stuff here
            
            let url=NSURL(string: urlString);
            let urlData=NSData(contentsOf: url! as URL);
            
            if((urlData) != nil)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                
                let fileName = urlString as NSString;
                
                let filePath="\(documentsPath)/\(fileName.lastPathComponent)";
                
                let fileExists = FileManager().fileExists(atPath: filePath)
                
                if(fileExists){
                    
                    // File is already downloaded
                    completion(URL(fileURLWithPath: filePath))
                }
                else{
                    
                    //download
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        print(filePath)
                        urlData?.write(toFile: filePath, atomically: true);
                        completion(URL(fileURLWithPath: filePath))
                    })
                }
            }
        })
    }
    
    
}


protocol DataManagerDelegate {
    func dataManager(_ recievedRootPools: [Pool])
}
extension DataManagerDelegate {
    func dataManager(_ recievedRootPools: [Pool]) {
        
    }
}

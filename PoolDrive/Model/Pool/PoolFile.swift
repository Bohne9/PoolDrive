//
//  PoolFile.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 14.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import QuickLook

class PoolFile: PoolNode {
//    var previewItemURL: URL?{
//        return
//    }
    
    
    public static let POOLFILE_COLLECTION_NAME = "files"
    public static let FILENAME = "fileName"
    public static let STORAGEURL = "storageUrl"
    public static let LOCALURL = "localUrl"
    
    override var firestoreCollectionName: String{
        return PoolFile.POOLFILE_COLLECTION_NAME
    }
    
    var storageUrl: String? {
        didSet{ hasChanged = true }
    }
    
    var localUrl: URL? {
        didSet { hasChanged = true }
    }
    
    var fileName: String? {
        didSet{ hasChanged = true }
    }
    
    override var title: String{
        get{
            return fileName ?? "file"
        }
        set{
            hasChanged = true
            fileName = newValue
        }
    }
    
    // File data
    var data: Data?{
        didSet{
            hasChanged = true
            meta = StorageMetadata()
        }
    }
    
    var fileDelegate: FileNodeDelegate? {
        didSet{
            delegate = fileDelegate
        }
    }
    
    private(set) var downloadURL: URL?
    
    var size: Int64 {
        return meta?.size ?? -1
    }
    
    var contentType: String? {
        get {
            return meta?.contentType
        }
        set {
            meta?.contentType = newValue
        }
    }
    
    var meta: StorageMetadata?
    
    
    fileprivate func downloadMetadata(_ storageUrl: String, _ completion: @escaping ((Error?) -> Void)) {
        // Download the metadata from the server
        _ = DataManager.default.storageDownloadMetadata(path: storageUrl, completion: { (metadata, error) in
            guard error == nil else {
                completion(error)
                self.fileDelegate?.node(self, didRecievedFileMetatdataError: error!)
                return
            }
            self.meta = metadata
            
            self.fileDelegate?.node(self, didRecievedFileMetadata: metadata!)
            completion(nil)
        })
    }
    
    
    /// The method downloads the file data for a PoolFile.
    /// Content that is downloaded:
    ///     - File content
    ///     - File metadata
    ///     - File donwload url
    /// - Parameter completion:
    /// - Returns: Returns the Storage Referenze. Can be used for donwload process handling and so on.
    func downloadDataFromStorage(_ completion: @escaping ((Error?) -> Void)) -> StorageReference? {
        guard let storageUrl = self.storageUrl else {
            return nil
        }
        
        DataManager.default.processInfo("Downloading file... url: \(storageUrl)")
        
        // Download the data from the server
        let storageRef = DataManager.default.storageDownload(path: storageUrl) { (data, error) in
            guard let data = data else {
                completion(error)
                self.fileDelegate?.node(self, didRecievedFileContentError: error!)
                return
            }
            self.data = data
            
            self.fileDelegate?.node(self, didRecievedFileContent: data)
            completion(nil)
        }
        
        // Fetch the metadata
        downloadMetadata(storageUrl, completion)
        
        return storageRef
    }
    
    
    /// The method downloads the file data for a PoolFile.
    /// Content that is downloaded:
    ///     - File content
    ///     - File metadata
    ///     - File donwload url
    /// - Parameter completion:
    /// - Returns: Returns the Storage Referenze. Can be used for donwload process handling and so on.
    func downloadDataFromStorageToLocalFile(_ completion: @escaping ((Error?) -> Void)) -> StorageDownloadTask? {
        // In case the poolFile has a localUrl
        guard localUrl == nil else {
            completion(nil)
            print("There is a local URL")
            return nil
        }
        
        // Make sure the poolFile has a storageURL
        guard let storageUrl = self.storageUrl else {
            completion(NoFirestorePathError())
            print("There is no storage URL")
            return nil
        }
        
        DataManager.default.processInfo("Downloading file... url: \(storageUrl)")
        
        guard let localURL = createLocalUrl() else {
            completion(NoFirestorePathError())
            return nil
        }
        
        self.localUrl = localURL
        pushToFirestore(nil)
        print(self.firestoreData)
        
        // Download the data from the server
        let downloadTask = DataManager.default.storageDownload(path: storageUrl, to: localURL) { (url, error) in
            guard url != nil else {
                completion(error)
                self.fileDelegate?.node(self, didRecievedFileContentError: error!)
                return
            }
            
//            DataManager.default.processInfo("URL argument: \(url)")
        }
        
        // Observe the download task until the download process is finished.
        downloadTask.observe(.success) { (snapshot) in
            self.data = self.loadCachedData()
            self.fileDelegate?.node(self, didRecievedFileContent: self.data!)
            completion(nil)
        }
        
        downloadMetadata(storageUrl, completion)
        
        return downloadTask
    }
    
    
    override func writeToSource() {
        super.writeToSource()
        firestoreData[PoolFile.FILENAME] = fileName
        firestoreData[PoolFile.STORAGEURL] = storageUrl
    }
    
    
    
    override func loadFromSource() {
        super.loadFromSource()
        fileName = getString(key: PoolFile.FILENAME)
        storageUrl = getString(key: PoolFile.STORAGEURL)
        
        // Get the local url from the firestore document
        pullLocalUrlFromFirestore { (localURL, error) in
            guard let localURL = localURL else {
                DataManager.default.processError(error!)
                return
            }
            self.getLocalUrlFrom(localURL)
        }
        
        hasChanged = false

    }
    
    /// Pushes the data of the PoolFile to Firestore (in case the data has changed).
    /// This method also pushes the file data to Firebase Storage
    /// - Parameter completion: Completion handler for handling errors and other updated.
    override func pushToFirestore(_ completion: ((Error?) -> Void)?) {
        guard let data = self.data else {
            super.pushToFirestore(completion)
            pushLocalUrlToFirestore()
            return
        }
        
        super.pushToFirestore { (error) in
            guard let firestorePath = self.firestorePath() else {
                completion?(NoFirestorePathError())
                return
            }
            
            self.storageUrl = firestorePath + "/\(self.fileName ?? "")"
            print("fjfiwej")
            let storage = DataManager.default.storageReference(for: self.storageUrl!)
            storage.putData(data, metadata: self.meta)
            
            super.pushToFirestore({ (error) in
                self.fileDelegate?.node(self, didPushDataToFirestore: error)
                completion?(error)
            })
        }
        pushLocalUrlToFirestore()
    }
    
    /// In case a PoolFile has stored the data on the device. This Method will push the localURL
    /// to Firestore.
    private func pushLocalUrlToFirestore() {
        guard let path = localUrlFirestorePath(), localUrl != nil else {
            print("Trying to push local url to firestore ")
            return
        }
        DataManager.default.processInfo("Pushing localURL to firestore")
        let data = [PoolFile.LOCALURL: createLocalPath(self)]
        
        DataManager.default.document(path: path).setData(data) { (error) in
            guard let error = error else {
                return
            }
            
        }
    }
    
    
    
    /// The method will pull the localURL for a PoolFile
    ///
    /// - Parameter completion: Completion handler for handling errors and other things
    private func pullLocalUrlFromFirestore(_ completion: (String?, Error?) -> Void) {
        guard let localUrlPath = localUrlFirestorePath() else {
            DataManager.default.processWarning("Trying to pull the local url from firestore failed.")
            return
        }
        DataManager.default.processInfo("Pulling a lcoalURL")
        
        DataManager.default.document(path: localUrlPath).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                DataManager.default.processError(error!)
                return
            }
            
            if let path = snapshot.data()?[PoolFile.LOCALURL] as? String {
                self.getLocalUrlFrom(path)
            }
        }
    }
    
    
    /// Creates an localURL object of type URL. The URL will point to a file in the cache directory on the device
    ///
    /// - Parameter path: The path relative to the cache directory. This path should come from Firestore
    private func getLocalUrlFrom(_ path: String) {
        if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            localUrl = URL(fileURLWithPath: url.path + "/" + path)
        }
    }
    
    
    /// Creates a path for the localURL to store this in Firestore
    /// The path will look like this. pools/..../files/{this poolfile}/localPaths/{deviceUUID}/{someDocumentID}/{theLocalURL}
    private func localUrlFirestorePath() -> String? {
        guard let deviceID = UIDevice().identifierForVendor?.uuidString, let firestorePath = self.firestorePath() else {
            DataManager.default.processWarning("Trying to create a localURLFirestorePath.. failed!")
            print(self.firestorePath())
            return nil
        }
        return firestorePath + "/localPaths/" + deviceID
    }
    
    override class func instantiateType(_ documentID: String, _  data: [String : Any]) -> PoolNode {
        return PoolFile(data, documentId: documentID)
    }
}



extension PoolFile {
    
    // Methods for handling the localData flow
    
    
    /// - Returns: If a localUrl exists the content of the file will be returned
    private func getLocalData() -> Data? {
        guard let localUrlExists = self.localUrlExists() else {
            // There is no local url -> nothing to load
            return nil
        }
        
        // The localUrl that comes from firestore does not exist
        //    -> Delete this data-point at firestore
        if !localUrlExists {
            self.localUrl = nil
            pushToFirestore(nil)
            
            return nil
        }
        
        // Everything is fine. LocalUrl that comes from Firestore exists on the local device
        //   -> load the data from the device.
        return loadCachedData()
    }
    
    /// Loads the data from a file stored on the users device.
    /// - Returns: Returns the data that comes form the localURL stored at Firestore
    private func loadCachedData() -> Data? {
        guard let localUrl = localUrl else {
            print("Loading local data failed")
            return nil
        }
        return try? Data(contentsOf: localUrl)
    }
    
    /// This method checks if the localUrl exists or not
    ///
    /// - Returns: True if localUrl exists, False if localUrl is not nil but doesn't exist, nil if localUrl is nil
    private func localUrlExists() -> Bool? {
        guard let localURL = self.localUrl else {
            return nil
        }
        return FileManager.default.fileExists(atPath: localURL.absoluteString)
    }
    
    
    /// Writes the given data to the cache directory on the current device.
    /// The destination file is **localUrl**
    /// - Parameter data: Data that will be written to the device
    private func writeDataToLocalCache(_ data: Data) {
        guard let localURL = createLocalUrl() else {
            return
        }
        self.localUrl = localURL
        
        do{
            try data.write(to: localURL)
        }catch {
            self.localUrl = nil
        }
        
    }

    
    /// Creates a URL object which points to the device cache directory of the app
    ///
    /// - Returns: Returns the URL, nil if anything goes wrong
    private func createLocalUrl() -> URL? {
        let localPath = createLocalPath(self)
        
        let fileManager = FileManager.default

        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        
        guard var url = urls.first  else {
            return nil
        }
        url.appendPathComponent(localPath)
        
        DataManager.default.processInfo("LocalURL has been created: \(url.absoluteString)")
        return url
    }
    
    
    /// Creates a path containing the Pool hirachy and the files name
    /// Example: '/pool1/pool2/ExampleFile.pdf'
    private func createLocalPath(_ poolNode: PoolNode) -> String {
        if poolNode.parent == nil {
            if let pool = poolNode as? Pool {
                print("Pool filename: \(pool.poolName)")
                return pool.poolName ?? ""
            }
            return poolNode.title
        }
        print("Create local URL for: \(poolNode.title)")
        return createLocalPath(poolNode.parent!) + "/" + title
    }
    
}

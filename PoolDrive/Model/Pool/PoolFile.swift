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
    
    override var firestoreCollectionName: String{
        return PoolFile.POOLFILE_COLLECTION_NAME
    }
    
    var storageUrl: String?{
        didSet{ hasChanged = true }
    }
    
    var localUrl: URL?
    
    var fileName: String?{
        didSet{ hasChanged = true }
    }
    
    override var title: String{
        get{
            return fileName ?? ""
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
        return meta?.contentType
    }
    
    var meta: StorageMetadata?
    
    
    fileprivate func donwloadMetadataAndDownlaodURL(_ storageUrl: String, _ completion: @escaping ((Error?) -> Void), _ storageRef: StorageReference) {
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
        
        //     Download the download url for the file content
        storageRef.downloadURL { (url, error) in
            guard let url = url else {
                completion(error!)
                self.fileDelegate?.node(self, didRecievedDownloadUrlError: error!)
                return
            }
            
            self.downloadURL = url
            self.fileDelegate?.node(self, didRecievedDownloadUrl: url)
            completion(nil)
        }
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
        
        donwloadMetadataAndDownlaodURL(storageUrl, completion, storageRef)
        
        return storageRef
    }
    
    
    /// The method downloads the file data for a PoolFile.
    /// Content that is downloaded:
    ///     - File content
    ///     - File metadata
    ///     - File donwload url
    /// - Parameter completion:
    /// - Returns: Returns the Storage Referenze. Can be used for donwload process handling and so on.
    func downloadDataFromStorageToLocalFile(_ localURL: URL, _ completion: @escaping ((Error?) -> Void)) -> StorageReference? {
//        guard localURL == nil else {
//            completion(nil)
//            return nil
//        }
        
        guard let storageUrl = self.storageUrl else {
            completion(NoFirestorePathError())
            return nil
        }
        
        DataManager.default.processInfo("Downloading file... url: \(storageUrl)")
        
        // Download the data from the server
        let storageRef = DataManager.default.storageDownload(path: storageUrl, to: localURL) { (url, error) in
            guard let url = url else {
                completion(error)
                self.fileDelegate?.node(self, didRecievedFileContentError: error!)
                return
            }
            
            self.localUrl = localURL
            self.data = try? Data(contentsOf: self.localUrl!)
            self.fileDelegate?.node(self, didRecievedFileContent: self.data!)
            completion(nil)
        }
        
        donwloadMetadataAndDownlaodURL(storageUrl, completion, storageRef)
        
        return storageRef
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
        hasChanged = false
    }
    
    override func pushToFirestore(_ completion: ((Error?) -> Void)?) {
        guard let data = self.data else {
            super.pushToFirestore(completion)
            return
        }
        
        super.pushToFirestore { (error) in
            guard let firestorePath = self.firestorePath() else {
                completion?(NoFirestorePathError())
                return
            }
            
            self.storageUrl = firestorePath + "/\(self.fileName ?? "")"
            
            let storage = DataManager.default.storageReference(for: self.storageUrl!)
            storage.putData(data, metadata: self.meta)
            
            
            super.pushToFirestore({ (error) in
                self.fileDelegate?.node(self, didPushDataToFirestore: error)
                completion?(error)
            })
        }
        
    }

    override class func instantiateType(_ documentID: String, _ data: [String : Any]) -> PoolNode {
        return PoolFile(data, documentId: documentID)
    }
}

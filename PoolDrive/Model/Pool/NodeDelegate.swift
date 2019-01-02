//
//  NodeDelegate.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 31.12.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

protocol NodeDelegate {
    
    
    /// Called when a PoolNode pushed its data to Firestore
    /// - Parameters:
    ///   - node: PoolNode that pushed the data
    ///   - error: nil in case no error occured. Otherwise the error that occured
    func node(_ node: PoolNode, didPushDataToFirestore error: Error?)
    
    /// Called when a PoolNode recieved a snapshot update from Firestore
    ///
    /// - Parameters:
    ///   - node: PoolNode that recieved the update
    ///   - snapshot: DocumentSnapshot with the data
    func node(_ node: PoolNode, didRecievedSnapshotUpdate snapshot: DocumentSnapshot)
    
    
    /// Called when a PoolNode recieved a snapshot update from Firestore and an
    /// error occured
    /// - Parameters:
    ///   - node: PoolNode that recieved the update
    ///   - error: Error that occured
    func node(_ node: PoolNode, didRecievedSnapshotError error: Error)
    
    
    /// Called when a PoolNode did update its data
    ///
    /// - Parameters:
    ///   - node: PoolNode that updated its data
    ///   - didUpdateNodeData: new data
    func node(_ node: PoolNode, didUpdateNodeData: [String : Any])
    
    
}

extension NodeDelegate {
    
    func node(_ node: PoolNode, didPushDataToFirestore error: Error?){
        
    }
    
    func node(_ node: PoolNode, didRecievedSnapshotUpdate snapshot: DocumentSnapshot){
        
    }
    
    func node(_ node: PoolNode, didRecievedSnapshotError error: Error){
        
    }
    
    func node(_ node: PoolNode, didUpdateNodeData: [String : Any]){
        
    }

}




protocol FileNodeDelegate: NodeDelegate {
    

    
    /// Called when a PoolFile recieved the content of its file
    ///
    /// - Parameters:
    ///   - file: PoolFile that requested the fileContent
    ///   - data: Data for the content of **file**
    func node(_ file: PoolFile, didRecievedFileContent data: Data)

    
    /// Called when a PoolFile recieved an error while requesting the content of the file
    ///
    /// - Parameters:
    ///   - file: PoolFile that requested the file content
    ///   - error: Error that occured while requesting the file content
    func node(_ file: PoolFile, didRecievedFileContentError error: Error)
    

    /// Called when a PoolFile recieved the metadata for the file
    ///
    /// - Parameters:
    ///   - file: PoolFile that requested the metadata
    ///   - metadata: Metadata for the content of **file**
    func node(_ file: PoolFile, didRecievedFileMetadata metadata: StorageMetadata)
    
    
    /// Called when a PoolFile recieved an error while requesting the metadata for the file
    ///
    /// - Parameters:
    ///   - file: PoolFile that requested the metadata
    ///   - error: Error that occured during the request
    func node(_ file: PoolFile, didRecievedFileMetatdataError error: Error)
    

    
    /// Called when a PoolFile requested the download url
    ///
    /// - Parameters:
    ///   - file: PoolFile which requests the downloadURL
    ///   - url: DownloadURL for the content of the **file**
    func node(_ file: PoolFile, didRecievedDownloadUrl url: URL)

    
    /// Called when a PoolFile requested the download url for it's file and an
    /// error occured
    /// - Parameters:
    ///   - file: PoolFile which requests the downloadURL
    ///   - error: Error that occured during the request
    func node(_ file: PoolFile, didRecievedDownloadUrlError error: Error)
    
}

extension FileNodeDelegate {
    
    func node(_ file: PoolFile, didRecievedFileContent data: Data){
        
    }
    
    func node(_ file: PoolFile, didRecievedFileContentError error: Error){
        
    }
    
    func node(_ file: PoolFile, didRecievedFileMetadata metadata: StorageMetadata){
        
    }
    
    func node(_ file: PoolFile, didRecievedFileMetatdataError error: Error){
        
    }
    
    func node(_ file: PoolFile, didRecievedDownloadUrl url: URL){
        
    }
    
    func node(_ file: PoolFile, didRecievedDownloadUrlError error: Error){
        
    }
}

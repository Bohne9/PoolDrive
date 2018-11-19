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

class File {
    
    private var firestoreData: [String : Any] = [:]
    
    private let firestoreCollectionName = "pools"
    
    var documentId: String = ""
    
    var userId: String = ""
    
    var storageUrl: String = ""
    
    var fileName: String = ""
    
    var timestamp: Timestamp?
    
    // File data
    var data: Data?
    
    var meta: StorageMetadata?
    
    
    func downloadDocumentFromFirestore(){
        
    }
    
    func downloadDataFromStorage(){
        
    }

}

extension File: FirestoreExtension  {
    
    var collectionName: String {
        return firestoreCollectionName
    }
    
    func getSource() -> [String : Any] {
        return firestoreData
    }
    
}

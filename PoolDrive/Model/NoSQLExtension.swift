//
//  NoSQLExtension.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 16.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import FirebaseFirestore


enum NoSQLConstants: String {
    typealias RawValue = String
    
    case USERID = "userId"
    case ID = "id"
    case TIMESTAMP = "timestamp"
    case TITLE = "title"
}

protocol FirestoreExtension {
    
    var collectionName: String { get }
    
    func getSource() -> [String : Any]
    
    func writeToSource()
    
    func loadFromSource()
    
    func firestorePath() -> String?
    
}


extension FirestoreExtension {
    
    
    /// - Parameter key: Key for the key value dic
    /// - Returns: If the source dic. has the given key, it will be returned.
    /// Otherwise nil will be returned.
    func getString(key: String) -> String? {
        return getSource()[key] as? String
    }
    
    /// - Returns: Returns the value for the NoSQLConstans.TIMESTAMP key.
    ///     If TIMESTAMP has no value an empty string will be returned.
    ///
    func getTimestamp() -> Timestamp {
        return getSource()[NoSQLConstants.TIMESTAMP.rawValue] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
    }
    
    /// - Returns: Returns the value for the NoSQLConstans.USERID key.
    ///     If USERID has no value an empty string will be returned.
    func getUserId() -> String {
        return getString(key: NoSQLConstants.USERID.rawValue) ?? ""
    }
    
    func getTitle() -> String {
        return getString(key: NoSQLConstants.TITLE.rawValue) ?? ""
    }
    
    
    /// - Returns: Returns the value for the NoSQLConstans.ID key.
    ///     If ID has no value an empty string will be returned.
    func getId() -> String {
        return getString(key: NoSQLConstants.ID.rawValue) ?? ""
    }
    
    
    /// Writes the data stored in getSource() to Firestore
    /// Before pushing the data into the cloud writeToSource() is called
    /// - Parameter completion: Completion handler for error handling
    /// In case error == nil -> No error, successfully pushed data to
    /// Firestore
    func pushToFirestore(_ completion : ((Error?) -> Void)?){
        guard let firestorePath = self.firestorePath() else {
            return
        }
        writeToSource()
//        print("Pushing to path: \(firestorePath)")
//        print("Pushing following data to firestore: \(getSource())")
        let reference = DataManager.default.document(path: firestorePath)
        reference.setData(getSource(), completion: completion)
    }
    
    
    
}



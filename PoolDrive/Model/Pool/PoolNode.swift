//
//  PoolContent.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 21.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import FirebaseFirestore

class PoolNode: FirestoreExtension, CustomStringConvertible {
    
    var description: String{
        var str = "[DocumentID: \(documentId ?? "-")\n"
        for (key, value) in firestoreData {
            str += "\(key): \(value)\n"
        }
        str += "]\n"
        return str
    }
    
    var delegate: NodeDelegate?
    
    var collectionName: String{
        return firestoreCollectionName
    }
    
    private var documentSnapshotListener: ListenerRegistration?
    
    var snapshotListenerDelegate: SnapshotListenerDelegate?
    
    var hasChanged: Bool = false{
        didSet{
            parent?.hasChanged = hasChanged
        }
    }
    
    /// Pool in Firestore where PoolNode is stored
    var parent: Pool?{
        didSet{
            hasChanged = true
            loadFromSource()
        }
    }
    
    /// Firestore documentId
    var documentId: String?{
        didSet{
            hasChanged = true
            connectFirebaseSnapshotListerner()
        }
    }
    
    /// Firestore timestamp
    var timestamp: Timestamp?{
        didSet{ hasChanged = true }
    }
    
    var title: String {
        get {
            return "--"
        }
        set {
            
        }
    }
    
    var lastChange: Timestamp?{
        didSet{ hasChanged = true }
    }
    
    /// Id of the user who created the PoolNode
    var userId: String?{
        didSet{ hasChanged = true }
    }
    
    /// Describes the name of the collection where the poolNodes are stored
    internal var firestoreCollectionName: String {
        return ""
    }
    
    /// Stores the data that comes from Firestore
    internal var firestoreData: [String : Any] = [:] {
        didSet{
            delegate?.node(self, didUpdateNodeData: firestoreData)
        }
    }
    
    required init(_ data: [String : Any], documentId: String? = nil) {
        self.documentId = documentId
        firestoreData = data
        loadFromSource()
        hasChanged = false
    }
    
    /// - Returns: If a poolNode has a parent pool, it's path will we returned
    func parentFirestorePath() -> String? {
        return parent?.firestorePath()
    }
    
    func collectionFirestorePath() -> String? {
        guard let parentPath = parentFirestorePath() else {
            return nil
        }
        return parentPath + "/" + firestoreCollectionName
    }
    
    /// - Returns: The Dicionary where the values from Firestore are stored
    func getSource() -> [String : Any] {
        return firestoreData
    }
    
    /// Updates the values in getSource() to update them in Firestore
    func writeToSource() {
        firestoreData[NoSQLConstants.USERID.rawValue] = userId
        firestoreData[NoSQLConstants.TIMESTAMP.rawValue] = timestamp
        firestoreData[NoSQLConstants.TITLE.rawValue] = title
    }
    
    /// Loads the values stored in getSource() into the local
    /// variables of the PoolNode
    /// WARNING: When overriden in subclass: Call super method after making changes to the source
    /// Otherwise there will be problems with keeping the data in sync with the server
    func loadFromSource() {
        userId = getUserId()
        timestamp = getTimestamp()
        title = getTitle()
        hasChanged = false
    }
    
    /// - Returns: Path to the Firestore document,
    /// If parent or documentId is nil -> nil will be returned.
    func firestorePath() -> String? {
        guard let parentPath = parentFirestorePath(), let documentId = self.documentId else{
            return nil
        }
        return parentPath + "/" + firestoreCollectionName + "/" + documentId
    }
    
    
    func getFirestoreReference() -> DocumentReference? {
        guard let firestorePath = self.firestorePath() else{
            return nil
        }
        return DataManager.default.document(path: firestorePath)
    }
    
    
    /// Creates an firestore snapshot listener in case the poolNode has an documentId
    func connectFirebaseSnapshotListerner(){
        guard let documentReference = self.getFirestoreReference() else{
            return
        }
        
        documentSnapshotListener = documentReference.addSnapshotListener { (snapshot, error) in
            self.snapshot(snapshot, error)
            self.snapshotListenerDelegate?.snapshot(snapshot, error)
            if snapshot != nil {
                self.delegate?.node(self, didRecievedSnapshotUpdate: snapshot!)
            }else {
                self.delegate?.node(self, didRecievedSnapshotError: error!)
            }
        }
    }
    
    
    /// In case the PoolNode already has an documentId, the values will be pushed and updated in Firestore.
    /// Otherwise a new document will be created and the data will be written into that document
    /// - Parameter completion: Callback for error handling
    func pushToFirestore(_ completion: ((Error?) -> Void)?) {
        writeToSource()
        if !hasChanged {
            completion?(nil)
            delegate?.node(self, didPushDataToFirestore: nil)
        } else if documentId == nil && parentFirestorePath() != nil {
            print("Create firestore doc")
            createFirestoreDocument { (error) in
                self.delegate?.node(self, didPushDataToFirestore: error)
                completion?(error)
            }
        }else {
            print("Push data to existing document")
            // If something has changed -> push the data to firestore
            (self as FirestoreExtension).pushToFirestore { (error) in
                self.delegate?.node(self, didPushDataToFirestore: error)
                completion?(error)
            }
            hasChanged = false
        }
    }
    
    /// Downloads a set of documents from firestore.
    /// The documents are converted to a generic type T via the init([String : Any]) constructor
    /// - Parameters:
    ///   - path: Path to the collection in firestore
    ///   - completion: Callback for handling the list of poolNodes and error handling
    class func pullFromFirestore(_ path: String, _ completion: @escaping (_ poolNodes: [PoolNode]?, _ error: Error?) -> Void) {
        let collection = DataManager.default.collection(path: path)
        
        collection.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                completion(nil, error)
                return
            }
            
            let documentChanges = snapshot.documentChanges
            var poolNodes =  [PoolNode]()
            for documentChange in documentChanges {
                let document = documentChange.document
                let poolNode = instantiateType(document.documentID, document.data())
                poolNodes.append(poolNode)
            }
            completion(poolNodes, nil)
            
        }
    }
    
    internal class func instantiateType(_ documentID: String, _ data: [String : Any]) -> PoolNode {
        return PoolNode(data, documentId: documentID)
    }
    
    
    /// Called when the PoolNode does not has an documentId. In this case a
    func createFirestoreDocument(_ completion: ((Error?) -> Void)?){
        guard let collectionPath = self.collectionFirestorePath() else {
            return
        }
        
        let collection = DataManager.default.collection(path: collectionPath)
        // Save the data in the variables in the firestoreData dictionary
        writeToSource()
        var documentRef: DocumentReference?
        documentRef = collection.addDocument(data: getSource()) { (error) in
            guard error == nil else {
                DataManager.default.processError(error!, "Error while adding a firestore Document")
                completion?(error!)
                return
            }
            // Save the documentID of the new document in this document
            self.documentId = documentRef?.documentID
            completion?(nil)
        }
        
    }
    
    
    
}


extension PoolNode: SnapshotListenerDelegate {
    func snapshotListener(_ snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else{
            return
        }
        firestoreData = data
        firestoreData[NoSQLConstants.ID.rawValue] = snapshot.documentID
        loadFromSource()
    }
    
    func snapshotListener(_ error: Error) {
        DataManager.default.processError(error, "Error occured during an snapshot listener event.")
    }
    
}



// Sorting algos
extension PoolNode {
    
    func sortByNewest(_ other: PoolNode) -> Bool {
        guard let t1 = timestamp?.dateValue(), let t2 = other.timestamp?.dateValue() else {
            return false
        }
        return t1 < t2
    }
    
    func sortByOldest(_ other: PoolNode) -> Bool {
        guard let t1 = timestamp?.dateValue(), let t2 = other.timestamp?.dateValue() else {
            return false
        }
        return t1 > t2
    }
    
    func sortByName(_ other: PoolNode) -> Bool {
        let t1 = title
        let t2 = other.title
        return t1 < t2
    }
}



protocol SnapshotListenerDelegate {
    
    
    /// Called when the listener got some valid data
    ///
    /// - Parameter snapshot: QuerySnapshot with documentChanges
    func snapshotListener(_ snapshot: DocumentSnapshot)
    
    
    /// Called when the listener got some error
    ///
    /// - Parameter error: Error with description
    func snapshotListener(_ error: Error)
    
    
    /// Called when the listener fired
    func snapshotListener()
    
}

extension SnapshotListenerDelegate {
    func snapshot(_ snapshot: DocumentSnapshot?, _ error: Error?) {
        guard let snapshot = snapshot else {
            snapshotListener(error!)
            snapshotListener()
            return
        }
        snapshotListener(snapshot)
        snapshotListener()
    }
    
    func snapshotListener() {
        
    }
}




class NoFirestorePathError: Error { }

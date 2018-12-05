//
//  Pool.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 20.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import FirebaseFirestore

class Pool: PoolNode {
    
    public static let POOL_COLLECTION_NAME = "pools"
    public static let POOLNAME = "name"
    
    override var firestoreCollectionName: String {
        return Pool.POOL_COLLECTION_NAME
    }
    
    override var delegate: SnapshotListenerDelegate?{
        didSet{
            forEachSupNode { (poolNode) in
                poolNode.delegate = delegate
            }
        }
    }
    
    private var poolName: String?{
        didSet{ hasChanged = true }
    }
    
    private var files = [PoolFile]()
    
    private var comments = [PoolComment]()
    
    private var connections = [PoolConnection]()
    
    private var urls = [PoolURL]()
    
    private var dots = [PoolDot]()
    
    private var subPools = [Pool]()
    
    override func pushToFirestore(_ completion: ((Error?) -> Void)?) {
        super.pushToFirestore(completion)
        
        pushFilesToFirestore(completion)
        pushCommentsToFirestore(completion)
        pushUrlsToFirestore(completion)
        pushDotsToFirestore(completion)
        pushConnectionsToFirestore(completion)
        
        pushSubPoolsToFirestore(completion)
    }
    
    private func pushFilesToFirestore(_ completion: ((Error?) -> Void)?){
        for file in files {
            file.pushToFirestore(completion)
        }
    }
    
    private func pushCommentsToFirestore(_ completion: ((Error?) -> Void)?){
        for comment in comments {
            comment.pushToFirestore(completion)
        }
    }
    
    private func pushConnectionsToFirestore(_ completion: ((Error?) -> Void)?){
        for connection in connections {
            connection.pushToFirestore(completion)
        }
    }
    
    private func pushUrlsToFirestore(_ completion: ((Error?) -> Void)?){
        for url in urls {
            url.pushToFirestore(completion)
        }
    }
    
    private func pushDotsToFirestore(_ completion: ((Error?) -> Void)?){
        for dot in dots {
            dot.pushToFirestore(completion)
        }
    }
    
    private func pushSubPoolsToFirestore(_ completion: ((Error?) -> Void)?){
        for subPool in subPools {
            subPool.pushToFirestore(completion)
        }
    }

    
    override func writeToSource() {
        super.writeToSource()
        firestoreData[Pool.POOLNAME] = poolName

    }
    
    override func loadFromSource() {
        
        poolName = getString(key: Pool.POOLNAME)
        super.loadFromSource()
        
    }
    
    override func parentFirestorePath() -> String? {
        if parent == nil {
            return DataManager.default.userPoolDir
        }
        return super.parentFirestorePath()
    }
  
    
    override func firestorePath() -> String? {
        if documentId != nil && parent == nil {
            return DataManager.default.userPoolDir! + "/" + documentId!
        }
        return super.firestorePath()
    }

    private func forEachSupNode(_ action: (PoolNode) -> Void) {
        files.forEach(action)
        comments.forEach(action)
        connections.forEach(action)
        urls.forEach(action)
        dots.forEach(action)
        subPools.forEach { (pool) in
            pool.forEachSupNode(action)
        }
    }
    
    // Pulling the files, comments, connections, etc. for a pool
    
    
    /// Pulls the poolNodes for a pool.
    /// Warning! This method does not pull the poolNodes for the subPools.
    /// - Parameter completion: Callback for handling server errors and ui updates
    func getPoolContent(_ completion: ((Error?) -> Void)?){
        pullFiles(PoolFile.POOLFILE_COLLECTION_NAME, completion)
        
        pullConnections(PoolConnection.POOLCONNECTION_COLLECTION_NAME, completion)
        
        // TODO: pull other poolNode types
    }
    
    
    
    /// Pulls all files for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode Type: File
    ///   - completion: Callback for hadnling ui updates or error handling
    private func pullFiles(_ pathExtension: String,_ completion: ((Error?) -> Void)?){
        guard let firestorePath = firestorePath() else {
            return
        }
        // FirestorePath exists -> start pulling the files
        PoolFile.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.files = poolNodes as! [PoolFile]
        }
    }
    
    
    /// Pulls all connections for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: Connection
    ///   - completion: Callback for handling ui updates or error handling
    private func pullConnections(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolConnection.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.connections = poolNodes as! [PoolConnection]
        }
    }
    
    /// Pulls all comments for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: comments
    ///   - completion: Callback for handling ui updates or error handling
    private func pullComments(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolComment.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.comments = poolNodes as! [PoolComment]
        }
    }
    
    /// Pulls all dots for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: dots
    ///   - completion: Callback for handling ui updates or error handling
    private func pullDots(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolDot.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.dots = poolNodes as! [PoolDot]
        }
    }
    
    
    /// Pulls all url for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: URL
    ///   - completion: Callback for handling ui updates or error handling
    private func pullURL(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolURL.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.urls = poolNodes as! [PoolURL]
        }
    }
    
    private func clear(){
        files = []
        comments = []
        connections = []
        urls = []
        dots = []
        subPools = []
    }
    
    override class func instantiateType(_ documentID: String, _ data: [String : Any]) -> PoolNode {
        return Pool(data, documentId: documentID)
    }
}




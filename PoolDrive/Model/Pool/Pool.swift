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
    
    override var snapshotListenerDelegate: SnapshotListenerDelegate?{
        didSet{
            forEachSupNode { (poolNode) in
                poolNode.snapshotListenerDelegate = snapshotListenerDelegate
            }
        }
    }
    
    var poolName: String?{
        didSet{ hasChanged = true }
    }
    
    override var title: String {
        get{
            print("get pool title")
            return poolName ?? "files"
        }
        set{
            hasChanged = true
//            poolName = newValue
        }
    }
    
    private(set) var files = [PoolFile]()
    
    private(set) var comments = [PoolComment]()
    
    private(set) var connections = [PoolConnection]()
    
    private(set) var urls = [PoolURL]()
    
    private(set) var dots = [PoolDot]()
    
    private(set) var subPools = [Pool]()
    
    
    private var merge: [PoolNode]?
    
    var poolNodes: [PoolNode] {
        guard let merge = self.merge else {
            self.merge = self.mergePoolNodes()
            return self.merge!
        }
        return merge
    }
    
    
    /// Returns the total amount of poolNodes for one specific pool
    var totalPoolNodeCount: Int{
        get {
            return poolNodes.count
        }
    }
    
    
    /// Pushes the data that changed inside of the current pool and all subpool to firestore
    ///
    /// - Parameter completion: Callback
    override func pushToFirestore(_ completion: ((Error?) -> Void)?) {
        print(firestorePath())
        super.pushToFirestore(completion)
        
        forEachSupNode { (poolNode) in
            poolNode.pushToFirestore(completion)
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
    func getPoolContent(_ completionNodes: ((Error?) -> Void)?, _ completion: (() -> Void)?){
        var finishCount = 0
        
        let cm: ((Error?) -> Void)? = { (error: Error?) in
            completionNodes?(error)
            finishCount += 1
            if (finishCount == 5){
                self.forEachSupNode({ (node) in
                    node.parent = self
                })
                completion?()
            }
        }
        
        pullFiles(PoolFile.POOLFILE_COLLECTION_NAME, cm)
        
        pullConnections(PoolConnection.POOLCONNECTION_COLLECTION_NAME, cm)
        
        pullComments(PoolComment.POOLCOMMENT_COLLECTION_NAME, cm)
        
        pullDots(PoolDot.POOLDOT_COLLECTION_NAME, cm)
        
        pullURL(PoolURL.POOLURL_COLLECTION_NAME, cm)
        
    }
    
    
    /// Pulls all files for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode Type: File
    ///   - completion: Callback for hadnling ui updates or error handling
    private func pullFiles(_ pathExtension: String,_ completion: ((Error?) -> Void)?){
        guard let firestorePath = firestorePath() else {
            completion?(NoFirestorePathError())
            return
        }
        // FirestorePath exists -> start pulling the files
        PoolFile.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.files = poolNodes as! [PoolFile]
            completion?(nil)
        }
    }
    
    
    /// Pulls all connections for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: Connection
    ///   - completion: Callback for handling ui updates or error handling
    private func pullConnections(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            completion?(NoFirestorePathError())
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolConnection.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.connections = poolNodes as! [PoolConnection]
            completion?(nil)
        }
    }
    
    /// Pulls all comments for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: comments
    ///   - completion: Callback for handling ui updates or error handling
    private func pullComments(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            completion?(NoFirestorePathError())
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolComment.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.comments = poolNodes as! [PoolComment]
            completion?(nil)
        }
    }
    
    /// Pulls all dots for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: dots
    ///   - completion: Callback for handling ui updates or error handling
    private func pullDots(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            completion?(NoFirestorePathError())
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolDot.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.dots = poolNodes as! [PoolDot]
            completion?(nil)
        }
    }
    
    
    /// Pulls all url for the pool
    ///
    /// - Parameters:
    ///   - pathExtension: pathExtension for poolNode type: URL
    ///   - completion: Callback for handling ui updates or error handling
    private func pullURL(_ pathExtension: String, _ completion: ((Error?) -> Void)?) {
        guard let firestorePath = firestorePath() else {
            completion?(NoFirestorePathError())
            return
        }
        // FirestorePath exists -> start pulling the connections
        PoolURL.pullFromFirestore(firestorePath + "/\(pathExtension)") { (poolNodes, error) in
            guard let poolNodes = poolNodes else {
                completion?(error)
                return
            }
            self.urls = poolNodes as! [PoolURL]
            completion?(nil)
        }
    }
    
    
    override class func instantiateType(_ documentID: String, _  data: [String : Any]) -> PoolNode {
        return Pool(data, documentId: documentID)
    }
    
    
    //+++++++++++++++++++++++++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++
    // Helper Methods for adding poolNodes to the current pool.
    //+++++++++++++++++++++++++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++
    
    private func prepareNewPoolNode(_ poolNode: PoolNode){
        poolNode.parent = self
        merge?.append(poolNode)
    }
    
    func addFile(_ file: PoolFile, _ autoPush: Bool = false, _ completion: ((Error?) -> Void)? = nil) {
        prepareNewPoolNode(file)
        files.append(file)
        if autoPush {
            self.pushToFirestore(completion)
        }
    }
    
    func addComment(_ comment: PoolComment, _ autoPush: Bool = false, _ completion: ((Error?) -> Void)? = nil) {
        prepareNewPoolNode(comment)
        comments.append(comment)
        if autoPush {
            self.pushToFirestore(completion)
        }
    }
    
    func addConnection(_ connection: PoolConnection, _ autoPush: Bool = false, _ completion: ((Error?) -> Void)? = nil) {
        prepareNewPoolNode(connection)
        connections.append(connection)
        if autoPush {
            self.pushToFirestore(completion)
        }
    }
    
    func addDot(_ dot: PoolDot, _ autoPush: Bool = false, _ completion: ((Error?) -> Void)? = nil) {
        prepareNewPoolNode(dot)
        dots.append(dot)
        if autoPush {
            self.pushToFirestore(completion)
        }
    }
    
    func addUrl(_ url: PoolURL, _ autoPush: Bool = false, _ completion: ((Error?) -> Void)? = nil) {
        prepareNewPoolNode(url)
        urls.append(url)
        if autoPush {
            self.pushToFirestore(completion)
        }
    }
}







// Sorting Pools
extension Pool {
    
    
    /// Merges all the poolNodes
    ///
    /// - Returns:
    private func mergePoolNodes() -> [PoolNode] {
        var merge = [PoolNode]()
        merge.append(contentsOf: files)
        merge.append(contentsOf: comments)
        merge.append(contentsOf: connections)
        merge.append(contentsOf: dots)
        merge.append(contentsOf: urls)
        merge.append(contentsOf: subPools)
        return merge
    }
    
    
    /// Returns the merged poolNodes sorted by the timestamp value
    /// Ordering: Ascending (Newest first)
    /// - Returns: List of sorted poolNodes
    func getByNewest() -> [PoolNode] {
        merge = nil
        var nodes = poolNodes
        nodes.sort(by: { (node1, node2) -> Bool in
            return node1.sortByNewest(node2)
        })
        return poolNodes
        
    }
    
    
    /// Returns the merged poolNodes sorted by the timestamp value
    /// Ordering: Descending (Oldest first)
    /// - Returns: List of sorted poolNodes
    func getByOldest() -> [PoolNode] {
        merge = nil
        var nodes = poolNodes
        nodes.sort(by: { (node1, node2) -> Bool in
            return node1.sortByOldest(node2)
        })
        return poolNodes
    }
    
    
    /// Returns the merged poolNodes sorted by the title
    /// Ordering: Ascending ('A' first, ...)
    /// - Returns: List of sorted poolNodes
    func getByTitle() -> [PoolNode] {
        merge = nil
        var nodes = poolNodes
        nodes.sort { (node1, node2) -> Bool in
            return node1.sortByName(node2)
        }
        return poolNodes
    }
    
    
 
    
    
    
    //    private func pushFilesToFirestore(_ completion: ((Error?) -> Void)?){
    //        for file in files {
    //            file.pushToFirestore(completion)
    //        }
    //    }
    //
    //    private func pushCommentsToFirestore(_ completion: ((Error?) -> Void)?){
    //        for comment in comments {
    //            comment.pushToFirestore(completion)
    //        }
    //    }
    //
    //    private func pushConnectionsToFirestore(_ completion: ((Error?) -> Void)?){
    //        for connection in connections {
    //            connection.pushToFirestore(completion)
    //        }
    //    }
    //
    //    private func pushUrlsToFirestore(_ completion: ((Error?) -> Void)?){
    //        for url in urls {
    //            url.pushToFirestore(completion)
    //        }
    //    }
    //
    //    private func pushDotsToFirestore(_ completion: ((Error?) -> Void)?){
    //        for dot in dots {
    //            dot.pushToFirestore(completion)
    //        }
    //    }
    //
    //    private func pushSubPoolsToFirestore(_ completion: ((Error?) -> Void)?){
    //        for subPool in subPools {
    //            subPool.pushToFirestore(completion)
    //        }
    //    }

}


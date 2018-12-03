//
//  Pool.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 20.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import FirebaseFirestore

class Pool: PoolNode {
    
    public static let POOLNAME = "name"
    
    override var firestoreCollectionName: String {
        return "pools"
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
    
    func getPoolContent(_ completion: ((Error?) -> Void)?){
        
    }
    
    
    private func clear(){
        files = []
        comments = []
        connections = []
        urls = []
        dots = []
        subPools = []
    }
}




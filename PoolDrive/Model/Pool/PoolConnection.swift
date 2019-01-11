//
//  PoolConnection.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 27.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation

class PoolConnection: PoolNode {
    
    public static let POOLCONNECTION_COLLECTION_NAME = "connections"
    public static let FROMDOCUMENTID = "fromDocumentId"
    public static let TODOCUMENTID = "toDocumentId"
    public static let CONNECTIONCOMMENT = "comment"
    
    override var firestoreCollectionName: String{
        return PoolConnection.POOLCONNECTION_COLLECTION_NAME
    }
    
    var fromDocumentId: String?
    
    var toDocumentId: String?
    
    var comment: String?
    
    var fromPoolNode: PoolNode?
    
    var toPoolNode: PoolNode?
    
    override func writeToSource() {
        super.writeToSource()
        firestoreData[PoolConnection.FROMDOCUMENTID] = fromDocumentId
        firestoreData[PoolConnection.TODOCUMENTID] = toDocumentId
        firestoreData[PoolConnection.CONNECTIONCOMMENT] = comment
    }
    
    override func loadFromSource() {
        fromDocumentId = getString(key: PoolConnection.FROMDOCUMENTID)
        toDocumentId = getString(key: PoolConnection.TODOCUMENTID)
        comment = getString(key: PoolConnection.CONNECTIONCOMMENT)
        super.loadFromSource()
    }
    
    
    override class func instantiateType(_ documentID: String, _  data: [String : Any]) -> PoolNode {
        return PoolConnection(data, documentId: documentID)
    }
    
}

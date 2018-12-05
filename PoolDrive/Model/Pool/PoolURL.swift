//
//  PoolURL.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 30.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation
class PoolURL: PoolNode{
    
    public static let POOLURL_COLLECTION_NAME = "urls"
    private static let POOLURL = "url"
    
    override var firestoreCollectionName: String{
        return PoolURL.POOLURL_COLLECTION_NAME
    }
    
    var url: String?
    
    override func writeToSource() {
        super.writeToSource()
        firestoreData[PoolURL.POOLURL] = url
    }
    
    override func loadFromSource() {
        url = getString(key: PoolURL.POOLURL)
        super.loadFromSource()
    }
    
    
    override class func instantiateType(_ documentID: String, _ data: [String : Any]) -> PoolNode {
        return PoolURL(data, documentId: documentID)
    }
}

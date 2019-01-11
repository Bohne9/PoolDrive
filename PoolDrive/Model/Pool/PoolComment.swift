//
//  PoolComments.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 25.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation

class PoolComment: PoolNode {
    
    public static let POOLCOMMENT_COLLECTION_NAME = "comments"
    private static let COMMENT = "comment"
    
    override var firestoreCollectionName: String{
        return PoolComment.POOLCOMMENT_COLLECTION_NAME
    }
    
    var comment: String?
    
    override func writeToSource() {
        super.writeToSource()
        firestoreData[PoolComment.COMMENT] = comment
    }
    
    override func loadFromSource() {
        comment = getString(key: PoolComment.COMMENT)
        super.loadFromSource()
    }
    
    override class func instantiateType(_ documentID: String, _  data: [String : Any]) -> PoolNode {
        return PoolComment(data, documentId: documentID)
    }
}


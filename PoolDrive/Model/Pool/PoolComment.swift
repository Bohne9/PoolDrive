//
//  PoolComments.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 25.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation

class PoolComment: PoolNode {
    
    private static let COMMENT = "comment"
    
    override var firestoreCollectionName: String{
        return "comments"
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
    
}


//
//  PoolURL.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 30.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation
class PoolURL: PoolNode{
    
    private static let POOLURL = "url"
    
    override var firestoreCollectionName: String{
        return "urls"
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
}

//
//  PoolDot.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 30.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import Foundation


/// Describes a PoolNode inside of an pool.
/// A PoolDot is a Node that can have a label.
/// It's primary task is to connect other nodes.
class PoolDot: PoolNode {
    
    public static let DOTLABEL = "label"
    
    override var firestoreCollectionName: String{
        return "dots"
    }
    
    var label: String?
    
    override func writeToSource() {
        super.writeToSource()
        
        firestoreData[PoolDot.DOTLABEL] = label
    }
    
    override func loadFromSource() {
        label = getString(key: PoolDot.DOTLABEL)
        super.loadFromSource()
    }
}

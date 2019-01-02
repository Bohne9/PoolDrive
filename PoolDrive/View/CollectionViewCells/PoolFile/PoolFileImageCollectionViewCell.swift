//
//  PoolFileImageCollectionViewCell.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 23.12.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import QuickLook

class PoolFileImageCollectionViewCell: UICollectionViewCell {
    
    var poolFile: PoolFile?
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUserInterface(){
        
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFill
        
        guard let image = self.imageView else {
            return
        }
        
        addSubview(image)
        image.addSubview(image)
        
        image.fillSuperview()
    }

    
    func reload(_ poolFile: PoolFile) {
        self.poolFile = poolFile
        
        
    }
    
}

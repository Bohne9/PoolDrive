//
//  PoolNodeCellCollectionViewCell.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 15.12.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class PoolNodeCellCollectionViewCell: UICollectionViewCell {
    
    var poolNode: PoolNode?
    
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUserInterface(){
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.black.cgColor
        
        contentView.layer.cornerRadius = 4
//        backgroundColor = .white
        
        contentView.backgroundColor = .dazzledBlue
        
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    
    
    func reload(with poolNode: PoolNode) {
        self.poolNode = poolNode
        
        titleLabel.text = poolNode.title
        
        
    }
    
}

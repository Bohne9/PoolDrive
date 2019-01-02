//
//  PoolFileInfoCollectionViewCell.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 21.12.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit

class PoolFileInfoCollectionViewCell: UICollectionViewCell {
    
    var poolFile: PoolFile?
    
    var timestampLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    var createdByLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .right
        return label
    }()
    
    var timestampDescription: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()
    
    var createdByDescription: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .gray
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
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.darkGray.cgColor
        
//        backgroundColor = .white
        
        contentView.layer.cornerRadius = 4
        
        contentView.backgroundColor = UIColor.white
        
        setupLabel(timestampDescription)
        setupLabel(timestampLabel)
        setupLabel(createdByDescription)
        setupLabel(createdByLabel)
        
        timestampDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3).isActive = true
        timestampDescription.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        
        timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3).isActive = true
        timestampLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        
        createdByDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3).isActive = true
        createdByDescription.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        createdByLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3).isActive = true
        createdByLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        timestampDescription.text = "Created on: "
        createdByDescription.text = "Created by: "
    }
    
    private func setupLabel(_ label: UILabel){
        contentView.addSubview(label)
        
        label.heightAnchor.constraint(equalToConstant: 35).isActive = true
        label.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
    }
    
    func reload(_ poolFile: PoolFile) {
        self.poolFile = poolFile
        
        timestampLabel.text = "\(poolFile.timestamp!.dateValue())"
        createdByLabel.text = poolFile.userId
    }
    
    
    
}

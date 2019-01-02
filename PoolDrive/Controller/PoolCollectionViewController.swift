//
//  PoolCollectionViewController.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 09.12.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import QuickLook

private let reuseIdentifier = "poolNodeCell"

class PoolCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIDocumentPickerDelegate,
QLPreviewControllerDataSource, QLPreviewControllerDelegate{
    
    
    var pool: Pool?{
        didSet {
            guard let pool = self.pool else {
                return
            }
            title = pool.poolName
        }
    }
    
    private var poolFileController: PoolFileController?
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        
        // Register cell classes
        self.collectionView!.register(PoolNodeCellCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionView.delegate = self
        
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 20
        
        self.title = "Computer Science"
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pool?.poolNodes.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PoolNodeCellCollectionViewCell
        let node = pool!.poolNodes[indexPath.row]
        cell.reload(with: node)
        cell.titleLabel.text = "\(node.title)"
        
        // Configure the cell
    
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 170)
    }
    
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        if self.poolFileController == nil {
//            poolFileController = PoolFileController(collectionViewLayout: UICollectionViewFlowLayout())
//        }
//
//        poolFileController!.poolFile = pool!.poolNodes[indexPath.row] as! PoolFile
//        navigationController?.pushViewController(poolFileController!, animated: true)
//
        let node = pool!.poolNodes[indexPath.row] as! PoolFile
        
        node.fileDelegate = self
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath="\(documentsPath)/\(node.fileName!)";
        node.downloadDataFromStorageToLocalFile(URL(fileURLWithPath: filePath)) { (error) in
            guard error == nil else{
                print(error!)
                return
            }
        
            guard let localURL = node.localUrl else {
                print("no url")
                return
            }
        
            self.urls = [localURL]
            print(localURL.absoluteString)
        
            let quickLookController = QLPreviewController()
            quickLookController.dataSource = self
            quickLookController.delegate = self
            self.present(quickLookController, animated: true, completion: nil)
        
        
        
        }
        

        return true
    }
    
    private var urls = [URL]()
    
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urls[index] as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    
//    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
//    documentPicker.delegate = self
//    present(documentPicker, animated: true, completion: nil)
//
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        var data = [String : Any]()
        DataManager.default.writeUserIdAndTimestamp(&data)
        data["fileName"]  = urls.first!.lastPathComponent
        
        let poolFile = PoolFile(data)
        
        poolFile.data = try? Data(contentsOf: urls.first!)
        
//        poolFile.meta?.contentType
        
        pool!.addFile(poolFile)
        
        poolFile.pushToFirestore { (error) in
            guard error == nil else {
                DataManager.default.processError(error!)
                return
            }
            DataManager.default.processInfo("Uploaded image")
        }
        
    }
    
    
    
    
    
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
////        return pool!.poolNodes[index]
//        
//    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}







extension PoolCollectionViewController: FileNodeDelegate {
    
    func node(_ file: PoolFile, didRecievedDownloadUrl url: URL) {
        
        DataManager.default.writeToTemporaryFile(url) { (url) in
//            self.urls = [url]
//            print(url.absoluteString)
//
//            let quickLookController = QLPreviewController()
//            quickLookController.dataSource = self
//            quickLookController.delegate = self
//            self.present(quickLookController, animated: true, completion: nil)
        }
        
    }
    
}


//
//  ViewController.swift
//  MConnectIndia
//
//  Created by Apple on 11/12/20.
//

struct ImageState
{
    var image:UIImage
    var imageUrl:String
    var index:String
    var imageChecked:Bool
}


import UIKit
import Photos

class ViewController: UIViewController,
                      UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout
{
    
    var imageArray = [ImageState]()
    var imageIds = [Int]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var allPhotos = PHFetchResult<PHAsset>()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = CustomImageLayout()
        
        grabPhotos()
        title = "Choose Photos"
    }
    //MARK: grab photos
    func grabPhotos()
    {
        imageArray = []
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(
                key: "creationDate",
                ascending: true)
        ]
        // 2
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    @IBAction func saveImages(_ sender: UIButton) {
        
        let filteredArray = imageArray.filter() { $0.imageChecked == true }
        if filteredArray.count == 0
        {
            Helper.sharedHelper.showAlert("MConnect India",
                                          alertMessage: "Please select images")
            return
        }
        
        for i in 0..<imageArray.count
        {
            if imageArray[i].imageChecked == true
            {
                let predicate = NSPredicate(format: "image_id = \(imageArray[i].index)")
                DbManager.sharedDbManager.fetchDataFromTable("Album",
                                                             strPredicate: predicate)
                { (result) in
                    if result.count > 0
                    {
                        
                    }
                    else
                    {
                        let strImagePathUrl = (Helper.sharedHelper.saveimageToDocumentDirectory(imageArray[i].image))
                        _ = strImagePathUrl.components(separatedBy: "/")
                        
                        let imageData = NSMutableDictionary()
                        
                        let date = Date()
                        imageData.setValue(imageArray[i].index, forKey: "image_id")
                        imageData.setValue(strImagePathUrl, forKey: "imagePath")
                        imageData.setValue(date.format(), forKey: "date")
                        imageData.setValue("_yes", forKey: "isSaved")
                        
                        DbManager.sharedDbManager.insertIntoTable("Album",
                                                                  dictInsertData: imageData)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:CustomCollectionCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionCellCollectionViewCell", for: indexPath) as! CustomCollectionCellCollectionViewCell
        
        cell.imageView.fetchImageAsset(allPhotos[indexPath.row],
                                       targetSize: cell.imageView.bounds.size)
        {   [weak self]
            isDataAvailable,imageData  in
            if let _weakSelf = self
            {
                if isDataAvailable
                {
                    if !_weakSelf.imageIds.contains(indexPath.row)
                    {
                        _weakSelf.imageArray.append(ImageState(image: imageData ?? UIImage(),
                                                               imageUrl: "",
                                                               index: "\(indexPath.row)",
                                                               imageChecked: false))
                        _weakSelf.imageIds.append(indexPath.row)
                    }
                    else
                    {
                        if _weakSelf.isImageSelected(row:indexPath.row){
                            
                            cell.imgViewTickMark.image = UIImage(named: "check-1")
                            cell.lblCount.backgroundColor = .clear
                            cell.lblCount.textColor = .clear
                            cell.lblCount.text = ""
                        }
                        else
                        {
                            
                            cell.imgViewTickMark.image = UIImage(named: "uncheck-1")
                            cell.lblCount.text = ""
                            cell.lblCount.backgroundColor = .clear
                            cell.lblCount.textColor = .clear
                        }
                    }
                }
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = collectionView.frame.width
        return CGSize(width: width/3 - 1, height: width/3 - 1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let predicate = NSPredicate(format: "image_id = \(imageArray[indexPath.row].index)")
        DbManager.sharedDbManager.fetchDataFromTable("Album",
                                                     strPredicate: predicate)
        { (result) in
            if result.count > 0
            {
                Helper.sharedHelper.showAlert("Error",
                                              alertMessage: "One of your media is already copied.")
                imageArray[indexPath.row].imageChecked = true
                self.collectionView.reloadData()
                return
            }
            else
            {
                if imageArray[indexPath.row].imageChecked
                {
                    imageArray[indexPath.row].imageChecked = false
                }
                else
                {
                    imageArray[indexPath.row].imageChecked = true
                }
                self.collectionView.reloadData()
            }
        }
        
       
    }
    
    func isImageSelected(row:Int) -> Bool
    {
        return imageArray[row].imageChecked ? true : false
    }
}

class CustomImageLayout: UICollectionViewFlowLayout {
    
    var numberOfColumns:CGFloat = 3.0
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override var itemSize: CGSize
    {
        set { }
        get {
            let itemWidth = (self.collectionView!.frame.width - (self.numberOfColumns - 1)) / self.numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
}
extension UIImageView {
    func fetchImageAsset(_ asset: PHAsset?, targetSize size: CGSize, contentMode: PHImageContentMode = .aspectFill, options: PHImageRequestOptions? = nil, completionHandler: ((Bool,UIImage?) -> Void)?) {
        // 1
        guard let asset = asset else {
            completionHandler?(false,nil)
            return
        }
        // 2
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            self.image = image
            completionHandler?(true,image)
        }
        // 3
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: contentMode,
            options: options,
            resultHandler: resultHandler)
    }
}
extension Date {
    func format(format:String = "dd-MM-yyyy hh-mm-ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as? Locale
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

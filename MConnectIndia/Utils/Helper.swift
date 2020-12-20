//
//  Helper.swift
//  MConnectIndia
//
//  Created by Apple on 20/12/20.
//

import Foundation
import CoreData
import AVFoundation
import UIKit

open class Helper : NSObject
{
    
    static let sharedHelper = Helper()
    
    override init()
    {
        
    }
    
    func saveimageToDocumentDirectory( _ pickedimage : UIImage )-> String
    {
        let image = imageOrientation(pickedimage)
        let imagedata = self.compressImage(image:image)
        //let imagedata = UIImageJPEGRepresentation(compressImage, 0.75)
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docs: NSString = paths[0] as NSString
        
        var Timestamp: TimeInterval {
            return Date().timeIntervalSince1970 * 1000
        }
        
        
        let fullPath = docs.appendingPathComponent("\(Timestamp).png")
        _ = (try? imagedata.write(to: URL(fileURLWithPath: fullPath), options: [.atomic])) != nil
        
        return fullPath
    }
    func imageOrientation(_ src:UIImage) -> UIImage
    {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
            
            let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            
            ctx.concatenate(transform)
            
            switch src.imageOrientation {
            case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
                ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
                break
            default:
                ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
                break
            }
            
            let cgimg:CGImage = ctx.makeImage()!
            let img:UIImage = UIImage(cgImage: cgimg)
            
            return img
        }
        return UIImage()
    }
    func compressImage(image:UIImage)->Data
    {
        let actualHeight:CGFloat = image.size.height
        let actualWidth:CGFloat = image.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 1024.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.75
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = img.jpegData(compressionQuality: compressionQuality)!
        UIGraphicsEndImageContext()
        return imageData
    }
    func getRootViewController() -> UIViewController?
      {
          if let topController = UIApplication.topViewController() {
              return topController
          }
          if let viewController =  UIApplication.shared.keyWindow?.rootViewController
          {
              return viewController
          }
          return nil
      }
      func showAlert(_ alertTitle: String, alertMessage: String)
      {
          if objc_getClass("UIAlertController") != nil
          { // iOS 8
              let myAlert: UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
              myAlert.view.tintColor = customColor.globalTintColor
              myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              self.getRootViewController()?.present(myAlert, animated: true, completion: nil)
          }
          else
          {
              let alert: UIAlertView = UIAlertView()
              alert.delegate = self
              alert.title = alertTitle
              alert.tintColor = customColor.globalTintColor
              alert.message = alertMessage
              alert.addButton(withTitle: "OK")
              
              alert.show()
          }
      }
}
extension UIApplication
{
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
struct customColor
{
    static let globalTintColor =  UIColor(red: 67.0/255.0, green: 141.0/255.0, blue: 65.0/255.0, alpha:1.0)
}

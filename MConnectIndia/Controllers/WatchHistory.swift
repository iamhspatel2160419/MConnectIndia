//
//  WatchHistory.swift
//  MConnectIndia
//
//  Created by Apple on 20/12/20.
//

import UIKit

class WatchHistory: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var list = [Album]()
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Receive History"
        tableview.dataSource = self
        tableview.delegate = self
        fetchData()
    }
    
    func fetchData()
    {
        let predicate = NSPredicate(format: "isSaved = %@","_yes")
        DbManager.sharedDbManager.fetchDataFromTable("Album",strPredicate: predicate)
        { (result) in
            if result.count > 0
            {
                for k in 0..<result.count
                {
                    let _Album = result[k] as! Album
                    list.append(_Album)
                }
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : CustomCell
        cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")! as! CustomCell
        
        
        let obj = list[indexPath.row]
        let fileArry = obj.imagePath!.components(separatedBy: "/")
        let path = URL.urlInDocumentsDirectory(with: fileArry[fileArry.count-1]).path
        let image = UIImage(contentsOfFile: path)
        cell.lblVideoTitle.text = obj.date
        cell.imageView_.image = image
        
        cell.selectionStyle = .none
        if let date = obj.date
        {
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = NSTimeZone.local
            timeFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            timeFormatter.dateFormat = "dd-MM-yyyy hh-mm-ss"
            let time1 =  timeFormatter.date(from: date)
            let time2 =  timeFormatter.date(from: self.getLocalTimeZone(dateFormat: "dd-MM-yyyy hh-mm-ss") )
            
            let secondsAgo = Int(time2!.timeIntervalSince(time1!))
            var duration = ""
            let minute = 60
            let hour = 60 * minute
            let day = 24 * hour
            let week = 7 * day
            
            if secondsAgo < minute  {
                if secondsAgo < 2{
                    duration = "just now"
                }else{
                    duration = "\(secondsAgo) secs ago"
                }
            } else if secondsAgo < hour {
                let min = secondsAgo/minute
                if min == 1{
                    duration = "\(min) min ago"
                }else{
                    duration = "\(min) mins ago"
                }
            } else if secondsAgo < day {
                let hr = secondsAgo/hour
                if hr == 1{
                    duration = "\(hr) hr ago"
                } else {
                    duration = "\(hr) hrs ago"
                }
            } else if secondsAgo < week {
                let day = secondsAgo/day
                if day == 1{
                    duration = "\(day) day ago"
                }else{
                    duration = "\(day) days ago"
                }
            }
            cell.lblDate.text = duration
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func getLocalTimeZone(dateFormat:String)->String
    {
        let dateFormatter = DateFormatter()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        //NSTimeZone(name: "UTC") as TimeZone! //
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        let strCurrentTimezone = dateFormatter.string(from: Date())
        return strCurrentTimezone
    }
    func isFileExistsInDirectory(docName:String) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths[0] as String;
        
        let documentsDirectory: URL = NSURL.init(string: path)! as URL
        let dataPath:NSURL = documentsDirectory.appendingPathComponent("/\(docName)") as NSURL
        //appendingPathComponent("/\(docName)")
        let strURL = dataPath.path
        return FileManager.default.fileExists(atPath: strURL!)
    }
    
}
extension URL {
    static var documentsDirectory: URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(string: documentsDirectory)!
    }
    
    static func urlInDocumentsDirectory(with filename: String) -> URL {
        return documentsDirectory.appendingPathComponent(filename)
    }
}
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

//
//  Celebrity.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-12.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
import FirebaseDatabase

class Celebrity: NSObject {
    var name : String = ""
    var hometownLatlng : CLLocation?
    var title : String = ""
    var hometown : String?
    var address : String?
    var category : String?
    var imageUrl : String?
    var intro : String?
    var createTime: Date?

    // Firebase
    private var roofRef: DatabaseReference!
    
    override init(){}
    
    init(name: String, hometown: String, title: String, category: String) {
        self.name = name
        self.hometown = hometown
        self.title = title
        self.category = category
        super.init()
    }
    
    init(name: String, hometownLatlng: CLLocation, title: String, category: String) {
        self.name = name
        self.hometownLatlng = hometownLatlng
        self.title = title
        self.category = category
        super.init()
    }
    
    func toDictionary() -> [String : Any] {
        return ["latitude" : self.hometownLatlng?.coordinate.latitude as Any, "longtidue" : self.hometownLatlng?.coordinate.longitude as Any]
    }
    
    func parseJSON(json : JSON) {
        
        let parsedLatlon : CLLocation = CLLocation(latitude: json["results"][0]["geometry"]["location"]["lat"].doubleValue, longitude: json["results"][0]["geometry"]["location"]["lng"].doubleValue)
        let parseAddress : String = json["results"][0]["formatted_address"].stringValue
        self.hometownLatlng = parsedLatlon
        self.address = parseAddress
    }
    
    func saveToFirebase() {
        roofRef = Database.database().reference()
        let celebrityRef = self.roofRef.child("celebrity")
        let idRef = celebrityRef.childByAutoId()
        
        let dict : [String : Any] = ["name": self.name , "lat": self.hometownLatlng?.coordinate.latitude as! Double, "lng": self.hometownLatlng?.coordinate.longitude as! Double, "hometown": self.hometown as! String, "title": self.title, "category": self.category as! String, "createTime": self.getCurrentDateTime() , "address": self.address as! String, "image": self.imageUrl as! String, "intro": self.intro as! String]
        
        idRef.setValue(dict)
        
        
    }
    
    func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTime = formatter.string(from: Date())
        return currentTime
    }
    
    func getCreateTime(createTimeString: String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        self.createTime = dateFormatter.date(from: createTimeString)
//        let currentTime = getCurrentDateTime()
//        Calendar.current.isDateInToday(createTime!)
        
    }
    
}

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

class Celebrity: NSObject {
    var name : String = ""
    var hometownLatlng : CLLocation?
    var title : String = ""
    var hometown : String?
    var address : String?
    
    override init(){}
    
    init(name: String, hometown: String, title: String) {
        self.name = name
        self.hometown = hometown
        self.title = title
        
        super.init()
    }
    
    init(name: String, hometownLatlng: CLLocation, title: String) {
        self.name = name
        self.hometownLatlng = hometownLatlng
        self.title = title
        
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
    
    
    
}

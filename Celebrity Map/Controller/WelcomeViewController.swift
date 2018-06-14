//
//  ViewController.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-12.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

// MARK - Class to hold the info of annotation
final class CelebrityAnnotaion: NSObject, MKAnnotation, MKMapViewDelegate {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
    
}

class WelcomeViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let APP_ID = "AIzaSyALFOLxjKHnfW4SBOw20t6hVXiUfQ4RY3E"

    
    //MARK - Initialization
    let locationManager = CLLocationManager()
    var userLocation : CLLocation? = nil
    var pin : CelebrityAnnotaion!
    
    var celebrityArray = [Celebrity]()
    

    
    //MARK - IBoutlet Intialization
    @IBOutlet weak var MainMapView: MKMapView!
    
    @IBOutlet weak var locateMeOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Register the Mapview
//        MainMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Mapview Delegate
        MainMapView.delegate = self as? MKMapViewDelegate
        
        //Load celebrity
        loadCelebrity()
    }
    
    //
    

    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
        
        let location = locations[locations.count - 1]
        
        self.userLocation = location
        
        userLocation(location: location)
        
        
        self.MainMapView.showsUserLocation = true
        
    }
    
    //MARK - Load Celebrity data
    func loadCelebrity() {
//        let testHometown : CLLocation = CLLocation(latitude: 44.6617829,longitude: -63.5275867)

        geocodingHometown(celebrity: Celebrity(name: "Sidney Crosby",hometown: "Cole-Habour,NS", title: "NHL Player"))
        geocodingHometown(celebrity: Celebrity(name: "Justin Trudeau", hometown: "Ottawa", title: "Canada Premier"))
        geocodingHometown(celebrity: Celebrity(name: "Chenyinpeng", hometown: "huanggang", title: "APP Coder"))
        geocodingHometown(celebrity: Celebrity(name: "Lebron James", hometown: "Akron,OH", title: "NBA Star"))
        geocodingHometown(celebrity: Celebrity(name: "Donald Trump", hometown: "New-York-City", title: "US president"))
        geocodingHometown(celebrity: Celebrity(name: "Russell Westbrook", hometown: "Long Beach, California", title: "NBA Star"))
        geocodingHometown(celebrity: Celebrity(name: "Jackie Chan", hometown: "Victoria Peak, British Hong Kong", title: "Actor"))
        geocodingHometown(celebrity: Celebrity(name: "Isaac Newton", hometown: "Woolsthorpe, Lincolnshire, England", title: "Scientist"))


    }
    
    
    //MARK - Set annotation from all data in array
    func loadCelebrityAnnotation() -> Void {
        print("Array\(celebrityArray.count)")
        
        for celebrityItem in celebrityArray {
            pin = CelebrityAnnotaion(coordinate: (celebrityItem.hometownLatlng!.coordinate), title: celebrityItem.name, subtitle: celebrityItem.title)
            MainMapView.addAnnotation(pin)
        }
    }
    
    //MARK - geoCoding the given hometown name
    func geocodingHometown(celebrity: Celebrity) {
        // A object used to append an entry to Array
        let celebrityDataModel = Celebrity()
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(celebrity.hometown?.replacingOccurrences(of: " ", with: "-") ?? "beijing")&key=AIzaSyALFOLxjKHnfW4SBOw20t6hVXiUfQ4RY3E"
        
        celebrityDataModel.name = celebrity.name
        celebrityDataModel.title = celebrity.title
        celebrityDataModel.hometown = celebrity.hometown
        
        Alamofire.request(url).responseJSON { response in
//            print(response.request)  // original URL request
//            print(response.response) // HTTP URL response
//            print(response.data)     // server data
//            print(response.result)   // result of response serialization
            
            let returnJson : JSON = JSON(response.result.value!)
            celebrityDataModel.hometownLatlng = self.parseJSON(json: returnJson)
            
            if !self.celebrityArray.contains(celebrityDataModel) {
                self.celebrityArray.append(celebrityDataModel)
            }
            print("countcele:\(self.celebrityArray.count)")
            self.loadCelebrityAnnotation()
        }

    }
    
    //MARK - Parse Json to CLLocation object
    func parseJSON(json : JSON) -> CLLocation {
        
        let parsedLatlon : CLLocation = CLLocation(latitude: json["results"][0]["geometry"]["location"]["lat"].doubleValue, longitude: json["results"][0]["geometry"]["location"]["lng"].doubleValue)
        
        
        return parsedLatlon
    }

    //MARK - Back to user location
    func userLocation(location : CLLocation){
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(5, 5)
            let userLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
            MainMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func locatedMeButtonClicked(_ sender: UIButton) {
        print("button clicked")
        if let userlocations = userLocation{
            userLocation(location: userlocations)
            sender.pulsate()
        }
    }
    


}


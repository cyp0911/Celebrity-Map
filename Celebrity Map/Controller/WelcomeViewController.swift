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
import FirebaseDatabase
import Dropdowns
import SVProgressHUD
import RKDropdownAlert


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
    var onlyOnceRemove : Int = 0
    
    var celebrityArray = [Celebrity]()
    var defaults = UserDefaults.standard
    let cetegoryArray = ["ALL", "Sport", "Political", "Art", "Science", "Technology", "Business"]
    var fullCelebrityArray = [Celebrity]()


    //Mark - Firebase Initialization
    private var roofRef: DatabaseReference!

    
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
        
        //connect to Firebase
        self.roofRef = Database.database().reference()
        
        //SVProgress
        SVProgressHUD.show()
        
        //Load data from database
        loadCelebrity()
        
        //Save current category index
        defaults.set(0, forKey: "selectedCategory")
        
        //Set navigationbar
        setNavgationBar()
        
        //Set bannerview not visable
        
        SVProgressHUD.dismiss()
        

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

        let celebrityRef = roofRef.child("celebrity")
        
            celebrityRef.queryOrdered(byChild: "createTime").observe(.value) { snapshot in
                // Loading progress show
                SVProgressHUD.show()
                self.celebrityArray.removeAll()
                let celebrityDictionaries = snapshot.value as? [String : Any] ?? [:]
                for(key, _) in celebrityDictionaries{
                    if let celebrityDictionary = celebrityDictionaries[key] as? [String : Any]{
                        if let newname = celebrityDictionary["title"]{
                            let newCeleberity = Celebrity(name: celebrityDictionary["name"] as! String, hometownLatlng: CLLocation(latitude: celebrityDictionary["lat"] as! Double, longitude: celebrityDictionary["lng"] as! Double), title: celebrityDictionary["title"] as! String, category: celebrityDictionary["category"] as! String)
                            self.celebrityArray.append(newCeleberity)
                        }
                    }
                }

                    self.dropDownAlert(title: "\(self.celebrityArray.count) Celebrities loded!")
                    self.loadCelebrityAnnotation()
                    // Loading progress show
                    SVProgressHUD.dismiss()
                }

    }
    
    
    //MARK - Set annotation from all data in array
    func loadCelebrityAnnotation() -> Void {
        let selectedIndex = defaults.integer(forKey: "selectedCategory")
        let selectedCategory = cetegoryArray[selectedIndex]
        
        if selectedIndex == 0 && onlyOnceRemove == 0{
            fullCelebrityArray = celebrityArray
        }else{
            celebrityArray = self.celebrityArray.filter { $0.category == selectedCategory}
        }
        
        for celebrityItem in celebrityArray {
            pin = CelebrityAnnotaion(coordinate: (celebrityItem.hometownLatlng!.coordinate), title: celebrityItem.name, subtitle: celebrityItem.title)
            if onlyOnceRemove > 0 {
                MainMapView.removeAnnotations(MainMapView.annotations)
                onlyOnceRemove += 1
            }
            MainMapView.addAnnotation(pin)
        }
        celebrityArray = fullCelebrityArray

    }
    

    //MARK - Back to user location
    func userLocation(location : CLLocation){
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(10, 10)
            let userLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
            MainMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func locatedMeButtonClicked(_ sender: UIButton) {
        if let userlocations = userLocation{
            userLocation(location: userlocations)
            sender.pulsate()
            self.view.endEditing(true)
        }
    }
    
    // MARK - Navigationbar
    func setNavgationBar(){
        //Navigationbar color
        navigationController?.navigationBar.barTintColor = UIColor.red
        tabBarController?.tabBar.barTintColor = UIColor.white
        tabBarController?.tabBar.tintColor = UIColor.red
        
        //Config the navigation bar button color
        Config.topLineColor = UIColor.white
        Config.ArrowButton.Text.color = UIColor.white
        Config.List.backgroundColor = UIColor.white
        //Config the dropdownmenu color
        Config.List.DefaultCell.Text.color = UIColor.red
        Config.List.DefaultCell.separatorColor = UIColor.red

        // Take stored setting from user default
        let selectedIndex = defaults.integer(forKey: "selectedCategory")
        let selectedCategory = cetegoryArray[selectedIndex]

        
        let titleView = TitleView(navigationController: navigationController!, title: selectedCategory, items: self.cetegoryArray)
        titleView?.action = { [weak self] index in
            self?.MainMapView.removeAnnotations((self?.MainMapView.annotations)!)
            self?.defaults.set(index, forKey: "selectedCategory")
            self?.loadCelebrityAnnotation()
        }
        
        
        navigationItem.titleView?.tintColor = UIColor.white
        navigationItem.titleView = titleView
    }
    

    func dropDownAlert(title: String) {
        
        RKDropdownAlert.title(title, backgroundColor: UIColor.orange, textColor: UIColor.white, time: 2)

    }

}


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
import MapViewPlus

// MARK - Class to hold the info of annotation
final class CelebrityAnnotaion: NSObject, MKAnnotation, MKMapViewDelegate {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var celebrity: Celebrity?
    
    init(celebrity: Celebrity) {
        self.celebrity = celebrity
        self.coordinate = (celebrity.hometownLatlng?.coordinate)!
        self.title = celebrity.name
        self.subtitle = celebrity.title
        
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
    @IBOutlet weak var MainMapViewPlus: MapViewPlus!
    
    //MARK - Callout Initialization
    @IBOutlet weak var MainMapView: MKMapView!
    weak var currentCalloutView: UIView?
//    var annotations: [AnnotationPlus] = []
    
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
        
        //Load Annotation
        let annotations = [
            AnnotationPlus.init(viewModel: DefaultCalloutViewModel.init(title: "Paris"), coordinate: CLLocationCoordinate2DMake(48.85, 2.35)),
            
            AnnotationPlus.init(viewModel: DefaultCalloutViewModel.init(title: "Geneva", subtitle: "Switzerland", imageType: .downloadable(imageURL: URL.init(string: "https://media.istockphoto.com/photos/urban-view-with-famous-fountain-geneva-switzerland-hdr-picture-id477159306?k=6&m=477159306&s=612x612&w=0&h=NwvReV5kYj0M939OkdVenOSQvU4d0eGmqJcbwx_Qsr4=")!, placeholder: #imageLiteral(resourceName: "basic_annotation_image")), theme: .light, detailButtonType: .detailDisclosure), coordinate: CLLocationCoordinate2DMake(46.2039, 6.1400)),
            
            AnnotationPlus.init(viewModel: DefaultCalloutViewModel.init(title: "Brussels", imageType: .downloadable(imageURL: URL.init(string: "https://cdn.pixabay.com/photo/2016/07/22/14/58/brussels-1534989_960_720.jpg")!, placeholder: #imageLiteral(resourceName: "basic_annotation_image")), theme: .dark, detailButtonType: .info), coordinate: CLLocationCoordinate2DMake(50.85, 4.35))
        ]
        
        MainMapViewPlus.delegate = self // Must conform to this to make it work.
        MainMapViewPlus.setup(withAnnotations: annotations)
        
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

    }
    
    //MARK - Set annotation from all data in array
    func loadCelebrityAnnotation() -> Void {
        print("Array\(celebrityArray.count)")
        
        for celebrityItem in celebrityArray {
            pin = CelebrityAnnotaion(celebrity: celebrityItem)
            MainMapView.addAnnotation(pin)
        }
    }
    
    //MARK - geoCoding the given hometown name
    func geocodingHometown(celebrity: Celebrity) {
        // A object used to append an entry to Array
        let celebrityDataModel = Celebrity()
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(celebrity.hometown ?? "beijing")&key=AIzaSyALFOLxjKHnfW4SBOw20t6hVXiUfQ4RY3E"
        
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

extension WelcomeViewController: MapViewPlusDelegate {
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        return #imageLiteral(resourceName: "basic_annotation_image")
    }
    
    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus{
        let calloutView = MapViewPlusTemplateHelper.defaultCalloutView
        
        // Below two are:
        // Required if DefaultCalloutView is being used
        // Optional if you are using your own callout view
        mapView.calloutViewCustomizerDelegate = calloutView
        mapView.anchorViewCustomizerDelegate = calloutView
        
        //Optional. Conform to this if you want button click delegate method to be called.
        calloutView.delegate = self
        
        return calloutView
    }
    
    // Optional
    func mapView(_ mapView: MapViewPlus, didAddAnnotations annotations: [AnnotationPlus]) {
        mapView.showAnnotations(annotations, animated: true)
    }
    
    // Optional. Just to show that delegate forwarding is actually working.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("This method is being forwarded to you by MapViewPlusDelegate")
    }
}

extension WelcomeViewController: DefaultCalloutViewDelegate {
    func buttonDetailTapped(with viewModel: DefaultCalloutViewModelProtocol, buttonType: DefaultCalloutViewButtonType) {
        let alert = UIAlertController(title: buttonType == .background ? "Background Tapped" : "Detail Button Tapped", message: viewModel.title + "  " + (viewModel.subtitle ?? ""), preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
}


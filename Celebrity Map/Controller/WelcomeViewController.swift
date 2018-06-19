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
    var celebrity: Celebrity
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, celebrity: Celebrity?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.celebrity = celebrity!
        
        super.init()
    }
    
    
}

class WelcomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, notifyViewDelegate {
    
    //some view Init
    var menuView: MenuBtnView?

    
    //Constants
    let APP_ID = "AIzaSyALFOLxjKHnfW4SBOw20t6hVXiUfQ4RY3E"

    
    //MARK - Initialization
    let locationManager = CLLocationManager()
    var userLocation : CLLocation? = nil
    var pin : CelebrityAnnotaion!
    var onlyOnceRemove : Int = 0
    
    var celebrityArray = [Celebrity]()
    var defaults = UserDefaults.standard
    let cetegoryArray = ["ALL", "Sport", "Political", "Art", "Science", "Technology", "Business", "Entertainment"]
    var fullCelebrityArray = [Celebrity]()


    //Mark - Firebase Initialization
    private var roofRef: DatabaseReference!

    
    //MARK - IBoutlet Intialization
    @IBOutlet weak var MainMapView: MKMapView!
    
    @IBOutlet weak var shareButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var bounceDetailView: UIView!
    
    //MARK - Notification View Initialization
    var notifyView = notificationView()
    
    //MARK - Share View Initialization
    var shareView = ShareView()
    
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
        MainMapView.delegate = self
        
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
        
        
        notifyView.generateNotificationButton(phoneFrameView: self.view, botView: self.bounceDetailView, navigationBar: (self.navigationController?.navigationBar)!)
        
        notifyView.generateCallOutView()
        notifyView.delegate = self

        
        
        setBot()
        
        //MARK - Set ShareView
        shareView.buildShareview(phoneFrame: view, frameOfTabBar: (tabBarController?.tabBar.frame)!, tabBarView: (self.tabBarController?.view)!)
        
//        shareView.buildShareview(phoneFrame: view, heightOfTabbar: (self.tabBarController?.tabBar.frame.height)!)
        
        
        
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
                            
                                newCeleberity.getCreateTime(createTimeString: celebrityDictionary["createTime"] as! String)
                                newCeleberity.address = celebrityDictionary["address"] as! String
                            //image
                            if let imageUrl = celebrityDictionary["image"]{
                                newCeleberity.imageUrl = imageUrl as? String
                            }else{
                            
                            }
                            
                            //intro text
                            if let intro = celebrityDictionary["intro"]{
                                newCeleberity.intro = intro as? String
                            }
                            
                            
                            self.celebrityArray.append(newCeleberity)
                        }
                    }
                }

                    self.dropDownAlert(title: "\(self.celebrityArray.count) Celebrities loded!")
                    self.loadCelebrityAnnotation()
                    self.notifyView.loadNotification(celebrityArray: self.celebrityArray)
                
                    //Refresh button
                    let refreshableCount = self.defaults.integer(forKey: "refresh")
                    if refreshableCount != self.celebrityArray.count {
                        self.defaults.set(self.celebrityArray.count, forKey: "refresh")
                        self.refreshBtn.isHidden = false
                        self.rotate(imageView: self.refreshBtn, aCircleTime: 3)
                    }else{
                        self.refreshBtn.isHidden = true
                    }
                
                    // Loading progress show
                    SVProgressHUD.dismiss()
                }

    }
    
    
    
    //MARK - Set annotation from all data in array
    func loadCelebrityAnnotation() -> Void {
        let selectedIndex = defaults.integer(forKey: "selectedCategory")
        let selectedCategory = cetegoryArray[selectedIndex]
        
        //Mark - bug may here!!
        fullCelebrityArray = celebrityArray

        
        if selectedIndex == 0 && onlyOnceRemove == 0{
            fullCelebrityArray = celebrityArray
        }else{
            celebrityArray = self.celebrityArray.filter { $0.category == selectedCategory}
        }
        
        for celebrityItem in celebrityArray {
            pin = CelebrityAnnotaion(coordinate: (celebrityItem.hometownLatlng!.coordinate), title: celebrityItem.name, subtitle: celebrityItem.title, celebrity: celebrityItem)
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
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        //Set popUp social sharing menu
//        showMenu()
        let active = UIActivityViewController(activityItems: ["www.google.ca"], applicationActivities: nil)
        active.popoverPresentationController?.sourceView = self.view
        self.present(active, animated: true, completion: nil)

    }
    


    
    @objc func showMenu() {
        shareButtonOutlet.isEnabled = false
        let imageNames = ["FacebookIcon", "lefttime_memo", "lefttime_riji"]
        let titleNames = [NSLocalizedString("Facebook", comment: ""), NSLocalizedString("备忘", comment: ""), NSLocalizedString("日记", comment: "")]
        menuView = MenuBtnView(frame: view.frame, imageNames: imageNames, titleNames: titleNames, isFromTabBar: false, distance: 8, selectAction: { (index) in
            
            switch index {
            case 0:
                print("Facebook")
            default:
                print("1111")
            }
            
            
            print(titleNames[index])
        })
        
        menuView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuView?.showInView(superView: view)
        menuView?.dismissBlock = { [weak self] in
            self?.menuView = nil
            self?.shareButtonOutlet.isEnabled = true
        }
    }
    
    //Bottom animation here
    
    
    //Mark - Button Init
    var locatedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var botNameLabel = UILabel(frame: CGRect(x: 20, y: 15, width: 0, height: 21))
    var botTextView = UITextView()
    var botImageDetail = UIImage()
    var botImageView = UIImageView()
    var botAddressLabel = UILabel()
    var refreshBtn = UIButton()

    func setBot(){
        
        //UIVIEW Animation
        
        self.bounceDetailView.frame = CGRect(x: 0, y: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!, width: self.view.frame.width, height: 150)
        
        
        self.bounceDetailView.clipsToBounds = true
        self.bounceDetailView.layer.cornerRadius = 25
        self.bounceDetailView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.bounceDetailView.backgroundColor = UIColor.white
        self.bounceDetailView.alpha = 0
        self.bounceDetailView.layer.borderColor = UIColor.gray.cgColor
        self.bounceDetailView.layer.borderWidth = 0.5
        //addcomponents to the botview
        
        //1. botNameLabel
        botNameLabel = UILabel(frame: CGRect(x: 20, y: 15, width: self.view.frame.width / 2 - 30, height: 21))
        botNameLabel.textAlignment = .left
        botNameLabel.text = "Yinpeng Chen"
        botNameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        botNameLabel.textColor = UIColor.black
        botNameLabel.adjustsFontSizeToFitWidth = true
        self.bounceDetailView.addSubview(botNameLabel)
        
        botAddressLabel = UILabel(frame: CGRect(x: 20, y:  botNameLabel.frame.height + 20, width: self.view.frame.width / 2 - 30, height: 12))
        botAddressLabel.textColor = UIColor.blue
        botAddressLabel.font = UIFont.boldSystemFont(ofSize: 10)
        botAddressLabel.textAlignment = .left
        botAddressLabel.text = "Charlemagne, QC, Canada"
        botAddressLabel.backgroundColor = UIColor.clear
        botAddressLabel.adjustsFontSizeToFitWidth = true
        self.bounceDetailView.addSubview(botAddressLabel)

        
        botTextView = UITextView(frame: CGRect(x: 15, y:botNameLabel.frame.height + botAddressLabel.frame.height + 25, width: botNameLabel.frame.width, height: self.bounceDetailView.frame.height - botNameLabel.frame.height - 30))
        botTextView.textColor = UIColor.gray
        botTextView.font = UIFont.systemFont(ofSize: 15.0)
        botTextView.textAlignment = .left
        botTextView.backgroundColor = UIColor.clear
        botTextView.isEditable = false
        botTextView.isSelectable = false
        botTextView.text = "Ernesto Guevara (Spanish: [ˈtʃe ɣeˈβaɾa][4] June 14, 1928 – October 9, 1967)[1][5] was an Argentine Marxist revolutionary, physician, author, guerrilla leader, diplomat and military theorist. "
        self.bounceDetailView.addSubview(botTextView)
        
        //share and more button and label
        let botShareBtn = UIButton(frame: CGRect(x: botNameLabel.frame.width + 15, y: botNameLabel.frame.origin.y - 5, width: 50, height: 50))
        botShareBtn.backgroundColor = UIColor.clear
        botShareBtn.setImage(UIImage(named: "shareBtn"), for: .normal)
        botShareBtn.center.x = self.view.frame.width / 2 + botShareBtn.frame.width / 2 + 5
        botShareBtn.center.y = self.bounceDetailView.frame.height * 1 / 4
        self.bounceDetailView.addSubview(botShareBtn)

        let botMoreBtn = UIButton(frame: CGRect(x: botNameLabel.frame.width + 15, y: botNameLabel.frame.origin.y - 5, width: 50, height: 50))
        botMoreBtn.backgroundColor = UIColor.clear
        botMoreBtn.setImage(UIImage(named: "moreBtn"), for: .normal)
        botMoreBtn.center.x = botShareBtn.center.x
        botMoreBtn.center.y = self.bounceDetailView.frame.height * 3 / 4
        self.bounceDetailView.addSubview(botMoreBtn)
        
        //Draw seperating line
        let midLine = UIView(frame: CGRect(x: 20, y: 0, width: 1, height: self.bounceDetailView.frame.height - 60))
        midLine.center.x = botShareBtn.frame.minX - 10
        midLine.backgroundColor = UIColor.gray
        midLine.center.y = self.bounceDetailView.frame.height / 2
        self.bounceDetailView.addSubview(midLine)
        
        let RightLine = UIView(frame: CGRect(x: 20, y: 0, width: 1, height: midLine.frame.height))
        RightLine.center.x = botShareBtn.frame.maxX + 10
        RightLine.backgroundColor = UIColor.gray
        RightLine.center.y = self.bounceDetailView.frame.height / 2
        self.bounceDetailView.addSubview(RightLine)


        
        //bot Image
        botImageDetail = UIImage(named: "blank_portrait")!
        botImageView = UIImageView(image: botImageDetail)
        botImageView.frame = CGRect(x: self.bounceDetailView.frame.width / 2 + botShareBtn.frame.width + 30, y: 100, width: self.bounceDetailView.frame.width / 2 - botShareBtn.frame.width - 50, height: self.bounceDetailView.frame.height - 20)
        botImageView.center.y = self.bounceDetailView.frame.height / 2
        botImageView.layer.cornerRadius = 10
        botImageView.contentMode = .scaleAspectFit
        botImageView.clipsToBounds = true
        self.bounceDetailView.addSubview(botImageView)
        
        //Top indicator short line
        let topLine = UIView(frame: CGRect(x: 20, y: 0, width: 20, height: 2))
        topLine.center.x = self.bounceDetailView.frame.width / 2
        topLine.backgroundColor = UIColor.gray
        topLine.layer.cornerRadius = 25
        topLine.center.y = 10
        self.bounceDetailView.addSubview(topLine)

        //located button
        locatedButton.backgroundColor = UIColor.clear
        locatedButton.setImage(UIImage(named: "LocateMe"), for: .normal)
        locatedButton.center.x = self.view.frame.width - 65
        locatedButton.center.y = self.bounceDetailView.frame.minY - 65
        locatedButton.backgroundColor = UIColor.white
        locatedButton.layer.cornerRadius = locatedButton.frame.size.width/2
        locatedButton.clipsToBounds = true
        locatedButton.layer.borderColor = UIColor.white.cgColor
        locatedButton.layer.borderWidth = 5.0
        locatedButton.addTarget(self, action: #selector(locatedMeButtonClicked), for: .touchUpInside)
        self.view.addSubview(locatedButton)
        
        refreshBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        refreshBtn.backgroundColor = UIColor.clear
        refreshBtn.setImage(UIImage(named: "refresh"), for: .normal)
        refreshBtn.center.x = self.view.frame.width - 65
        refreshBtn.center.y = 65 + notifyView.topHeights()
        refreshBtn.backgroundColor = UIColor.clear
        refreshBtn.layer.cornerRadius = notifyView.notiBtn().frame.size.width/2
        refreshBtn.clipsToBounds = true
        refreshBtn.layer.borderColor = UIColor.clear.cgColor
        refreshBtn.isHidden = true
        
        refreshBtn.addTarget(self, action: #selector(refreshClicked), for: .touchUpInside)
        self.view.addSubview(refreshBtn)
        }
    
    //MARK - Animation for bounceview
    func botViewAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.bounceDetailView.frame.origin.y -= self.bounceDetailView.frame.height
            self.bounceDetailView.alpha = 1
            
            self.locatedButton.frame.origin.y -= self.bounceDetailView.frame.height
        }, completion: nil)
    }
    
    func botViewAnimationReverse(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.bounceDetailView.frame.origin.y += self.bounceDetailView.frame.height
            self.bounceDetailView.alpha = 0
            
            self.locatedButton.frame.origin.y += self.bounceDetailView.frame.height
        }, completion: nil)
        
    }
    
    //MARK - Tap annotation and responder
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // first ensure that it really is an EventAnnotation:
        if let eventAnnotation = view.annotation as? CelebrityAnnotaion {
            let theEvent = eventAnnotation.title
            // now do somthing with your event
            botNameLabel.text = "\(theEvent!)"
            botTextView.text = "\(eventAnnotation.celebrity.title)"
            
            botAddressLabel.text = "\(eventAnnotation.celebrity.address!)"
            
            //Set intro
            if eventAnnotation.celebrity.intro != nil && eventAnnotation.celebrity.intro != ""{
                botTextView.text = "\(eventAnnotation.celebrity.intro!)"
            }else{
                botTextView.text = "\(eventAnnotation.celebrity.title)"
            }
            
            //Set imageview
            if eventAnnotation.celebrity.imageUrl != nil && eventAnnotation.celebrity.imageUrl != ""{
                            if let url = URL(string: "\(eventAnnotation.celebrity.imageUrl!)") {
                                do {
                                    let data: Data = try Data(contentsOf: url)
                                    self.botImageView.image = UIImage(data: data)
                                } catch {
                                    // error handling
                                }
                }
            }
            
            botViewAnimation()
        }
    }
    
    func mapView(_ mapView: MKMapView,
                 didDeselect view: MKAnnotationView){
        botViewAnimationReverse()
        
        //Delay to change image back to default
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { // change 2 to desired number of seconds
//            // Your code with delay
//            self.botImageView.image = UIImage(named: "blank_portrait")
//        }
        
//        self.botImageView.image = UIImage(named: "blank_portrait")
        self.bounceDetailView.frame = CGRect(x: 0, y: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!, width: self.view.frame.width, height: 150)
        self.locatedButton.center.y = self.bounceDetailView.frame.minY - 65
    }
    
    
    @IBAction func refreshClicked(_ sender: UIButton) {
        loadCelebrity()
    }
    
    func returnView() -> UIView{
        return self.view
    }
    
    func changeLocatedButton() {
        if self.locatedButton.isHidden == false {
            self.locatedButton.isHidden = true
        }else{
            self.locatedButton.isHidden = false
        }
    }
    
    func refreshButtonRotate(){
        UIView.animate(withDuration: 2) {
            self.refreshBtn.transform.rotated(by: 360)
        }
    }
    

    func rotate(imageView: UIButton, aCircleTime: Double) { //CABasicAnimation
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi * 2 //Minus can be Direction
        rotationAnimation.duration = aCircleTime
        rotationAnimation.repeatCount = .infinity
        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    
        
}



    


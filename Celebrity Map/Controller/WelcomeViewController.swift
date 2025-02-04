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
import AppsFlyerLib


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

class WelcomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, notifyViewDelegate, reportDelegate {
    
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
    var publishSwitch = ""
    

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
    
    //MARK - Report View Initialization
    var ReportView = reportView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Register the Mapview
//        MainMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        publishSwitch = "\(UIDevice.current.identifierForVendor?.uuidString ?? "noid")"
        
        print("publicswitch")
        
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
        
        hideTabbar()

        
        notifyView.generateNotificationButton(phoneFrameView: self.view, botView: self.bounceDetailView, navigationBar: (self.navigationController?.navigationBar)!)
        
        notifyView.generateCallOutView()
        notifyView.delegate = self

        //Report view
        ReportView.startReportView(phoneFrame: self.view, botView: self.MainMapView, navigationBar: (self.navigationController?.navigationBar)!)
        ReportView.delegate = self
        

        
        setBot()
        

        
        //MARK - Set ShareView
        shareView.buildShareview(phoneFrame: view, frameOfTabBar: (tabBarController?.tabBar.frame)!, tabBarView: (self.tabBarController?.view)!)
        
        MainMapView.register(CelebrityAnnoView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        
        //Mark - Notification Module
        
        
        SVProgressHUD.dismiss()
        
    }
    
    

    
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
                            newCeleberity.address = (celebrityDictionary["address"] as! String)
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

                    self.loadCelebrityAnnotation()
                    self.notifyView.loadNotification(celebrityArray: self.celebrityArray)
                
                    //Refresh button
                    let refreshableCount = self.defaults.integer(forKey: "refresh")
//                    self.dropDownAlert(title: "\(self.celebrityArray.count) Celebrities loded!")
                    if refreshableCount != self.celebrityArray.count {
                        self.defaults.set(self.celebrityArray.count, forKey: "refresh")
                        
                        //Refresh button rotate and appear
                        self.refreshBtn.isHidden = false
                        self.rotate(imageView: self.refreshBtn, aCircleTime: 2)
                        
                        let convertedArray = self.celebrityArray.sorted(by: { $0.createTime! > $1.createTime! })
                        self.dropDownAlert(title: "<\(convertedArray.first!.name)> has been added by Programmer!")
                    }else{
                        self.refreshBtn.isHidden = true
                    }
                    // Load reportView
                if self.userLocation != nil && self.celebrityArray.count > 0{
                        self.nearestReport()
                    }
                
                    // Loading progress show
                    SVProgressHUD.dismiss()
                }

    }
    
    
    // Array to store place celebrity
    var placedPin = [String]()
    
    //MARK - Set annotation from all data in array
    func loadCelebrityAnnotation() -> Void {
        let selectedIndex = defaults.integer(forKey: "selectedCategory")
        let selectedCategory = cetegoryArray[selectedIndex]
        
        //Mark - bug may here!!
        fullCelebrityArray = celebrityArray
        
        
        if selectedIndex == 0 || onlyOnceRemove == 0{
            
        }else{
            celebrityArray = self.celebrityArray.filter { $0.category == selectedCategory}
        }
        onlyOnceRemove += 1
        
        if ifRefreshOutside {
            MainMapView.removeAnnotations(MainMapView.annotations)
            placedPin.removeAll()
        }
        
        for celebrityItem in celebrityArray {
            
            if !placedPin.contains(celebrityItem.name){
                pin = CelebrityAnnotaion(coordinate: (celebrityItem.hometownLatlng!.coordinate), title: celebrityItem.name, subtitle: celebrityItem.address, celebrity: celebrityItem)

            
                // juage if shop on maprect: must in maprect
                if mapingRect != nil {
                    if (mapingRect?.checkIfInside(point: (celebrityItem.hometownLatlng?.coordinate)!))!{
                            MainMapView.addAnnotation(pin)
                            placedPin.append(pin.title!)
                    }
                }
            }
            
//            else{
//                MainMapView.removeAnnotation(pin)
//            }
            
        }
        celebrityArray = fullCelebrityArray

    }
    
    //MARK - Back to user location
    func userLocation(location : CLLocation){
        
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            let span:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 10, longitudeDelta: 10)
            let userLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegion.init(center: userLocation, span: span)
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
    var locatedButton = UIButton()
    var botNameLabel = UILabel(frame: CGRect(x: 20, y: 15, width: 0, height: 21))
    var botTextView = UITextView()
    var botImageDetail = UIImage()
    var botImageView = UIImageView()
    var botAddressLabel = UILabel()
    var refreshBtn = UIButton()

    func setBot(){
        let btnSize = self.view.frame.height / 15
        
        //UIVIEW Animation
        if publishSwitch == "59B12E56-EBC8-4CEA-8AC5-88CAAF41F39C" {
            self.bounceDetailView.frame = CGRect(x: 0, y: self.view.frame.height -         (self.tabBarController?.tabBar.frame.height)!, width: self.view.frame.width, height: 150)
        }else{
            self.bounceDetailView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200)
        }
        
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
        botShareBtn.addTarget(self, action: #selector(shareToButtonClicked), for: .touchUpInside)
        self.bounceDetailView.addSubview(botShareBtn)

        let botMoreBtn = UIButton(frame: CGRect(x: botNameLabel.frame.width + 15, y: botNameLabel.frame.origin.y - 5, width: 50, height: 50))
        botMoreBtn.backgroundColor = UIColor.clear
        botMoreBtn.setImage(UIImage(named: "moreBtn"), for: .normal)
        botMoreBtn.center.x = botShareBtn.center.x
        botMoreBtn.center.y = self.bounceDetailView.frame.height * 3 / 4
        botMoreBtn.addTarget(self, action: #selector(moreBtnClicked), for: .touchUpInside)
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

        //shadow view
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 1
        outerView.layer.shadowOffset = CGSize.zero
        outerView.layer.shadowRadius = 25
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 25).cgPath

        
        //bot Image
        botImageDetail = UIImage(named: "blank_portrait")!
        botImageView = UIImageView(image: botImageDetail)
        let heightIndex = self.bounceDetailView.frame.height  - 30
        botImageView.frame = CGRect(x: RightLine.frame.maxX + 30, y: 100, width: ((self.view.frame.width - RightLine.frame.maxX) - 30), height: heightIndex)
        botImageView.center.x = (self.view.frame.width - RightLine.frame.maxX) / 2 + RightLine.frame.maxX
        botImageView.center.y = self.bounceDetailView.frame.height / 2
        botImageView.layer.cornerRadius = 25
        botImageView.contentMode = .scaleAspectFill
        botImageView.clipsToBounds = true
        outerView.addSubview(botImageView)
        self.bounceDetailView.addSubview(botImageView)
        
        
        
        //Top indicator short line
//        let topLine = UIView(frame: CGRect(x: 20, y: 0, width: 20, height: 2))
//        topLine.center.x = self.bounceDetailView.frame.width / 2
//        topLine.backgroundColor = UIColor.gray
//        topLine.layer.cornerRadius = 25
//        topLine.center.y = 10
//        self.bounceDetailView.addSubview(topLine)

        //located button
        locatedButton = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        locatedButton.backgroundColor = UIColor.clear
        locatedButton.setImage(UIImage(named: "LocateMe"), for: .normal)
        locatedButton.center.x = self.view.frame.width - 65
        locatedButton.center.y = self.bounceDetailView.frame.minY - 65
        locatedButton.backgroundColor = UIColor.white
        locatedButton.layer.cornerRadius = locatedButton.frame.size.width/2
        locatedButton.clipsToBounds = true
        locatedButton.layer.borderColor = UIColor.white.cgColor
        locatedButton.layer.borderWidth = 5.0
        locatedButton.layer.zPosition = 2
        locatedButton.addTarget(self, action: #selector(locatedMeButtonClicked), for: .touchUpInside)
        self.view.addSubview(locatedButton)
        
        refreshBtn = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
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
        
//        changetitle()
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
            
            botAddressLabel.text = "\(eventAnnotation.celebrity.title)"
            
            //Set intro
            if eventAnnotation.celebrity.intro != nil && eventAnnotation.celebrity.intro != ""{
                botTextView.text = "\(eventAnnotation.celebrity.intro!)"
            }else{
                botTextView.text = "\(eventAnnotation.celebrity.title)"
            }
            
            //Set imageview
            var problemOccur = 0
            shareView.currentAnnotationCelebrity = eventAnnotation.celebrity
            if var imageTempo = getSavedImage(named: eventAnnotation.celebrity.name){
                let imageHeightIndex = imageTempo.size.height
                imageTempo = cropToBounds(image: imageTempo, width: Double(imageHeightIndex * 3 / 4), height: Double(imageHeightIndex))
                eventAnnotation.celebrity.portrait = imageTempo
            } else {
                problemOccur = 1
            }
            

            
            if eventAnnotation.celebrity.portrait == UIImage(named: "blank_portrait")! || problemOccur == 1{
                    if let url = URL(string: "\(eventAnnotation.celebrity.imageUrl!)"){
                    do {
                        SVProgressHUD.show()
                        let data: Data = try Data(contentsOf: url)
                        if var imageTempo = UIImage(data: data){
                            let imageHeightIndex = imageTempo.size.height
                        
                        
                            imageTempo = cropToBounds(image: imageTempo, width: Double(imageHeightIndex * 3 / 4), height: Double(imageHeightIndex))
                        
                            _ = saveImage(image: imageTempo, name: "\(eventAnnotation.celebrity.name)")
                            eventAnnotation.celebrity.portrait = imageTempo
                            problemOccur = 0}
                        SVProgressHUD.dismiss()
                    } catch {
                        // error handling
                        eventAnnotation.celebrity.portrait = UIImage(named: "blank_portrait")!
                    }
                    
                }
            }
            //Set the imageview on bot frame
            self.botImageView.image = eventAnnotation.celebrity.portrait
            botViewAnimation()
        }
    }
    
    func mapView(_ mapView: MKMapView,
                 didDeselect view: MKAnnotationView){
        botViewAnimationReverse()
        
        confirmBounceView()
    }
    
    var mapingRect : mapRect?
    var ifRefreshOutside : Bool = false
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let rect = MainMapView.visibleMapRect
        let mapPoint = MKMapPoint.init(x: rect.origin.x, y: rect.origin.y)
        let coordinate = mapPoint.coordinate

        if let ifRefresh = mapingRect?.checkIfRefresh(newTop: coordinate.latitude, newBot: coordinate.latitude - mapView.region.span.latitudeDelta, newLeft: coordinate.longitude, newRight: coordinate.longitude + mapView.region.span.longitudeDelta, time: onlyOnceRemove){
            
            ifRefreshOutside = ifRefresh

        }
        
        mapingRect = mapRect(Top: coordinate.latitude, Bot: coordinate.latitude - mapView.region.span.latitudeDelta, Left: coordinate.longitude, Right: coordinate.longitude + mapView.region.span.longitudeDelta)
//        let judge = mapingRect?.checkIfInside(point: CLLocationCoordinate2D(latitude: 44.6458149, longitude: -63.4534447))
        
        
        loadCelebrityAnnotation()
    }
    
    
    @IBAction func refreshClicked(_ sender: UIButton) {
        loadCelebrity()
        let today = self.defaults.integer(forKey: "todayUpdate")
        self.dropDownAlert(title: "\(today) new celebries loaded, enjoy!")
    }
    
    @IBAction func moreBtnClicked(_ sender: UIButton) {        
        self.performSegue(withIdentifier: "web", sender: sender)
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
    
    @IBAction func shareToButtonClicked(_ sender: UIButton) {
        shareView.callOutShareView(switchs: 0)
//        let shareURL = NSURL(string: "http://www.google.com")
//        let image = shareView.currentAnnotationCelebrity.portrait
//        
//        let text = "Do you konw \(shareView.currentAnnotationCelebrity.name) is a \(shareView.currentAnnotationCelebrity.category ?? "???") celebrity come from \(shareView.currentAnnotationCelebrity.address ?? "??"). Check your interest celebrity with IOS APP: Celebrity Map!"
//        
//        let active = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
        //            active.popoverPresentationController?.sourceView = currentView?.view
//        self.present(active, animated: true, completion: nil)
        
    }

    

    func rotate(imageView: UIButton, aCircleTime: Double) { //CABasicAnimation
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi * 2 //Minus can be Direction
        rotationAnimation.duration = aCircleTime
        rotationAnimation.repeatCount = .infinity
        imageView.layer.add(rotationAnimation, forKey: nil)
    }
    
    
    //MARK - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "web" {
            guard let webVC = segue.destination as? WebViewController else { print("???failded web")
                return}
        
            webVC.gotCelebrity = shareView.currentAnnotationCelebrity
        }
    }
    
    //MARK - Change the title of navibar button
    func changetitle() {
        
        let filterButton = UIButton(type: .custom)
        filterButton.setImage(UIImage(named: "weibo"), for: .normal)
        filterButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        filterButton.addTarget(self, action: #selector(Class.Methodname), for: .touchUpInside)
        //Assign that UIButton to UIBarButtonItem
        let item1 = UIBarButtonItem(customView: filterButton)
        
        //set UIBarButtonItem to navigationItem
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    //Mark - set tab bar hidden
    func hideTabbar(){
        if publishSwitch == "59B12E56-EBC8-4CEA-8AC5-88CAAF41F39C"{
            self.tabBarController?.tabBar.isHidden = false
        }else{
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    //Mark - confirm the locatoin of bounce view
    func confirmBounceView(){
        if publishSwitch == "59B12E56-EBC8-4CEA-8AC5-88CAAF41F39C" {
        self.bounceDetailView.frame = CGRect(x: 0, y: self.view.frame.height -         (self.tabBarController?.tabBar.frame.height)!, width: self.view.frame.width, height: 150)
            self.locatedButton.center.y = (self.tabBarController?.tabBar.frame.minY)! - 65

        }else{
        self.bounceDetailView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200)
        self.locatedButton.center.y = self.bounceDetailView.frame.minY - 65
        }
    }
    
    //MARK - Save and Load Image locally
    func saveImage(image: UIImage, name: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(name).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
//            posX = ((contextSize.width - contextSize.height) / 2)
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = 10
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func reportOn(){
        locatedButton.isHidden = true
    }
    
    func reportOff(){
        locatedButton.isHidden = false
        shareView.blackBackground.isHidden = true
    }
    
    var shortestCelebrityName = ""
    func nearestReport(){
        
        
        var shortestDistance = 100000000.0
        var shortestCelebrity = Celebrity()
                
        for celebrityItem in celebrityArray{
            
            if (userLocation?.distance(from: celebrityItem.hometownLatlng!))! < shortestDistance{
                shortestDistance = (userLocation?.distance(from: celebrityItem.hometownLatlng!))!
                shortestCelebrity = celebrityItem
            }
        }
        
        if let url = URL(string: "\(shortestCelebrity.imageUrl!)"){
            do {
                let data: Data = try Data(contentsOf: url)
                if var imageTempo = UIImage(data: data){
                    let imageHeightIndex = imageTempo.size.height
                    
                    
                    imageTempo = cropToBounds(image: imageTempo, width: Double(imageHeightIndex * 3 / 4), height: Double(imageHeightIndex))
                    
                    _ = saveImage(image: imageTempo, name: "\(shortestCelebrity.name)")
                    shortestCelebrity.portrait = imageTempo
                }
                
            } catch {
                // error handling
                shortestCelebrity.portrait = UIImage(named: "blank_portrait")!
            }
        }
        
        let storedNearest = self.defaults.string(forKey: "nearest")
        if (storedNearest != nil){
        }
        
        if storedNearest == shortestCelebrity.name{
            
        }else{
            ReportView.callOutSet(type: 0, name: "\(shortestCelebrity.name)", address: "\(shortestCelebrity.address ?? "???")", distance: shortestDistance, image: shortestCelebrity.portrait, shortest: shortestCelebrity)
            
            locatedButton.isHidden = true
            ReportView.motherView.isHidden = false

            self.defaults.set(shortestCelebrity.name, forKey: "nearest")
        }
    }
    
//    func sendLink(){
//        let message =  WXMediaMessage()
//        
//        message.title = "欢迎访问 hangge.com"
//        message.description = "做最好的开发者知识平台。分享各种编程开发经验。"
//        message.setThumbImage(UIImage(named:"apple.png"))
//        
//        let ext =  WXWebpageObject()
//        ext.webpageUrl = "http://hangge.com"
//        message.mediaObject = ext
//        
//        let req =  SendMessageToWXReq()
//        req.bText = false
//        req.message = message
//        req.scene = scene
//        WXApi.send(req)
//    }
        
    
    
}

extension MKMapView {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.visibleMapRect.contains(MKMapPoint.init(coordinate))
    }
    
}
    


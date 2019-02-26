//
//  SubmitViewController.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-14.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire
import SwiftyJSON
import CoreLocation
import WebKit

class SubmitViewController: UIViewController, UIPickerViewDelegate,
UIPickerViewDataSource, UITextFieldDelegate {
    // Variable Initialization
    var selectedPickerViewItem : String = "Sport"
    var celebrityArray = [Celebrity]()
    
    
    // Outlet Initialization
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titles: UITextField!
    @IBOutlet weak var hometownTextField: UITextField!
    @IBOutlet weak var categoryPickerViewOutlet: UIPickerView!
    
    @IBOutlet weak var webDataView: WKWebView!
    
    @IBOutlet weak var ImageIndicator: UILabel!
    
    @IBOutlet weak var IntroIndicator: UILabel!
    
    var pickerViewArray = ["Sport", "Political", "Art", "Science", "Technology", "Business", "Entertainment"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate of Pickerview
        self.categoryPickerViewOutlet.delegate = self
        self.categoryPickerViewOutlet.dataSource = self
        
        //Delegate of Textfield
        self.hometownTextField.delegate = self
        
        //Webview setting
        setWebView()
        
        //Set Gesture
        setGesture()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func submitButtonClicked(_ sender: UIButton) {
        let elementAdded = Celebrity(name: nameTextField.text!, hometown: hometownTextField.text!, title: titles.text!, category: selectedPickerViewItem)
        elementAdded.imageUrl = ImageIndicator.text
        elementAdded.intro = IntroIndicator.text
        insertCelebrityData(celebrity: elementAdded)
        sender.shake()
    }

    //MARK - Pickview Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerViewItem = pickerViewArray[row]
    }
    
    //MARK - Connect to google firebase and geocoding API
    func insertCelebrityData(celebrity: Celebrity) {
        // A object used to append an entry to Array
        let celebrityDataModel = Celebrity()

        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(celebrity.hometown?.replacingOccurrences(of: " ", with: "+") ?? "beijing")&key=AIzaSyALFOLxjKHnfW4SBOw20t6hVXiUfQ4RY3E"
        
        celebrityDataModel.name = celebrity.name
        celebrityDataModel.title = celebrity.title
        celebrityDataModel.hometown = celebrity.hometown
        celebrityDataModel.category = celebrity.category
        celebrityDataModel.intro = celebrity.intro
        celebrityDataModel.imageUrl = celebrity.imageUrl
        
        Alamofire.request(url).responseJSON { response in
            //            print(response.request)  // original URL request
            //            print(response.response) // HTTP URL response
            //            print(response.data)     // server data
            //            print(response.result)   // result of response serialization
            
            if let returnJson : JSON = JSON(response.result.value!){
            celebrityDataModel.parseJSON(json: returnJson)
            celebrityDataModel.saveToFirebase()
                
            let alert = UIAlertController(title: "Alert", message: "Entry succeed", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in print("Good")
                
                self.titles.isEnabled = false
                self.nameTextField.isEnabled = false
                self.hometownTextField.isEnabled = false
                
                self.titles.text = ""
                self.nameTextField.text = ""
                self.hometownTextField.text = ""
                
                self.titles.isEnabled = true
                self.nameTextField.isEnabled = true
                self.hometownTextField.isEnabled = true
                self.ImageIndicator.text="Image ->"
                self.IntroIndicator.text="Intro -up"

                
                self.view.endEditing(true)
            }))
            self.present(alert, animated: true, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "Alert", message: "Entry failed", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in print("Failed")}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK - Return keyborad for textfield
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //MARK - Set webview
    func setWebView(){
        let url = URL(string: "https://www.google.ca/")
        let request = URLRequest(url: url!)
        webDataView.load(request)
        
        webDataView.layer.borderWidth = 1
        webDataView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        webDataView.allowsBackForwardNavigationGestures = true
    }
    
    //MARK - Set auto paste functions
    @objc func pasteToName() {
        let pb: UIPasteboard = UIPasteboard.general;
        nameTextField.text  = pb.string
    }
    
    @objc func pasteToHome() {
        let pb: UIPasteboard = UIPasteboard.general;
        hometownTextField.text  = pb.string
    }
    
    @objc func pasteToTitle() {
        let pb: UIPasteboard = UIPasteboard.general;
        titles.text  = pb.string
    }
    
    @objc func pasteToImage() {
        let pb: UIPasteboard = UIPasteboard.general;
        ImageIndicator.text  = pb.string
    }
    
    @objc func pasteToIntro() {
        let pb: UIPasteboard = UIPasteboard.general;
        IntroIndicator.text  = pb.string
    }
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
        
    }
    
    func setGesture(){
        //Auto paste Right -> Name
        var swipeRight = UISwipeGestureRecognizer()
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(pasteToImage as () -> Void))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        //Auto paste Left -> Home
        var swipeLeft = UISwipeGestureRecognizer()
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(pasteToName as () -> Void))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        //Auto paste Longpress -> Title
        var longPress = UILongPressGestureRecognizer()
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(pasteToHome as () -> Void))
        longPress.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPress)
        
        //Auto paste Up -> Image
        var swipeUp = UISwipeGestureRecognizer()
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(pasteToIntro as () -> Void))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        
        //Auto paste Down -> INTRO
        var swipeDown = UISwipeGestureRecognizer()
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(pasteToTitle as () -> Void))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
    

    }
    
}

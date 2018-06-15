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

class SubmitViewController: UIViewController, UIPickerViewDelegate,
UIPickerViewDataSource {
    // Variable Initialization
    var selectedPickerViewItem : String = ""
    var celebrityArray = [Celebrity]()

    // Firebase
    private var roofRef: DatabaseReference!

    
    // Outlet Initialization
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titles: UITextField!
    @IBOutlet weak var hometownTextField: UITextField!
    @IBOutlet weak var categoryPickerViewOutlet: UIPickerView!
    
    var pickerViewArray = ["Sport", "Political", "Art", "Science", "Technology", "Business"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate of Pickerview
        self.categoryPickerViewOutlet.delegate = self
        self.categoryPickerViewOutlet.dataSource = self
        self.selectedPickerViewItem = "Sport"
        
        //connect to Firebase
        self.roofRef = Database.database().reference()
        
        // Do any additional setup after loading the view.
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
        let elementAdded = Celebrity(name: nameTextField.text!, hometown: hometownTextField.text!, title: titles.text!)
        geocodingHometown(celebrity: elementAdded)
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
            
            if let returnJson : JSON = JSON(response.result.value!){
            celebrityDataModel.parseJSON(json: returnJson)
            self.insertDataToFirebase(celebrityDataModel: celebrityDataModel)
            }else{
                let alert = UIAlertController(title: "Alert", message: "Entry failed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in print("Failed")}))
                self.present(alert, animated: true, completion: nil)
            }
            
            

        }
        
    }
    
    func parseJSON(json : JSON) -> CLLocation {
        
        let parsedLatlon : CLLocation = CLLocation(latitude: json["results"][0]["geometry"]["location"]["lat"].doubleValue, longitude: json["results"][0]["geometry"]["location"]["lng"].doubleValue)
        
        
        return parsedLatlon
    }
    
    //MARK - Get current time
    func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTime = formatter.string(from: Date())
        return currentTime
    }
    
    //Mark - Insert data to firebase
    func insertDataToFirebase(celebrityDataModel : Celebrity) {
        
        let celebrityRef = self.roofRef.child("celebrity")
        let idRef = celebrityRef.childByAutoId()
        
        idRef.child("name").setValue(celebrityDataModel.name)
        
        idRef.child("lat").setValue(celebrityDataModel.hometownLatlng?.coordinate.latitude)
        idRef.child("lng").setValue(celebrityDataModel.hometownLatlng?.coordinate.longitude)
        
        idRef.child("hometown").setValue(celebrityDataModel.hometown)
        idRef.child("title").setValue(celebrityDataModel.title)

        idRef.child("address").setValue(celebrityDataModel.address)
        idRef.child("category").setValue("\(self.selectedPickerViewItem)")
        idRef.child("createTime").setValue(self.getCurrentDateTime())
        
        
        let alert = UIAlertController(title: "Alert", message: "New entry added", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            print("finish")
            self.nameTextField.text = ""
            self.hometownTextField.text = ""
            self.titles.text = ""
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

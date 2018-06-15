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
UIPickerViewDataSource, UITextFieldDelegate {
    // Variable Initialization
    var selectedPickerViewItem : String = "Sport"
    var celebrityArray = [Celebrity]()

  
    
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
        
        //Delegate of Textfield
        self.hometownTextField.delegate = self
        
        
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
        let elementAdded = Celebrity(name: nameTextField.text!, hometown: hometownTextField.text!, title: titles.text!, category: selectedPickerViewItem)
        insertCelebrityData(celebrity: elementAdded)
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

        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(celebrity.hometown?.replacingOccurrences(of: " ", with: "-") ?? "beijing")&key=AIzaSyALFOLxjKHnfW4SBOw20t6hVXiUfQ4RY3E"
        
        celebrityDataModel.name = celebrity.name
        celebrityDataModel.title = celebrity.title
        celebrityDataModel.hometown = celebrity.hometown
        celebrityDataModel.category = celebrity.category
        
        Alamofire.request(url).responseJSON { response in
            //            print(response.request)  // original URL request
            //            print(response.response) // HTTP URL response
            //            print(response.data)     // server data
            //            print(response.result)   // result of response serialization
            
            if let returnJson : JSON = JSON(response.result.value!){
            celebrityDataModel.parseJSON(json: returnJson)
            celebrityDataModel.saveToFirebase()
                
            let alert = UIAlertController(title: "Alert", message: "Entry succeed", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in print("Good")
                self.nameTextField.text = ""
                self.hometownTextField.text = ""
                self.titles.text = ""
                self.view.endEditing(true)
            }))
            self.present(alert, animated: true, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "Alert", message: "Entry failed", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in print("Failed")}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK - Return keyborad for textfield
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

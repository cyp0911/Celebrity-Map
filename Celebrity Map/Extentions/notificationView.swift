//
//  notificationView.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-17.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import SVProgressHUD

protocol notifyViewDelegate{
    func changeLocatedButton()
}

class notificationView{
    var notificationButton = UIButton()
    var notificationView = UIView()
    var screenView = UIView()
    var topHeight : CGFloat?
    var callOutView = UIView()
    
    var callOutViewSwitch : Bool = false
    var cancelButton = UIButton()
    var notificationImageView = UIImageView()
    var notificationTitle = UILabel()
    var blackBackground = UIView()
    var locateButton = UIButton()
    var notiBoard = UITextView()
    
    var delegate: notifyViewDelegate?
    var defaults = UserDefaults.standard


    //Mark - Firebase Initialization
    private var roofRef: DatabaseReference!
    
    init() {
    }
    
    //MARK - Generate a notificationButton
    func generateNotificationButton(phoneFrameView : UIView, botView: UIView, navigationBar: UINavigationBar){
        //navigation bar height
        self.screenView = phoneFrameView
        
        let heightofNavigationBar = navigationBar.frame.height
        let heightofStatusBar = UIApplication.shared.statusBarFrame.height
        topHeight = heightofNavigationBar + heightofStatusBar
        
        
        
        //noti button
        notificationButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        notificationButton.backgroundColor = UIColor.clear
        notificationButton.setImage(UIImage(named: "email"), for: .normal)
        notificationButton.center.x = 65
        notificationButton.center.y = 65 + topHeight!
        notificationButton.backgroundColor = UIColor.clear
        notificationButton.layer.cornerRadius = notificationButton.frame.size.width/2
        notificationButton.clipsToBounds = true
        notificationButton.layer.borderColor = UIColor.clear.cgColor
        
        notificationButton.addTarget(self, action: #selector(notificationButtonClicked), for: .touchUpInside)
        phoneFrameView.addSubview(notificationButton)
    }
    
    
    //MARK - View of call out by the notification button
    func generateCallOutView() {
        callOutView = UIView(frame: CGRect(x: 100, y: topHeight! + 100, width: self.screenView.frame.width * 3 / 4, height: self.screenView.frame.height * 2 / 3))
        callOutView.center.x = self.screenView.frame.width / 2
        callOutView.center.y = self.screenView.frame.height / 2
        callOutView.clipsToBounds = true
        self.callOutView.layer.cornerRadius = 25
        callOutView.autoresizesSubviews = true
        self.callOutView.backgroundColor = UIColor.white
        callOutView.isHidden = true
        
        calloutViewItems()
        
        screenView.addSubview(callOutView)
    }
    
   
    
    //MARK - CallOutView Components
    func calloutViewItems(){
        cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        cancelButton.backgroundColor = UIColor.clear
        
        cancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        cancelButton.center.x = callOutView.frame.width / 2
        cancelButton.center.y = callOutView.frame.height - 50
        cancelButton.backgroundColor = UIColor.clear
        
        cancelButton.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        callOutView.addSubview(cancelButton)
        
        //Imageview
        notificationImageView = UIImageView(image: UIImage(named: "notification"))
        notificationImageView.frame = CGRect(x: 0, y: 5, width:100, height: 100)
        notificationImageView.center.x = self.callOutView.frame.width / 2
        callOutView.addSubview(notificationImageView)

        
        //title
        notificationTitle = UILabel(frame: CGRect(x: 0, y: notificationImageView.frame.maxY + 10, width: callOutView.frame.width - 100, height: 26))
        notificationTitle.text = "Celebrity Updates"
        notificationTitle.center.x = callOutView.frame.width / 2
        notificationTitle.textColor = UIColor.black
        notificationTitle.font = UIFont.boldSystemFont(ofSize: 25)
        notificationTitle.adjustsFontSizeToFitWidth = true
        notificationTitle.textAlignment = .center
        notificationTitle.backgroundColor = UIColor.clear
        callOutView.addSubview(notificationTitle)
        
        //notiboard
        notiBoard = UITextView(frame: CGRect(x: 0, y: notificationTitle.frame.maxY + 15, width: callOutView.frame.width - 30, height: cancelButton.frame.minY - notificationTitle.frame.maxY - 30))
        notiBoard.center.x = callOutView.frame.width / 2
        notiBoard.textColor = UIColor.black
        notiBoard.font = UIFont.systemFont(ofSize: 15.0)
        notiBoard.textAlignment = .left
        notiBoard.backgroundColor = UIColor.clear
        notiBoard.isEditable = false
        notiBoard.text = "Sorry, Internet disconnected"
        notiBoard.allowsEditingTextAttributes = false
        notiBoard.isSelectable = false
        notiBoard.isScrollEnabled = true
        notiBoard.layer.borderWidth = 1
        notiBoard.layer.borderColor = UIColor.red.cgColor
        callOutView.addSubview(notiBoard)
        
        //Black background view
        blackBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.screenView.frame.width, height: self.screenView.frame.height))
        blackBackground.backgroundColor = UIColor.black
        blackBackground.alpha = 0.7
        blackBackground.isHidden = true
        screenView.addSubview(blackBackground)
    }
    
    @IBAction func notificationButtonClicked(_ sender: UIButton) {
        delegate?.changeLocatedButton()
        if callOutViewSwitch == false {
            callOutView.isHidden = false
            blackBackground.isHidden = false
            print(callOutView.frame.width)
            scale()
            callOutViewSwitch = true
        }
        
    }
    
    
    @IBAction func cancelClicked(_ sender: UIButton) {

        scale()
        
    }
    
    func topHeights() -> CGFloat {
        return topHeight!
    }
    
    func notiBtn() -> UIButton {

        return notificationButton
    }
    
    //MARK - Load Celebrity data
    func loadNotification(celebrityArray: [Celebrity]) {
        
        var convertedArray = [Celebrity]()
        var todayTotal = 0
        var yestodayTotal = 0
        
        convertedArray = celebrityArray.sorted(by: { $0.createTime! > $1.createTime! })
        
        var notifyContent = "\(getDateTime(day:Date(), format: "EEEE, MMM d")): "
        var yestodayNotify = "\n\(getDateTime(day:Date().yesterday, format: "EEEE, MMM d")): "
        
        var notifyContentEnd = ""
        var yestodayNotifyEnd = ""
        
        for celebrity in convertedArray{
            
            let createTime = celebrity.createTime
            
            if Calendar.current.isDateInToday(createTime!){
                notifyContentEnd += "\(celebrity.name): \(celebrity.address!)\n\n"
                todayTotal += 1
            }else if Calendar.current.isDateInYesterday(createTime!){
                yestodayNotifyEnd += "\(celebrity.name): \(celebrity.address!)\n\n"
                yestodayTotal += 1
            }
        }
        
        self.defaults.set(todayTotal, forKey: "todayUpdate")
        notifyContent = "\(notifyContent)Total \(todayTotal) \n\n\n"
        yestodayNotify = "\(yestodayNotify)Total \(yestodayTotal) \n\n\n"

        notiBoard.text = notifyContent + notifyContentEnd + yestodayNotify + yestodayNotifyEnd
        
        
    }
    
    func getDateTime(day: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let currentTime = formatter.string(from: day)
        return currentTime
    }
    
    func scale() {
        
        if callOutViewSwitch == false {
            print("scale1")
            UIView.animate(withDuration: 0.001, animations: {
                self.callOutView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.callOutView.alpha = 0
            }, completion:
                { (finish) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.callOutView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.callOutView.alpha = 1
                    })
            })

        }else if callOutViewSwitch == true{
            print(callOutView.frame.width)
            UIView.animate(withDuration: 0.5, animations: {
                self.callOutView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.callOutView.alpha = 0
            }, completion:
                { (finish) in
                    UIView.animate(withDuration: 0.001, animations: {
                        self.callOutView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.callOutView.alpha = 1
                        self.callOutView.isHidden = true
                        self.callOutViewSwitch = false
                        self.blackBackground.isHidden = true
                        self.delegate?.changeLocatedButton()
                    })
            })
        }
    }

    
}




extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}


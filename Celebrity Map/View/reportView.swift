//
//  reportView.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-23.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//
import Foundation
import UIKit
import FirebaseDatabase
import SVProgressHUD

protocol reportDelegate{
    func reportOn()
    func changeLocatedButton()
    func reportOff()
}


class reportView{
    var screenView = UIView()
    var motherView = UIView()
    var shareBtn = UIButton()
    var cancelBtn = UIButton()
    var topHeight : CGFloat?
    var delegate: reportDelegate?
    var blackBackground = UIView()

    var imageViewFrame = UIImageView()
    var TopLabel = UILabel()
    var nameLabel = UILabel()
    var distanceLabel = UILabel()
    var locationin = false
    
    func startReportView(phoneFrame:UIView, botView: UIView, navigationBar: UINavigationBar){
        screenView = phoneFrame
        
        let heightofNavigationBar = navigationBar.frame.height
        let heightofStatusBar = UIApplication.shared.statusBarFrame.height
        topHeight = heightofNavigationBar + heightofStatusBar
        
        motherView = UIView(frame: CGRect(x: 0, y: 0, width: screenView.frame.width * 4 / 5, height: self.screenView.frame.height * 2 / 3))
        motherView.center.x = self.screenView.frame.width / 2
        motherView.center.y = self.screenView.frame.height / 2
        motherView.clipsToBounds = true
        self.motherView.layer.cornerRadius = 25
        self.motherView.backgroundColor = UIColor.white
        screenView.addSubview(motherView)
        
        imageViewFrame = UIImageView(frame: CGRect(x: 20, y: 20, width: motherView.frame.width * 2 / 5, height: motherView.frame.height * 2 / 5))
        imageViewFrame.clipsToBounds = true
        imageViewFrame.layer.cornerRadius = 25
        imageViewFrame.image = UIImage(named: "facebook")
        imageViewFrame.contentMode = .scaleAspectFit
        motherView.addSubview(imageViewFrame)
        
        TopLabel = UILabel(frame: CGRect(x: motherView.frame.width / 2 + 20, y: 40, width: motherView.frame.width * 2 / 5, height: 50))
        TopLabel.text = "Yinpeng Chen241234143"
        TopLabel.adjustsFontSizeToFitWidth = true
        TopLabel.font = UIFont.boldSystemFont(ofSize: 20)
        TopLabel.textAlignment = .left
        // For Swift >= 3
        TopLabel.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
        TopLabel.numberOfLines = 2
        TopLabel.textColor = UIColor.black
        motherView.addSubview(TopLabel)
        
        
        
        nameLabel = UILabel(frame: CGRect(x: TopLabel.frame.minX, y: TopLabel.frame.maxY + 20, width: TopLabel.frame.width, height: 90))
//        nameLabel.center.x = motherView.frame.midX
        nameLabel.text = "Honmaru, Naka Ward, Nagoya, Aichi Prefectures Japan"
        nameLabel.textColor = UIColor.gray
        nameLabel.numberOfLines = 4
        nameLabel.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .left
        nameLabel.adjustsFontSizeToFitWidth = true
        motherView.addSubview(nameLabel)
        
        distanceLabel = UILabel(frame: CGRect(x: 0, y: imageViewFrame.frame.maxY + 30, width: motherView.frame.width - 40, height: 80))
        distanceLabel.text = "Nearest Celebrity \n Distance: 40km"
        distanceLabel.numberOfLines = 4
        distanceLabel.font = UIFont.boldSystemFont(ofSize: 40)
        distanceLabel.textAlignment = .center
        distanceLabel.adjustsFontSizeToFitWidth = true
        distanceLabel.textColor = UIColor.black
        distanceLabel.center.x = motherView.frame.width / 2
        motherView.addSubview(distanceLabel)
        
        let shareBtn = UIButton(frame: CGRect(x: 30, y: motherView.frame.height - 100, width: motherView.frame.width / 2 - 60, height: 50))
        shareBtn.center.x = motherView.frame.width / 4
        shareBtn.backgroundColor = UIColor.blue
        shareBtn.clipsToBounds = true
        shareBtn.setTitle("Share", for: .normal)
        shareBtn.layer.cornerRadius = 15

//        shareBtn.layer.borderWidth = 5.0
        shareBtn.addTarget(self, action: #selector(shareBtnClicked), for: .touchUpInside)
        motherView.addSubview(shareBtn)
        
        let cancelBtn = UIButton(frame: CGRect(x: motherView.frame.width / 2 + 30, y: motherView.frame.height - 100, width: shareBtn.frame.width, height: 50))
        cancelBtn.center.x = motherView.frame.width * 3 / 4
        cancelBtn.backgroundColor = UIColor.gray
        cancelBtn.clipsToBounds = true
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.layer.cornerRadius = 15
        //        shareBtn.layer.borderWidth = 5.0
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        motherView.addSubview(cancelBtn)
        motherView.isHidden = true
        
        //Black background view
        blackBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.screenView.frame.width, height: self.screenView.frame.height))
        blackBackground.backgroundColor = UIColor.black
        blackBackground.alpha = 0.7
        blackBackground.isHidden = true
        botView.addSubview(blackBackground)
        
        //set gesture
        var tapBlack = UITapGestureRecognizer()
        tapBlack = UITapGestureRecognizer(target: self, action: #selector(shutDownBlack as () -> Void))
        self.blackBackground.addGestureRecognizer(tapBlack)

        delegate?.reportOn()
    }
    
    var shortestCelebrity = Celebrity()
    var shortestDistance = Double()
    func callOutSet(type: Int, name: String, address: String, distance: Double?, image: UIImage, shortest: Celebrity){
        shortestCelebrity = shortest
        
        shortestDistance = Double(round(1000 * (distance! / 1000)) / 1000)
        
        if shortestDistance <= 20 {
            locationin = true
        }else{
            locationin = false
        }
        
        if locationin{
            let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedStringKey.foregroundColor : UIColor.black]
            
            let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40), NSAttributedStringKey.foregroundColor : UIColor.red]
            
            let attributedString1 = NSMutableAttributedString(string:"Congratulations: Your stand in the hometown of\n", attributes:attrs1)
            
            let attributedString2 = NSMutableAttributedString(string:"\(shortest.title): \(shortest.name)\n", attributes:attrs2)
            
            let attributedString3 = NSMutableAttributedString(string:"check in and share to your friend!", attributes:attrs1)
            
            attributedString1.append(attributedString2)
            
            attributedString1.append(attributedString3)
            
            self.distanceLabel.attributedText = attributedString1

        }else{
            let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 30), NSAttributedStringKey.foregroundColor : UIColor.black]

            let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 40), NSAttributedStringKey.foregroundColor : UIColor.red]

            let attributedString1 = NSMutableAttributedString(string:"Nearest celebrity alert: \n", attributes:attrs1)
            
            let attributedString2 = NSMutableAttributedString(string:"\(shortestDistance) KM", attributes:attrs2)
            
            let attributedString3 = NSMutableAttributedString(string:"\n to your location who is \(shortest.title).", attributes:attrs1)

            attributedString1.append(attributedString2)
            
            attributedString1.append(attributedString3)
            
            self.distanceLabel.attributedText = attributedString1
        }
            
        self.TopLabel.text = "\(name)"
        self.nameLabel.text = address
        imageViewFrame.image = image
        blackBackground.isHidden = false
    }
    
    //Shut down BlackBG View When Cancel button be clicked in shareView
    @objc func shutDownBlack(){
    }
    
    
    
    @IBAction func shareBtnClicked(_ sender: UIButton) {
        
        let currentView = getCurrentViewController()
        let shareURL = NSURL(string: "https://itunes.apple.com/ca/app/google/id1401680756")

        let image = shortestCelebrity.portrait
        
        var text = ""
        if locationin {
            text = "I checked in \(shortestCelebrity.title): \(shortestCelebrity.name)'s Hometown: \(shortestCelebrity.address!)."
        }else{
            text = "Nearest celebrity: \(shortestDistance) km distance from me: \(shortestCelebrity.address!) - the hometown of \(shortestCelebrity.name)\nwho is famous \(shortestCelebrity.title)"
        }
        let active = UIActivityViewController(activityItems: [image, text, shareURL!], applicationActivities: nil)
        active.popoverPresentationController?.sourceView = currentView?.view
        currentView?.present(active, animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        motherView.isHidden = true
        blackBackground.isHidden = true
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }


    
}


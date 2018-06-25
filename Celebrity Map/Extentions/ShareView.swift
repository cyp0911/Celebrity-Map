//
//  ShareView.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-18.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation
import UIKit
//import FacebookShare



class ShareView {
    var shareView = UIView()
    var screenView = UIView()
    var cancelBtn = UIButton()
    var numOfButtons : Int32 = 0
    
    let providerArray = ["facebook", "twitter", "weibo", "moment", "wechat"]
    var blackBackground = UIView()
    var shareViewCalloutSwitch = 0

    var currentAnnotationCelebrity = Celebrity()
    
    var switchShiftHeight = 0
    
    func buildShareview(phoneFrame:UIView, frameOfTabBar: CGRect, tabBarView: UIView){
        screenView = phoneFrame
        
        let bannerView:CGFloat = 25
        let heightOfTabbar = frameOfTabBar.height
        let heightOfButtonBar:CGFloat = 90.0 + bannerView
        
        switchShiftHeight = Int(heightOfTabbar + heightOfButtonBar)
        
        shareView = UIView(frame: CGRect(x: 0, y: screenView.frame.height, width: screenView.frame.width, height: heightOfButtonBar + heightOfTabbar))
//        shareView.clipsToBounds = true
//        shareView.layer.cornerRadius = 25
        shareView.backgroundColor = UIColor(r: 211, g: 211, b: 211)
//        shareView.isHidden = true
        tabBarView.addSubview(shareView)
        
        //Draw seperating line
        let midLine = UIView(frame: CGRect(x: 0, y: shareView.frame.height - heightOfTabbar, width: screenView.frame.width, height: 1))
        midLine.backgroundColor = UIColor.gray
        midLine.isHidden = true
        shareView.addSubview(midLine)
        
        
        //Cancel Button
        cancelBtn = UIButton(frame: CGRect(x: 0, y: heightOfButtonBar, width: screenView.frame.width, height: 50))
        cancelBtn.center.x = screenView.frame.width / 2
        cancelBtn.center.y = heightOfButtonBar + (heightOfTabbar / 2)
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitle("CANCEL", for: .normal)
        cancelBtn.setTitleColor(UIColor.black, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.5)
        cancelBtn.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)

        shareView.addSubview(cancelBtn)
        
        //ButtonListView
        let buttonListView = UIView(frame: CGRect(x: 0, y: bannerView, width: screenView.frame.width, height: heightOfButtonBar - bannerView))
        buttonListView.backgroundColor = UIColor(r: 211, g: 211, b: 211)
        shareView.addSubview(buttonListView)
        
        let listBound = CGFloat(20)
        let sizeOfButton = CGFloat(50)
        numOfButtons = 5
        //Button List(4)
        for i in 1...numOfButtons {
            let listButton = UIButton(frame: CGRect(x:listBound + (((screenView.frame.width - 2 * listBound) - sizeOfButton) / (CGFloat(numOfButtons) - 1) * (CGFloat(i) - 1)), y: 0, width: sizeOfButton, height: sizeOfButton))
            listButton.backgroundColor = UIColor.clear
            listButton.setImage(UIImage(named: "\(providerArray[Int(i) - 1])"), for: .normal)
            listButton.center.y = buttonListView.frame.height / 2
            listButton.tag = Int(i)
            listButton.clipsToBounds = true
            listButton.layer.cornerRadius = 10
            listButton.addTarget(self, action: #selector(listButtonCliked), for: .touchUpInside)
            buttonListView.addSubview(listButton)
        }
        
        //Label: ShareToLabel
        let ShareToLabel = UILabel(frame: CGRect(x: screenView.frame.width / 2, y: 10, width: 300, height: 15))
        ShareToLabel.center.x = screenView.frame.width / 2
        ShareToLabel.textAlignment = .center
        ShareToLabel.text = "ShareTo"
        ShareToLabel.font = UIFont.systemFont(ofSize: 12.5)
        ShareToLabel.textColor = UIColor.black
        ShareToLabel.adjustsFontSizeToFitWidth = true
        ShareToLabel.backgroundColor = UIColor(r: 211, g: 211, b: 211)
        shareView.addSubview(ShareToLabel)

        //Black background view
        blackBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.screenView.frame.width, height: self.screenView.frame.height))
        blackBackground.backgroundColor = UIColor.black
        blackBackground.alpha = 0.7
        blackBackground.isHidden = true
        screenView.addSubview(blackBackground)
        
        //Black background view
        blackBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.screenView.frame.width, height: self.screenView.frame.height))
        blackBackground.backgroundColor = UIColor.black
        blackBackground.alpha = 0.7
        blackBackground.isHidden = true
        self.screenView.addSubview(blackBackground)
        
        //set gesture
        var tapBlack = UITapGestureRecognizer()
        tapBlack = UITapGestureRecognizer(target: self, action: #selector(shutDownBlack as () -> Void))
        self.blackBackground.addGestureRecognizer(tapBlack)
        
    }
    
    
    
    @IBAction func listButtonCliked(_ sender: UIButton) {
        
        let currentView = getCurrentViewController()
        let shareURL = NSURL(string: "https://itunes.apple.com/ca/app/google/id1401680756")
        let image = currentAnnotationCelebrity.portrait
        
        let text = "\(currentAnnotationCelebrity.name) is \(currentAnnotationCelebrity.title) who come from \(currentAnnotationCelebrity.address ?? "??"). Check the celebrity hometown with IOS APP: Celebrity Map!"
        let active = UIActivityViewController(activityItems: [image, text, shareURL!], applicationActivities: nil)
        active.popoverPresentationController?.sourceView = currentView?.view
        
        switch sender.tag {
        case 1:
            currentView?.present(active, animated: true, completion: nil)
        case 2:
            currentView?.present(active, animated: true, completion: nil)
        default:
            currentView?.present(active, animated: true, completion: nil)
        }
    }

    
    @IBAction func cancelClicked(_ sender: UIButton) {
        callOutShareView(switchs: 1)
    }
    
    func callOutShareView(switchs: Int){
        
        shareViewCalloutSwitch = switchs
        
        if shareViewCalloutSwitch == 0 {
            self.botViewAnimation()
            shareViewCalloutSwitch = 1
        }else if switchs == 1 {
            self.botViewAnimationReverse()
            shareViewCalloutSwitch = 0
        }

    }
    
    
    //MARK - Animation for shareView
    func botViewAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.shareView.frame.origin.y -= self.shareView.frame.height
            self.shareView.alpha = 1
            self.blackBackground.isHidden = false

            
            //                self.locatedButton.frame.origin.y -= self.bounceDetailView.frame.height
        }, completion: nil)
    }
    
    func botViewAnimationReverse(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.shareView.frame.origin.y += self.shareView.frame.height
            self.shareView.alpha = 0
            self.blackBackground.isHidden = true

        }, completion:
            { (finish) in
        })
        
    }
    
    //Shut down BlackBG View When Cancel button be clicked in shareView
    @objc func shutDownBlack(){
        callOutShareView(switchs: 1)
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


//
//  ShareView.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-18.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation
import UIKit


class ShareView {
    var shareView = UIView()
    var screenView = UIView()
    var cancelBtn = UIButton()
    var numOfButtons : Int32 = 0
    
    let providerArray = ["Facebook", "Twitter", "Weibo", "Moment", "Wechat"]
    
    func buildShareview(phoneFrame:UIView, frameOfTabBar: CGRect, tabBarView: UIView){
        screenView = phoneFrame
        
        let heightOfTabbar = frameOfTabBar.height
        let heightOfButtonBar:CGFloat = 90.0
        
        shareView = UIView(frame: CGRect(x: 0, y: screenView.frame.height - heightOfTabbar - heightOfButtonBar, width: screenView.frame.width, height: heightOfButtonBar + heightOfTabbar))
        shareView.clipsToBounds = true
//        shareView.layer.cornerRadius = 25
        shareView.backgroundColor = UIColor.white
//        shareView.isHidden = true
        tabBarView.addSubview(shareView)
        
        //Draw seperating line
        let midLine = UIView(frame: CGRect(x: 0, y: shareView.frame.height - heightOfTabbar, width: screenView.frame.width, height: 1))
        midLine.backgroundColor = UIColor.gray
        midLine.isHidden = true
        shareView.addSubview(midLine)
        
        
        //Cancel Button
        cancelBtn = UIButton(frame: CGRect(x: 0, y: heightOfButtonBar, width: 100, height: 50))
        cancelBtn.center.x = screenView.frame.width / 2
        cancelBtn.center.y = heightOfButtonBar + heightOfTabbar / 2
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitle("CANCEL", for: .normal)
        cancelBtn.setTitleColor(UIColor.black, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.5)
        cancelBtn.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)

        shareView.addSubview(cancelBtn)
        
        //ButtonListView
        let buttonListView = UIView(frame: CGRect(x: 0, y: 0, width: screenView.frame.width, height: heightOfButtonBar))
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
        
    }
    
    @IBAction func listButtonCliked(_ sender: UIButton) {
        
        print("clicked\(providerArray[sender.tag - 1])")
    }

    
    @IBAction func cancelClicked(_ sender: UIButton) {
        
        print("cancel")
    }
    
}


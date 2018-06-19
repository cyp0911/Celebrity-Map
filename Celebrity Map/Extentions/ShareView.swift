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
    
    func buildShareview(phoneFrame:UIView, frameOfTabBar: CGRect, tabBarView: UIView){
        screenView = phoneFrame
        
        let heightOfTabbar = frameOfTabBar.height
        let heightOfButtonBar:CGFloat = 75.0
        
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
        cancelBtn = UIButton(frame: CGRect(x: 0, y: midLine.frame.height, width: screenView.frame.width, height: heightOfTabbar))
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitle("CANCEL", for: .normal)
        shareView.addSubview(cancelBtn)
        
        //ButtonListView
        let buttonListView = UIView(frame: CGRect(x: 0, y: shareView.frame.minY, width: screenView.frame.width, height: shareView.frame.height - heightOfButtonBar))
        buttonListView.backgroundColor = UIColor.lightGray
        shareView.addSubview(buttonListView)
        
        //Button List(4)
        for i in 1...10 {
            print(i)
        }
        
    }
    
}


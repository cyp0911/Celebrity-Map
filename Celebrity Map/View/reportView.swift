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

class reportView{
    var screenView = UIView()
    var reportView = UIView()
    var motherView = UIView()
    var shareBtn = UIButton()
    var cancelBtn = UIButton()
    var topHeight : CGFloat?

    var portrait = UIImageView()
    
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
        self.motherView.backgroundColor = UIColor.red
        screenView.addSubview(motherView)
        
//        reportView = UIView(frame: CGRect(x: 0, y: 0, width: motherView.frame.width * 2 * 3, height: <#T##CGFloat#>))

//        let topLabel = UILabel(frame: CGRect(x: 0, y: 0, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
        
    }
    
    
    
    
}

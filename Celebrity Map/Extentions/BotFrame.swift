//
//  BotFrame.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-17.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation
import UIKit



class BotFrame: UIViewController {

    func setImageByUrl(imageview: UIImageView, url: String) -> UIImageView {
        if let urlLink = NSURL(string: "\(url)") {
            if let data = NSData(contentsOf: urlLink as URL) {
                imageview.image = UIImage(data: data as Data)
            }
        }
        
        return imageview
    }
    
    
}

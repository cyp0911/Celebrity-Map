//
//  CelebrityCalloutViewModel.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-13.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import UIKit
import MapViewPlus

class CelebrityCalloutViewModel: CalloutViewModel {
    var title: String
    var image: UIImage
    var name: String
    var hometown: String
    
    init(title: String, image: UIImage, name: String, hometown: String) {
        self.title = title
        self.image = image
        self.name = name
        self.hometown = hometown
    }
}

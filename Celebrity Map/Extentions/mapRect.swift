//
//  mapRect.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-23.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation
import MapKit

class mapRect{
    var Top : Double
    var Bot : Double
    var Left : Double
    var Right : Double
    
    init(Top: Double, Bot : Double, Left : Double, Right : Double) {
        self.Top = Top
        self.Bot = Bot
        self.Left = Left
        self.Right = Right
    }
    
    func checkIfInside(point: CLLocationCoordinate2D) -> Bool {
        let yCor = point.latitude
        let xCor = point.longitude
        
        if xCor >= Left && xCor <= Right && yCor >= Bot && yCor <= Top {
            return true
        }
        
        return false
    }
    
    
}

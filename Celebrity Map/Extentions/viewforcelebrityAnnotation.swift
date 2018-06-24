//
//  viewforcelebrityAnnotation.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-23.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import Foundation

import MapKit

//  MARK: Battle Rapper View
internal final class CelebrityAnnoView: MKMarkerAnnotationView {
    //  MARK: Properties
    internal override var annotation: MKAnnotation? { willSet { newValue.flatMap(configure(with:)) } }
}


//  MARK: Configuration
private extension CelebrityAnnoView {
    func configure(with annotation: MKAnnotation) {
        guard annotation is CelebrityAnnotaion else { fatalError("Unexpected annotation type: \(annotation)") }
        //    CONFIGURE
        switch annotation.title {
        case "Yinpeng Chen":
            markerTintColor = .purple
            glyphImage = UIImage(named: "groom")
        default:
            markerTintColor = .red
            glyphImage = UIImage(named: "groom")
        }
        
    }
}

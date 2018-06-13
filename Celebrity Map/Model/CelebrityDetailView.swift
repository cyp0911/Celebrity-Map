//
//  CelebrityDetailView.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-13.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//
import UIKit
import MapViewPlus

// CalloutViewPlus is a protocol of MapViewPlus.
// Currently, it has just one requirement -> func configureCallout(_ viewModel: CalloutViewModel)

public protocol BasicCalloutViewModelDelegate: class {
    func detailButtonTapped(withTitle title: String)
}

class CelebrityDetailView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var delegate: BasicCalloutViewModelDelegate?

    
    @IBOutlet weak var CelebrityImage: UIImageView!
    
    @IBOutlet weak var CelebrityName: UILabel!
    @IBOutlet weak var CelebrityTitle: UILabel!
    @IBOutlet weak var HomeTownTitle: UILabel!
    
    @IBOutlet weak var detailButtonOutlet: UIButton!
    
    @IBAction func DetailButtonClicked(_ sender: Any) {
        delegate?.detailButtonTapped(withTitle: CelebrityTitle.text!)
    }
    
}

extension CelebrityDetailView: CalloutViewPlus{
    func configureCallout(_ viewModel: CalloutViewModel) {
        let celebrityModel = viewModel as! CelebrityCalloutViewModel
        
        CelebrityTitle.text = celebrityModel.title
        CelebrityImage.image = celebrityModel.image
        CelebrityName.text = celebrityModel.name
        HomeTownTitle.text = celebrityModel.hometown
    }
}

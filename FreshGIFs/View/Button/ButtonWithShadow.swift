//
//  ButtonWithShadow.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 01/05/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit

class ButtonWithShadow: UIButton {
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    
}

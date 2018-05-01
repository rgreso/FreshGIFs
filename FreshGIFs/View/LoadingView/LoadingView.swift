//
//  LoadingView.swift
//  AppDay
//
//  Created by Pavol Kmet on 25/01/2017.
//  Copyright © 2017 GoodRequest, s.r.o. All rights reserved.
//

import UIKit

class LoadingView: UIView, NibLoadable {

    weak var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib(with: LoadingView.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(with: LoadingView.self)
    }
    
    // MARK: - NibLoadable
    
    func loadViewFromNib<T : UIView>(with type: T.Type) {
        view = type.loadNib(withOwner: self)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.autoresizingMask = autoresizingMask
        view.frame = bounds
        addSubview(view);
    }

}

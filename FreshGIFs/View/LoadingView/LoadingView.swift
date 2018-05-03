//
//  LoadingView.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 26/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
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

//
//  EmptyStateView.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 26/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit

protocol NibLoadable {
    
    var view: UIView! { get set }
    
    func loadViewFromNib<T: UIView>(with type: T.Type)
    
}

enum EmptyState {
    
    case error, emptyFavourites, zeroResults
    
    var title: String? {
        switch self {
        case .error:
            return "Something went wrong"
        case .emptyFavourites:
            return "No Favourite GIFs"
        case .zeroResults:
            return "No GIFs Available"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .emptyFavourites:
            return "Go and hit the like button on the best GIFs to save them for later!"
        case .zeroResults:
            return "Sorry we haven't found any GIFs matching your search term. Let's try it with another one!"
        default:
            return nil
        }
    }

    var buttonTitle: String? {
        return NSLocalizedString("Try again", comment: "")
    }
    
    var buttonIsHidden: Bool {
        return self != .error
    }
    
    var image: UIImage? {
        return nil
    }
    
}

class EmptyStateView: UIView, NibLoadable {

    weak var view: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var subtitleLabelCenterVerticalyConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib(with: EmptyStateView.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadViewFromNib(with: EmptyStateView.self)
    }
    
    convenience init(for frame: CGRect, target: Any? = nil, selector: Selector? = nil) {
        self.init(state: .zeroResults, frame: frame, target: target, selector: selector)
    }
            
    init(state: EmptyState, frame: CGRect, target: Any? = nil, selector: Selector? = nil) {
        super.init(frame: frame)
        
        loadViewFromNib(with: EmptyStateView.self)
        set(state: state, subtitle: nil)

        if let target = target, let selector = selector {
            reloadButton.setTitle(state.buttonTitle, for: .normal)
            reloadButton.addTarget(target, action: selector, for: .touchUpInside)
        }
        
        subtitleLabelCenterVerticalyConstraint.constant = state.buttonIsHidden ? 45.0 : 0.0
    }
    
    // MARK: - Public
    
    func set(state: EmptyState, subtitle: String?) {
        titleLabel.text       = state.title
        subtitleLabel.text    = subtitle ?? state.subtitle
        imageView.image       = state.image
        reloadButton.isHidden = state.buttonIsHidden
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

// MARK: - UIView

extension UIView {
    
    class func loadNib(withOwner ownerOrNil: Any?) -> UIView {
        guard let view = UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: ownerOrNil, options: nil).first as? UIView else {
            fatalError("‼️ Owner of nib with name \(String(describing: self)) appears to be different from \(String(describing: ownerOrNil))")
        }
        
        return view
    }
    
}

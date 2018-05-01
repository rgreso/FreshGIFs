//
//  EmptyStateView.swift
//  AppDay
//
//  Created by Pavol Kmet on 25/01/2017.
//  Copyright © 2017 GoodRequest, s.r.o. All rights reserved.
//

import UIKit
import GoodSwift

protocol NibLoadable {
    
    weak var view: UIView! { get set }
    
    func loadViewFromNib<T: UIView>(with type: T.Type)
    
}

enum EmptyState {
    
    case empty, error, emptyGoogleSearch, emptySweatSearch, emptyInbox, emptyCalendarPrivateUser, emptyCalendarPrivateTrainer, emptyCalendarPublicTrainer, emptyCalendarMaxColder, zeroResults, zeroFollowersResults,  emptyFollowers, emptyTopTrainers, emptyFollowing
    
    var title: String? {
        switch self {
        case .error:
            return NSLocalizedString("Something went wrong", comment: "")
        case .emptyInbox:
            return NSLocalizedString("No inbox messages", comment: "")
        case .emptyCalendarPrivateUser:
            return NSLocalizedString("Your calendar is empty", comment: "")
        case .emptyCalendarPrivateTrainer:
            return NSLocalizedString("Your calendar is empty", comment: "")
        case .emptyCalendarPublicTrainer:
            return NSLocalizedString("This trainer has currently no openings. Please, contact the trainer for possible openings.", comment: "")
        case .emptyCalendarMaxColder:
            return NSLocalizedString("This trainer is fully booked. You can still follow this trainer to get instant notifications when new sessions are available.", comment: "")
        case .zeroFollowersResults:
            return NSLocalizedString("No results", comment: "")
        case .emptyFollowers:
            return NSLocalizedString("You don't have any followers.", comment: "")
        case .emptyFollowing:
            return NSLocalizedString("No instructors or categories", comment: "")
        case .emptyTopTrainers:
            return NSLocalizedString("Top trainers will be added soon.", comment: "")
        default:
            return nil
        }
    }
    
    var subtitle: String? {
        switch self {
        case .emptyGoogleSearch:
            return NSLocalizedString("Please enter city or address.", comment: "")
        case .emptySweatSearch:
            return NSLocalizedString("Please enter gym name or address \n(at least 3 characters)", comment: "")
        case .emptyInbox:
            return NSLocalizedString("Congratulations! You don't have any missed messages.", comment: "")
        case .emptyCalendarPrivateUser:
            return NSLocalizedString("All your classes will appear here in chronological order.", comment: "")
        case .emptyCalendarPrivateTrainer:
            return NSLocalizedString("To add new item to your calendar go to format and set up new class/session or join class of another instructor.", comment: "")
        case .zeroResults:
            return NSLocalizedString("No results were found.\nPlease try a different search.", comment: "")
        case .zeroFollowersResults:
            return NSLocalizedString("No results were found.\nPlease try a different search.", comment: "")
        case .emptyFollowing:
            return NSLocalizedString("You don't have any instructors or categories that you follow.", comment: "")
        default:
            return nil
        }
    }

    var buttonTitle: String? {
        return NSLocalizedString("Try again", comment: "")
    }
    
    var buttonIsHidden: Bool {
        return self != .error || self == .emptyFollowing
    }
    
    var image: UIImage? {
        switch self {
        case .emptyInbox:
            return nil
        case .emptyCalendarPrivateUser:
            fallthrough
        case .emptyCalendarPrivateTrainer:
            fallthrough
        case .emptyCalendarPublicTrainer, .emptyCalendarMaxColder:
            return #imageLiteral(resourceName: "empty-calendar")
        case .emptyFollowers:
            fallthrough
        case .emptyFollowing:
            return nil
        default:
            return nil
        }
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
    
    
    
    ////// CHANGE STATE!!!!!
    //
    ///
    
    //
    //
    //
    //
    //
    //
    
    convenience init(for frame: CGRect, target: Any? = nil, selector: Selector? = nil) {
        self.init(state: .emptyCalendarPrivateUser, frame: frame, target: target, selector: selector)
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
    
    // MARK: - Class functions
    
//    class func emptyState(from type: UserType) -> EmptyState {
//        switch type {
//        case .privateTrainer:
//            return .emptyCalendarPrivateTrainer
//        case .publicTrainer:
//            return .emptyCalendarPublicTrainer
//        case .publicTrainerFullyBooked:
//            return .emptyCalendarMaxColder
//        default:
//            return .emptyCalendarPrivateUser
//        }
//    }
    
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


extension UIView {
    
    class func loadNib(withOwner ownerOrNil: Any?) -> UIView {
        guard let view = UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: ownerOrNil, options: nil).first as? UIView else {
            fatalError("‼️ Owner of nib with name \(String(describing: self)) appears to be different from \(String(describing: ownerOrNil))")
        }
        return view
    }
    
}

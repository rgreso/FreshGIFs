//
//  LoadMoreViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 26/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import Async
//import Reachability
import StatefulViewController
//import SwiftMessages
import UIKit

extension UITableView {
    
    var lastIndexPath: IndexPath {
        let section = numberOfSections > 0 ? numberOfSections - 1 : 0
        let row = numberOfRows(inSection: section) - 1
        return IndexPath(row: row, section: section)
    }
    
}


extension Selector {
    
    static let loadData = #selector(LoadMoreViewController.loadData)
  //  fileprivate static let reachabilityDidChange = #selector(LoadMoreViewController.reachabilityDidChange(_:))
    
}

class LoadMoreViewController: UIViewController, StatefulViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
//    internal lazy var messages: SwiftMessages = {
//        let messages = SwiftMessages()
//        messages.defaultConfig = SwiftMessages.Config.navigationBarBottom(seconds: 4.0)
//        return messages
//    }()
    
    internal lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor.lightGray
        return control
    }()
    
    internal var isLoading: Bool = false {
        didSet {
            if !isLoading && refreshControl.isRefreshing {
                Async.main(after: 0.3) { [weak self] in
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    internal var isLoadingMore: Bool = false {
        didSet {
            let animated = tableView.indexPathsForVisibleRows?.contains(tableView.lastIndexPath) == true
            UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: { [weak self] in
                self?.tableView?.tableFooterView = self?.isLoadingMore == true ? self?.loadingHeaderFooterView : self?.tableFooterView
            })
        }
    }
    
    internal var distanceFromBottomToStartLoading: CGFloat {
        return 300.0
    }
    
    internal var hasMoreData: Bool = true
    
    private var tableFooterView: UIView?
    
    internal var loadingHeaderFooterView: LoadingHeaderFooterView!
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // NotificationCenter.default.addObserver(self, selector: .reachabilityDidChange, name: .reachabilityChanged, object: nil)
        
        tableView.addSubview(refreshControl)
        setupLoadingHeaderFooterView()
        
        loadingView = LoadingView(frame: tableView.bounds)
        errorView = EmptyStateView(state: .error, frame: tableView.bounds, target: self, selector: .loadData)
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInitialViewState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //messages.hideAll()
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
//    }
//
    // MARK: - Setup
    
    private func setupLoadingHeaderFooterView() {
        tableFooterView = tableView.tableFooterView
        tableView.registerHeaderFooterView(fromClass: LoadingHeaderFooterView.self)
        loadingHeaderFooterView = tableView.dequeueReusableHeaderFooterView(fromClass: LoadingHeaderFooterView.self)!
    }
    
    // MARK: - Selector

//    @objc func reachabilityDidChange(_ notification: Foundation.Notification) {
//        guard let reachability = notification.object as? Reachability else {
//            return
//        }
//        if reachability.connection != .none && shouldLoadData() && !isLoading {
//            loadData()
//        } else {
//            messages.hide()
//        }
//    }
    
    // MARK: - Stateful View Controller
    
    func hasContent() -> Bool {
        return tableView.numberOfSections > 0
    }
    
//    func handleErrorWhenContentAvailable(_ error: Error) {
//        let view = try! SwiftMessages.viewFromNib(named: .StatusLineAdjustable) as! MessageView
//        view.configureContent(body: error.localizedDescription)
//        view.configureTheme(.error)
//        messages.show(view: view)
//    }
    
    func startLoading(animated: Bool, completion: (() -> Void)?) {
        transitionViewStates(loading: true, error: nil, animated: animated, completion: completion)
        isLoading = true
    }
    
    func endLoading(animated: Bool, error: Error?, completion: (() -> Void)?) {
        (errorView as? EmptyStateView)?.set(state: .error, subtitle: error?.localizedDescription)
        transitionViewStates(loading: false, error: error, animated: animated, completion: completion)
        isLoading = false
        isLoadingMore = false
    }
    
    // MARK: - Fetching
    
    func shouldLoadData() -> Bool {
        return hasContent() == false
    }
    
    @objc func loadData() { }
    
    func loadMoreData() { }
}

// MARK: - Scroll View Delegate

extension LoadMoreViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height) < distanceFromBottomToStartLoading {
            if !isLoading && !isLoadingMore && hasMoreData {
                loadMoreData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing, !isLoading {
            loadData()
        }
    }
    
}

//// MARK: - Swift Messages - Config
//
//extension SwiftMessages.Config {
//
//    static func navigationBarBottom(seconds: TimeInterval) -> SwiftMessages.Config {
//        var config = SwiftMessages.Config()
//        config.duration = .seconds(seconds: seconds)
//        return config
//    }
//
//}


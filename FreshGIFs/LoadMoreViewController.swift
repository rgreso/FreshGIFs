//
//  LoadMoreViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 26/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import Async
import StatefulViewController
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
    
}

class LoadMoreViewController: UIViewController, StatefulViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    // MARK: - Setup
    
    private func setupLoadingHeaderFooterView() {
        tableFooterView = tableView.tableFooterView
        tableView.registerHeaderFooterView(fromClass: LoadingHeaderFooterView.self)
        loadingHeaderFooterView = tableView.dequeueReusableHeaderFooterView(fromClass: LoadingHeaderFooterView.self)!
    }
    
    // MARK: - Stateful View Controller
    
    func hasContent() -> Bool {
        return tableView.numberOfSections > 0
    }
    
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

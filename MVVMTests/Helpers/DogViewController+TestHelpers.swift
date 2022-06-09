//
//  DogViewController+TestHelpers.swift
//  MVVMTests
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import MVVM

extension DogViewController {
    @discardableResult
    func simulateDogImageViewVisible(at row: Int = 0) -> DogImageCell? {
        return dogImageView(at: row)
    }
    
    func simulateDogImageViewNotVisible(at row: Int = 0) {
        let view = simulateDogImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: dogImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func simulateDogImageViewNearVisible(at row: Int = 0) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: dogImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateDogImageViewNotNearVisible(at row: Int = 0) {
        simulateDogImageViewVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: dogImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateUserInitiatedDogReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func dogImageView(at row: Int) -> DogImageCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: dogImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? DogImageCell
    }
    
    func numberOfRenderedDogImageViews() -> Int {
        tableView.numberOfRows(inSection: dogImageSection)
    }
    
    private var dogImageSection: Int {
        return 0
    }
}

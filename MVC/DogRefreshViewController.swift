//
//  DogRefreshViewController.swift
//  MVC
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import UIKit
import IyashiDogFeature

final class DogRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    private let dogLoader: DogLoader
    
    var onRefresh: (([Dog]) -> Void)?
    
    init(dogLoader: DogLoader) {
        self.dogLoader = dogLoader
    }
    
    @objc func refresh() {
        view.beginRefreshing()
        dogLoader.load { [weak self] result in
            if let dogs = try? result.get() {
                self?.onRefresh?(dogs)
            }
            self?.view.endRefreshing()
        }
    }
}

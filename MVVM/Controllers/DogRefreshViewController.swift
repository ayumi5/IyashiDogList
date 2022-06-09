//
//  DogRefreshViewController.swift
//  MVVM
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import UIKit
import IyashiDogFeature

final class DogRefreshViewController: NSObject {
    @IBOutlet private var view: UIRefreshControl?
    var dogLoader: DogLoader?
    
    var onRefresh: (([Dog]) -> Void)?
    
    @IBAction func refresh() {
        view?.beginRefreshing()
        dogLoader?.load { [weak self] result in
            if let dogs = try? result.get() {
                self?.onRefresh?(dogs)
            }
            self?.view?.endRefreshing()
        }
    }
}

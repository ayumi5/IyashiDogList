//
//  DogRefreshViewController.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import UIKit

final class DogRefreshViewController: NSObject, DogLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    var loadDog: (() -> Void)?
    
    @IBAction func refresh() {
        loadDog?()
    }
    
    func display(_ viewModel: DogLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}

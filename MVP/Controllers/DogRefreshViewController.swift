//
//  DogRefreshViewController.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import UIKit

protocol DogRefreshViewControllerDelegate {
    func didRequestDogRefresh()
}

final class DogRefreshViewController: NSObject, DogLoadingView {
    @IBOutlet private var view: UIRefreshControl?
    var delegate: DogRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestDogRefresh()
    }
    
    func display(_ viewModel: DogLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}

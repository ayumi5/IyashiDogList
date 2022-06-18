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
    var presenter: DogPresenter?
    
    @IBAction func refresh() {
        presenter?.loadDog()
    }
    
    func display(_ isLoading: Bool) {
        if isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}

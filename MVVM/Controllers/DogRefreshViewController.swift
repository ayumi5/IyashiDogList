//
//  DogRefreshViewController.swift
//  MVVM
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import UIKit

final class DogRefreshViewController: NSObject {
    @IBOutlet private var view: UIRefreshControl?
    var dogViewModel: DogViewModel? {
        didSet { bind() }
    }
    
    @IBAction func refresh() {
        dogViewModel?.loadDog()
    }
    
    private func bind() {
        dogViewModel?.onLoadDogStateChange = { [weak self] isLoading in
            if isLoading {
                self?.view?.beginRefreshing()
            } else {
                self?.view?.endRefreshing()
            }
        }
    }
}

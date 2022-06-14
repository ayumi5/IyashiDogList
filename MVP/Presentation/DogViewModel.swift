//
//  DogViewModel.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/09.
//

import IyashiDogFeature

final class DogViewModel {
    private let dogLoader: DogLoader
    var onLoadDog: (([Dog]) -> Void)?
    var onLoadDogStateChange: ((Bool) -> Void)?
    
    init(dogLoader: DogLoader) {
        self.dogLoader = dogLoader
    }
    
    func loadDog() {
        onLoadDogStateChange?(true)
        dogLoader.load { [weak self] result in
            if let dogs = try? result.get() {
                self?.onLoadDog?(dogs)
            }
            self?.onLoadDogStateChange?(false)
        }
    }
    
}

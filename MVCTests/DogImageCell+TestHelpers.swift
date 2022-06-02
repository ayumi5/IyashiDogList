//
//  DogImageCell+TestHelpers.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import MVC

 extension DogImageCell {
    var isShowingImageViewLoadingIndicator: Bool {
        dogImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return dogImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}

//
//  UIRefrechControl+TestHelpers.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

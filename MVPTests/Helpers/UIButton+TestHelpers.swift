//
//  UIButton+TestHelpers.swift
//  Tests
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

//
//  ReactExtensions.swift
//  duTest
//
//  Created by Prateek Kansara on 09/03/21.
//

import UIKit
import RxSwift
import RxCocoa

// Extensions to handle loader in different Views

extension UIViewController: LoadingViewable {}

extension Reactive where Base: UIViewController {
    
    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    public var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (vc, active) in
            if active {
                vc.startAnimating()
            } else {
                vc.stopAnimating()
            }
        })
    }
}



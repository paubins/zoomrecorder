//
//  UIView+.swift
//  ZoomRecorder
//
//  Created by Patrick Aubin on 8/31/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Foundation

extension UIView {
    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
    
    func shake() {
        self.transform = CGAffineTransform(translationX: 80, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

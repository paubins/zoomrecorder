//
//  ZoomGraphViewController.swift
//  ZoomRecorder
//
//  Created by Patrick Aubin on 8/31/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Foundation
import Cartography


class ZoomGraphViewController : UIViewController {
    
    private var contentOffset:Int = 0
    
    fileprivate var currentPoints:[NSValue] = [] {
        didSet {
            if (0 < self.currentPoints.count) {
                self.contentOffset = Int((self.currentPoints.last?.cgPointValue.x)!)
            } else {
                self.contentOffset = 0
            }
            
        }
    }
    
    lazy var bezierContainer:UIScrollView = {
        let view:UIScrollView = UIScrollView(frame: .zero)
        
        view.backgroundColor = .black
        
        return view
    }()
    
    var bezierViewController:BezierViewController = BezierViewController(points: [], with: .blue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(self.bezierViewController)
        
        self.bezierContainer.addSubview(self.bezierViewController.view)
        
        self.view.addSubview(self.bezierContainer)
        
        constrain(self.bezierViewController.view) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
            view.width == 500
        }
        
        constrain(self.bezierContainer) { (view) in
            view.top == view.superview!.top
            view.right == view.superview!.right
            view.left == view.superview!.left
            view.bottom == view.superview!.bottom
        }
    }
    
    func moveToNextPoint() -> Bool {
        if (0 < self.contentOffset) {
            self.contentOffset = self.contentOffset - 1
            self.bezierContainer.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
            return true
        } else {
            return false
        }
    }
    
    func moveToFirstPoint() {
        self.contentOffset = 0
        self.bezierContainer.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}

extension ZoomGraphViewController : ZoomControllerDelegate {
    func zoomAdded(zoom: CGFloat) {
        self.currentPoints = self.currentPoints.map { (value) -> NSValue in
            let point:CGPoint = value.cgPointValue
            return NSValue(cgPoint: CGPoint(x: point.x + 1, y: point.y))
        }
        
        var newZoom:CGFloat = 0.0
        if (zoom < 10) {
            newZoom = zoom * 2
        } else {
            newZoom = zoom + 10
        }
        
        self.currentPoints = [NSValue(cgPoint: CGPoint(x: 0, y: newZoom))] + self.currentPoints
        
        self.bezierViewController.points = self.currentPoints
        self.bezierViewController.pointsChanged()
    }
    
    func zoomsEmptied() {
        self.currentPoints = []
        self.bezierViewController.points = [NSValue(cgPoint: CGPoint(x: 0, y: 0))]
        self.bezierViewController.pointsChanged()
        self.moveToFirstPoint()
    }
}

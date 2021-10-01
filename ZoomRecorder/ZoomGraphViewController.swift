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
    
    var maxZoom:CGFloat = 0.0
    
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
        
//        view.layer.cornerRadius = 10
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        
        return view
    }()
    
    var bezierViewController:BezierViewController = BezierViewController(points: [], with: UIColor(hex: "#ff7ad1"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChild(self.bezierViewController)
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let leftBorder = CALayer()
        leftBorder.backgroundColor = UIColor.white.cgColor
        leftBorder.frame = CGRect(x: 0, y: 0, width: 1.0, height: self.view.frame.size.height)
        
        let rightBorder = CALayer()
        rightBorder.backgroundColor = UIColor.white.cgColor
        rightBorder.frame = CGRect(x: self.bezierContainer.frame.size.width-1.0, y: 0, width: 1.0, height: self.bezierContainer.frame.size.height)
        
        self.view.layer.addSublayer(leftBorder)
        self.view.layer.addSublayer(rightBorder)
    }
    
    func moveToNextPoint() {
        if (0 < self.contentOffset) {
            self.contentOffset = self.contentOffset - 1
            self.bezierContainer.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
        }
        print(self.contentOffset)
    }
    
    func moveToPrevPoint() {
        if (0 <= self.contentOffset) {
            self.contentOffset = min(self.currentPoints.count, self.contentOffset + 1)
            self.bezierContainer.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
        }
        print(self.contentOffset)
    }
    
    func moveToFirstPoint() {
        self.contentOffset = self.currentPoints.count
        self.bezierContainer.setContentOffset(CGPoint(x: self.contentOffset, y: 0), animated: false)
    }
    
    func moveToLastPoint() {
        self.bezierContainer.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}

extension ZoomGraphViewController : ZoomControllerDelegate {
    func zoomAdded(zoom: CGFloat) {
        self.currentPoints = self.currentPoints.map { (value) -> NSValue in
            let point:CGPoint = value.cgPointValue
            return NSValue(cgPoint: CGPoint(x: point.x + 1, y: point.y))
        }

        let newZoom:CGFloat =  zoom/self.maxZoom * self.view.frame.size.height
        
        print(newZoom)
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

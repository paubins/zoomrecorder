//
//  ViewController.swift
//  ZoomRecorder
//
//  Created by Patrick Aubin on 7/31/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import UIKit
import SwiftyCam
import AVFoundation
import Cartography
import AVKit
import Shift
import AZExpandableIconListView


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

class ViewController: SwiftyCamViewController {

    var zooms:[CGFloat] = []
    var playbackTimer:Timer!
    
    var currentIndex:Int = 0
    
    var playbackZoomButton:ShiftButton!
    
    var recordNewZoomButton:UIButton!
    var expandable:AZExpandableIconListView!
    var bezierViewController:BezierViewController = BezierViewController(points: [], with: .blue)
    
    var currentPoints:[NSValue] = []
    
    lazy var playButton:UIButton = {
        let button:UIButton = UIButton(frame: .zero)
        button.backgroundColor = .blue
        
        return button
    }()
    
    lazy var recordButton:UIButton = {
        let button:UIButton = UIButton(frame: .zero)
        button.backgroundColor = .red
        
        return button
    }()
    
    lazy var resetButton:UIButton = {
        let button:UIButton = UIButton(frame: .zero)
        button.backgroundColor = .black
        
        
        return button
    }()
    
    lazy var shiftView:ShiftView = {
        var shiftView = ShiftView()
        
        shiftView.setColors([UIColor.orange,
                             UIColor.red,
                             UIColor.blue,
                             UIColor.purple])
        
        // set animation duration
        shiftView.animationDuration(3.0)
        
        return shiftView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cameraDelegate = self
        

        // start animation
        shiftView.startTimedAnimation()
        
        self.view.addSubview(self.shiftView)
        self.view.addSubview(self.playButton)
        self.view.addSubview(self.recordButton)
        self.view.addSubview(self.resetButton)
        
        self.playButton.addTarget(self, action: #selector(playbackZoom), for: .touchUpInside)
        self.resetButton.addTarget(self, action: #selector(recordNewZoom), for: .touchUpInside)
        
        self.addChildViewController(self.bezierViewController)
        
        self.view.addSubview(self.bezierViewController.view)
        
//        self.bezierViewController.view.addSubview(self.shiftView)
//        
//        constrain(self.shiftView) { (view) in
//            view.left == view.superview!.left
//            view.right == view.superview!.right
//            view.top == view.superview!.top
//            view.bottom == view.superview!.bottom
//        }
        
        self.bezierViewController.view.clipsToBounds = true

        constrain(self.playButton, self.bezierViewController.view, self.resetButton) { (view1, view, view3) in
            view1.left == view.superview!.left
            view1.right == view.left
            view1.bottom == view.superview!.bottom
            view1.height == 110
            view1.width == 50
            
            view.bottom == view.superview!.bottom
            view.height == 110
            
            view3.right == view3.superview!.right
            view3.left == view.right
            view3.bottom == view3.superview!.bottom
            view3.width == 50
            view3.height == 110
        }
        
        self.bezierViewController.points = [NSValue(cgPoint: CGPoint(x: 0, y: 0)),
                                            NSValue(cgPoint: CGPoint(x: 20, y: 20)),
                                            NSValue(cgPoint: CGPoint(x: 40, y: 40))]
        
        self.bezierViewController.pointsChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        playbackZoomButton.startMotionAnimation()
//        self.changeZoom(zoom: 1.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeZoom(zoom: CGFloat) {
        print(zoom)
        
        do {
            let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
            try captureDevice?.lockForConfiguration()
            
            captureDevice?.videoZoomFactor = zoom

            captureDevice?.unlockForConfiguration()
        } catch {
            print("[SwiftyCam]: Error locking configuration")
        }
    }
    
    func recordNewZoom() {
        self.resetButton.shake()
        
        self.zooms = []
        self.currentIndex = 0
        self.changeZoom(zoom: 1)
        
        self.currentPoints = []
        
        self.bezierViewController.points = [NSValue(cgPoint: CGPoint(x: 0, y: 0))]
        self.bezierViewController.pointsChanged()
    }
    
    func playbackZoom() {
        self.playButton.shake()
        self.playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            if self.currentIndex < self.zooms.count {
                self.changeZoom(zoom: self.zooms[self.currentIndex])
            } else {
                timer.invalidate()
                if (self.isVideoRecording) {
                    self.stopVideoRecording()
                }
            }
            
            self.currentIndex += 1
        }
        
        self.playbackTimer.fire()
    }
    
    func recordZoom() {
        self.recordButton.shake()
        self.startVideoRecording()
        self.playbackZoom()
    }
}

extension ViewController : SwiftyCamViewControllerDelegate {
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("finished")
        
        let playerViewController:AVPlayerViewController = AVPlayerViewController()
        
        playerViewController.player = AVPlayer(url: url)
        
        self.present(playerViewController, animated: true) { 
            print("presented")
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
        zooms.append(zoom)
        
        let currentAvg:CGFloat = self.bezierViewController.view.frame.size.width/CGFloat(self.currentPoints.count)
        
        print("CurrentAvg: \(currentAvg)")
        
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
}

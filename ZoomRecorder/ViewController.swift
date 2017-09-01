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


class ViewController: SwiftyCamViewController {

    var playbackTimer:Timer!
    
    var playbackZoomButton:ShiftButton!
    
    var recordNewZoomButton:UIButton!
    var expandable:AZExpandableIconListView!
    
    lazy var zoomController:ZoomController = {
        let zoomController:ZoomController = ZoomController()
        zoomController.delegate = self.zoomGraphViewController
        return zoomController
    }()
    
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
    
    lazy var zoomGraphViewController:ZoomGraphViewController = ZoomGraphViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cameraDelegate = self
        
        self.swipeToZoom = false
        self.pinchToZoom = true
        self.swipeToZoomInverted = false

        // start animation
        shiftView.startTimedAnimation()
        
        self.view.addSubview(self.shiftView)
        self.view.addSubview(self.playButton)
        self.view.addSubview(self.recordButton)
        self.view.addSubview(self.resetButton)
        
        self.addChildViewController(self.zoomGraphViewController)
        
        self.view.addSubview(self.zoomGraphViewController.view)
        
        self.playButton.addTarget(self, action: #selector(playbackZoom), for: .touchUpInside)
        self.resetButton.addTarget(self, action: #selector(recordNewZoom), for: .touchUpInside)

        constrain(self.playButton, self.zoomGraphViewController.view, self.resetButton) { (view1, view, view3) in
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
        
        if (self.playbackTimer != nil) {
            self.playbackTimer.invalidate()
            self.playbackTimer = nil
        }
        
        self.zoomController.emptyZooms()
        
        self.changeZoom(zoom: 1)
    }
    
    func playbackZoom() {
        self.playButton.shake()
        self.playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            if let zoom = self.zoomController.getNextZoom() {
                self.zoomGraphViewController.moveToNextPoint()
                self.changeZoom(zoom: zoom)
            } else {
                timer.invalidate()
                if (self.isVideoRecording) {
                    self.stopVideoRecording()
                }
                
                self.zoomController.resetZoomTraversal()
                self.zoomGraphViewController.moveToFirstPoint()
            }
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
        
        if (self.zoomController.canAddZoom(zoom: zoom)) {
            self.zoomController.addZoom(zoom: zoom)
        }
    }
}

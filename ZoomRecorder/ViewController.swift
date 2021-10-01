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
import SwiftyButton
import VerticalSlider
import Photos
import AssetsLibrary
import Hue

class StackableButton : UIStackView {
    
}

class ViewController: SwiftyCamViewController {

    var playbackTimer:Timer!
    
    var recordNewZoomButton:UIButton!
    
    var exportSession:AVAssetExportSession!
    
    var currentZoomInterval:TimeInterval = 0.02
    
    var currentMaxZoom:CGFloat = 0.0
    
    var isManual:Bool = false
    
    lazy var zoomController:ZoomController = {
        let zoomController:ZoomController = ZoomController()
        zoomController.delegate = self.zoomGraphViewController
        
        return zoomController
    }()
    
    lazy var playButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 3
        button.cornerRadius = 5
        button.isEnabled = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        
        button.addTarget(self, action: #selector(noManual), for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = "Auto"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let button2:PressableButton = PressableButton(frame: .zero)
        button2.backgroundColor = .clear
        button2.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button2.shadowHeight = 3
        button2.cornerRadius = 5
        button2.isEnabled = false
        button2.setTitleColor(.black, for: .normal)
        button2.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button2.titleLabel?.font = button.titleLabel?.font.withSize(12)
        
        button2.addTarget(self, action: #selector(useManual), for: .touchUpInside)
        
        let label2 = UILabel(frame: .zero)
        label2.text = "Manual"
        label2.font = UIFont.systemFont(ofSize: 10)
        label2.textAlignment = .center

        let labelOutside = UIStackView(arrangedSubviews: [label2, button2, label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    lazy var recordButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .red
        
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 3
        button.cornerRadius = 5
        
//        button.setTitle("Record", for: .normal)
        
        let label = UILabel(frame: .zero)
        label.text = "Record"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let labelOutside = UIStackView(arrangedSubviews: [label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    lazy var resetButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 3
        button.cornerRadius = 5
        button.isEnabled = false
//        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.addTarget(self, action: #selector(recordNewZoom),  for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = "Reset"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let button2:PressableButton = PressableButton(frame: .zero)
        button2.backgroundColor = .clear
        button2.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button2.shadowHeight = 3
        button2.cornerRadius = 5
        button2.isEnabled = false
//        button.setTitle("Reset", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button2.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button2.addTarget(self, action: #selector(playbackZoom),  for: .touchUpInside)
        
        let label2 = UILabel(frame: .zero)
        label2.text = "Record"
        label2.font = UIFont.systemFont(ofSize: 10)
        label2.textAlignment = .center
        
        
        let labelOutside = UIStackView(arrangedSubviews: [label2, button2, label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    lazy var recordingLabel:UILabel = {
        let label:UILabel = UILabel()
        label.text = "Recording Video..."
        label.backgroundColor = .red
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var slowForwardButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 5
        button.cornerRadius = 5
        
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)

        button.addTarget(self, action: #selector(self.slowerMoveForwardZoom), for: .touchDown)
        button.addTarget(self, action: #selector(self.slowerMoveForwardZoom), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.slowerMoveForwardZoom), for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = "Slow F"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let labelOutside = UIStackView(arrangedSubviews: [label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    
    lazy var forwardButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 5
        button.cornerRadius = 5
        
//        button.setTitle(, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)

        button.addTarget(self, action: #selector(self.slowMoveForwardZoom), for: .touchDown)
        button.addTarget(self, action: #selector(self.slowMoveForwardZoom), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.slowMoveForwardZoom), for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = "Forward"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let labelOutside = UIStackView(arrangedSubviews: [label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    lazy var slowBackButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 5
        button.cornerRadius = 5
        
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)

        button.addTarget(self, action: #selector(self.slowerMoveBackZoom), for: .touchDown)
        button.addTarget(self, action: #selector(self.slowerMoveBackZoom), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.slowerMoveBackZoom), for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = "Slow Back"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let labelOutside = UIStackView(arrangedSubviews: [label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        return labelOutside
    }()
    
    lazy var backButton:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 5
        button.cornerRadius = 5
        
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        
        button.addTarget(self, action: #selector(self.slowMoveBackZoom), for: .touchDown)
        button.addTarget(self, action: #selector(self.slowMoveBackZoom), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.slowMoveBackZoom), for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = "Back"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let labelOutside = UIStackView(arrangedSubviews: [label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    lazy var moveToStart:UIStackView = {
        let button:PressableButton = PressableButton(frame: .zero)
        button.backgroundColor = .clear
        button.colors = .init(button: UIColor(hex: "#ff7ad1"), shadow: UIColor(hex: "#ff00a6"))
        button.shadowHeight = 5
        button.cornerRadius = 5
        
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "DDCHardware-Condensed", size: 12)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        
        button.addTarget(self, action: #selector(self.moveToStartAction), for: .touchUpInside)
        
        let label = UILabel(frame: .zero)
        label.text = ">>|"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        let labelOutside = UIStackView(arrangedSubviews: [label, button])
        labelOutside.axis = .vertical
        labelOutside.spacing = 0
        labelOutside.distribution = .fillProportionally
        
        return labelOutside
    }()
    
    lazy var buttonsContainerView:UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 10
        
        view.addArrangedSubview(self.slowBackButton)
        view.addArrangedSubview(self.backButton)
        view.addArrangedSubview(self.forwardButton)
        view.addArrangedSubview(self.slowForwardButton)
        view.addArrangedSubview(self.moveToStart)
        
        return view
    }()

    lazy var zoomGraphViewController:ZoomGraphViewController = {
        let vc = ZoomGraphViewController()
        vc.maxZoom = self.currentMaxZoom
        return vc
    }()
    lazy var verticalSlider: VerticalSlider = {
        var verticalSlider:VerticalSlider = VerticalSlider()
        
        if (currentCamera == .front) {
            let captureDevice = AVCaptureDevice.devices()[1]
            verticalSlider.slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
            verticalSlider.slider.minimumValue = 1.0
            verticalSlider.slider.maximumValue = Float(captureDevice.activeFormat.videoMaxZoomFactor)
            self.currentMaxZoom = captureDevice.activeFormat.videoMaxZoomFactor
            verticalSlider.slider.value = 1.0
        } else {
            let captureDevice = AVCaptureDevice.devices().first
            verticalSlider.slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
            verticalSlider.slider.minimumValue = 1.0
            verticalSlider.slider.maximumValue = Float((captureDevice?.activeFormat.videoMaxZoomFactor)!)
            self.currentMaxZoom = captureDevice!.activeFormat.videoMaxZoomFactor
            verticalSlider.slider.value = 1.0
        }
        
        return verticalSlider
    }()
    
    override func viewDidLoad() {
        self.videoGravity = .resizeAspectFill
        self.defaultCamera = .front
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cameraDelegate = self
        
        self.swipeToZoom = false
        self.pinchToZoom = true
        self.swipeToZoomInverted = false
        
        self.view.addSubview(self.playButton)
        self.view.addSubview(self.recordButton)
        self.view.addSubview(self.resetButton)
        self.view.addSubview(self.verticalSlider)
        self.view.addSubview(self.recordingLabel)
        self.view.addSubview(self.buttonsContainerView)
        
        self.buttonsContainerView.isHidden = false
        
        self.addChild(self.zoomGraphViewController)
        
        self.view.addSubview(self.zoomGraphViewController.view)

        constrain(self.playButton, self.zoomGraphViewController.view, self.resetButton, self.buttonsContainerView) { (view1, view, view3, view4) in
            view1.left == view.superview!.left + 5
            view1.right == view.left - 10
            view1.bottom == view.superview!.bottom - 30
            view1.height == 120
            view1.width == 50
            
            view.bottom == view.superview!.bottom - 30
            view.height == 110
            
            view3.right == view3.superview!.right - 5
            view3.left == view.right + 10
            view3.bottom == view3.superview!.bottom - 30
            view3.width == 50
            view3.height == 120
            
            view4.bottom == view.top - 10
            view4.centerX == view.superview!.centerX
            view4.right == view4.superview!.right - 5
            view4.left == view4.superview!.left + 5
            view4.height == 60
        }
        
        constrain(self.recordingLabel, self.buttonsContainerView, self.zoomGraphViewController.view) { (view1, view2, view3) in
            view1.bottom == view2.top
            view1.width == view1.superview!.width
            view1.height == 30
            view1.centerX == view1.superview!.centerX
            
        }
        
        constrain(self.verticalSlider) { (view) in
            view.centerY == view.superview!.centerY
            view.right == view.superview!.right - 15
            view.height == 300
            view.width == 30
        }
        
        self.disableAllButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
        switch cameraAuthorizationStatus {
        case .denied:
            self.verticalSlider.isEnabled = false
            break
        case .restricted:
            self.verticalSlider.isEnabled = false
            break
        case .notDetermined:
            self.verticalSlider.isEnabled = true
        default:
            self.verticalSlider.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeZoom(zoom: CGFloat) {
        do {
            if (currentCamera == .front) {
                let captureDevice = AVCaptureDevice.devices()[1]
                try captureDevice.lockForConfiguration()
                captureDevice.videoZoomFactor = zoom
                captureDevice.unlockForConfiguration()
            } else {
                let captureDevice = AVCaptureDevice.devices().first
                try captureDevice?.lockForConfiguration()
                captureDevice?.videoZoomFactor = zoom
                captureDevice?.unlockForConfiguration()
            }
        } catch {
            print("[SwiftyCam]: Error locking configuration")
        }
    }
    
    func enableButton(button: UIStackView) {
        let button1:UIButton = button.arrangedSubviews[1] as! UIButton
        if (!button1.isEnabled) {
            button1.isEnabled = true
        }
        
        if button.arrangedSubviews.count == 4 {
            let button2:UIButton = button.arrangedSubviews[3] as! UIButton
            if (!button2.isEnabled) {
                button2.isEnabled = true
            }
        }
    }
    
    func disableButton(button: UIStackView) {
        let button1:UIButton = button.arrangedSubviews[1] as! UIButton
        if (button1.isEnabled) {
            button1.isEnabled = false
        }
        
        if button.arrangedSubviews.count == 4 {
            let button2:UIButton = button.arrangedSubviews[3] as! UIButton
            if (button2.isEnabled) {
                button2.isEnabled = false
            }
        }
    }
    
    func keepPlayButtonSelected() {
        if playButton.arrangedSubviews.count == 4 {
            let button2:UIButton = playButton.arrangedSubviews[3] as! UIButton
            button2.isEnabled = false
        }
    }
    
    func unselectPlayButton() {
        if playButton.arrangedSubviews.count == 4 {
            let button2:UIButton = playButton.arrangedSubviews[3] as! UIButton
            button2.isEnabled = true
        }
    }
    
    func keepManualButtonSelected() {
        if playButton.arrangedSubviews.count == 4 {
            let button2:UIButton = playButton.arrangedSubviews[1] as! UIButton
            button2.isEnabled = false
        }
    }
    
    func unselectManualButton() {
        if playButton.arrangedSubviews.count == 4 {
            let button2:UIButton = resetButton.arrangedSubviews[1] as! UIButton
            button2.isEnabled = true
        }
    }
    
    
    func keepResetButtonSelected() {
        if resetButton.arrangedSubviews.count == 4 {
            let button2:UIButton = playButton.arrangedSubviews[3] as! UIButton
            button2.isEnabled = true
        }
    }
    
    func unselectResetButton() {
        if resetButton.arrangedSubviews.count == 4 {
            let button2:UIButton = resetButton.arrangedSubviews[3] as! UIButton
            button2.isEnabled = false
        }
    }
    
    @objc func sliderChanged() {
        let zoom = CGFloat(self.verticalSlider.slider.value)
        print("Slider changed: \(zoom)")
        self.changeZoom(zoom: zoom)
        
        if (self.playbackTimer != nil) {
            self.playbackTimer.invalidate()
        }

        self.enableAllButtons()
        
        if (self.zoomController.canAddZoom(zoom: zoom)) {
            self.zoomController.addZoom(zoom: zoom)
            self.zoomGraphViewController.moveToLastPoint()
        }
    }
    
    func disableSomeButtons() {
        self.disableButton(button: self.playButton)
        self.disableButton(button: self.resetButton)
    }
    
    func disableAllButtons() {
        self.disableButton(button: self.playButton)
        self.disableButton(button: self.resetButton)
        self.disableButton(button: self.forwardButton)
        self.disableButton(button: self.moveToStart)
        self.disableButton(button: self.slowBackButton)
        self.disableButton(button: self.slowForwardButton)
        self.disableButton(button: self.backButton)
    }
    
    func enableAllButtons() {
        self.enableButton(button: self.playButton)
        self.enableButton(button: self.resetButton)
        self.enableButton(button: self.forwardButton)
        self.enableButton(button: self.moveToStart)
        self.enableButton(button: self.slowBackButton)
        self.enableButton(button: self.slowForwardButton)
        self.enableButton(button: self.backButton)
    }
    
    @objc func recordNewZoom() {
        self.recordingLabel.isHidden = true
        self.verticalSlider.isUserInteractionEnabled = true
        self.disableAllButtons()
        if (self.playbackTimer != nil) {
            self.playbackTimer.invalidate()
            self.playbackTimer = nil
        }
        
        self.verticalSlider.slider.value = 1.0
        self.zoomController.emptyZooms()
        
        self.changeZoom(zoom: 1)
    }
    
    @objc func moveForwardZoom() {
        if (self.playbackTimer != nil) {
            self.playbackTimer.invalidate()
            self.playbackTimer = nil
        } else {
            self.playbackTimer = Timer.scheduledTimer(withTimeInterval: currentZoomInterval, repeats: true) { (timer) in
                if let zoom = self.zoomController.getNextZoom() {
                    self.changeZoom(zoom: zoom)
                    self.verticalSlider.slider.value = Float(zoom)
                    self.zoomGraphViewController.moveToNextPoint()
                }
            }
            
            self.playbackTimer.fire()
        }
    }
    
    @objc func slowMoveForwardZoom() {
        currentZoomInterval = 0.02
        self.moveForwardZoom()
    }
    
    @objc func slowerMoveForwardZoom() {
        currentZoomInterval = 0.05
        self.moveForwardZoom()
    }
    
    @objc func moveBackZoom() {
        if (self.playbackTimer != nil) {
            self.playbackTimer.invalidate()
            self.playbackTimer = nil
        } else {
            self.playbackTimer = Timer.scheduledTimer(withTimeInterval: currentZoomInterval, repeats: true) { (timer) in
                if let zoom = self.zoomController.getPrevZoom() {
                    self.changeZoom(zoom: zoom)
                    self.verticalSlider.slider.value = Float(zoom)
                    self.zoomGraphViewController.moveToPrevPoint()
                }
            }
            
            self.playbackTimer.fire()
        }
    }
    
    @objc func slowMoveBackZoom() {
        currentZoomInterval = 0.02
        self.moveBackZoom()
    }
    
    @objc func slowerMoveBackZoom() {
        currentZoomInterval = 0.05
        self.moveBackZoom()
    }
    
    @objc func useManual() {
        self.isManual = true
        self.unselectPlayButton()
        self.keepManualButtonSelected()
    }
    
    @objc func noManual() {
        self.isManual = false
        self.keepPlayButtonSelected()
        self.unselectManualButton()
    }
    
    @objc func playbackZoom() {
        
        guard self.zoomController.validZooms() else { return }
        
        //Photos
       let photos = PHPhotoLibrary.authorizationStatus()
       if photos == .notDetermined {
           PHPhotoLibrary.requestAuthorization({status in
               if status == .authorized {
                    DispatchQueue.main.async {
                        self.playbackZoom()
                    }
               } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Uh oh!",
                                          message: "We need permission to your photo library to store the recorded zoom.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                            print("denied")
                        }))
                        self.present(alertController, animated: true) {
                            print("presented")
                        }
                    }
               }
           })
       } else if photos == .authorized {
            self.startVideoRecording()
            self.recordingLabel.isHidden = false
            self.verticalSlider.isUserInteractionEnabled = false
            if (self.isManual) {
                self.disableSomeButtons()
            } else {
                self.disableAllButtons()
                
                self.playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
                    if let zoom = self.zoomController.getNextZoom() {
                        self.changeZoom(zoom: zoom)
                        self.verticalSlider.slider.value = Float(zoom)
                        self.zoomGraphViewController.moveToNextPoint()
                    } else {
                        timer.invalidate()
                        if (self.isVideoRecording) {
                            self.stopVideoRecording()
                        }
                        
                        self.zoomController.resetZoomTraversal()
                        self.zoomGraphViewController.moveToFirstPoint()
                    }
                }
            }
       } else {
            let alertController = UIAlertController(title: "Uh oh!",
                              message: "We need permission to your photo library to store the recorded zoom.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                print("denied")
            }))
            self.present(alertController, animated: true) {
                print("presented")
            }
       }
    }
    
    @objc func moveToStartAction() {
        self.verticalSlider.slider.value = Float(0)
        self.zoomGraphViewController.moveToFirstPoint()
        self.zoomController.resetZoomTraversal()
        self.changeZoom(zoom: 1.0)
    }
}

extension ViewController : SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        self.recordNewZoom()
        if (camera == .front) {
            let captureDevice = AVCaptureDevice.devices()[1]
            verticalSlider.slider.maximumValue = Float(captureDevice.activeFormat.videoMaxZoomFactor)
            self.currentMaxZoom = captureDevice.activeFormat.videoMaxZoomFactor
            self.zoomGraphViewController.maxZoom = self.currentMaxZoom
        } else {
            let captureDevice = AVCaptureDevice.devices().first
            verticalSlider.slider.maximumValue = Float((captureDevice?.activeFormat.videoMaxZoomFactor)!)
            self.currentMaxZoom = captureDevice!.activeFormat.videoMaxZoomFactor
            self.zoomGraphViewController.maxZoom = self.currentMaxZoom
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("finished")
        
        let playerViewController:AVPlayerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: url)
        self.present(playerViewController, animated: true) { 
            
        }
        print(url)
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { (completed, error) in
            print(completed)
            print(error)
            if (completed) {
                DispatchQueue.main.async {
                    self.recordNewZoom()
                    let fileManager = FileManager.default
                    do {
                        try fileManager.removeItem(atPath: url.path)
                    } catch {
                       print("Could not clear temp folder: \(error)")
                    }
                }
            }
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
        
        if (self.zoomController.canAddZoom(zoom: zoom)) {
            self.zoomController.addZoom(zoom: zoom)
            self.verticalSlider.slider.value = Float(zoom)
        }
    }
}

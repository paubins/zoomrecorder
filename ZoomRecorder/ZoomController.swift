//
//  ZoomController.swift
//  ZoomRecorder
//
//  Created by Patrick Aubin on 8/31/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

import Foundation

protocol ZoomControllerDelegate {
    func zoomAdded(zoom: CGFloat)
    func zoomsEmptied()
    
}

class ZoomController : NSObject {
    
    private var previousZoom:CGFloat = 0
    private var currentIndex:Int = 0
    
    var delegate:ZoomControllerDelegate!
    
    private var zooms:[CGFloat] = [] {
        didSet {
            if (0 < self.zooms.count) {
                self.delegate.zoomAdded(zoom: self.zooms.last!)
            }
        }
    }
    
    func validZooms() -> Bool {
        return 0 < self.zooms.count 
    }
    
    func canAddZoom(zoom: CGFloat) -> Bool {
        return self.previousZoom != zoom
    }
    
    func addZoom(zoom: CGFloat) {
        self.previousZoom = zoom
        self.zooms.append(zoom)
    }
    
    func emptyZooms() {
        self.currentIndex = 0
        self.zooms = []
        
        self.delegate.zoomsEmptied()
    }
    
    func getNextZoom() -> CGFloat! {
        if (self.currentIndex == self.zooms.count) {
            return nil
        }
        
        if (self.currentIndex < 0) {
            self.currentIndex = 0
        }
        
        let zoom:CGFloat = self.zooms[self.currentIndex]
        self.currentIndex = self.currentIndex+1
        return zoom
    }
    
    func getPrevZoom() -> CGFloat! {
        if (self.currentIndex == -1) {
            return nil
        }
        
        if (self.currentIndex == self.zooms.count) {
            self.currentIndex = self.zooms.count-1
        }
        
        let zoom:CGFloat = self.zooms[self.currentIndex]
        self.currentIndex = self.currentIndex-1
        return zoom
    }
    
    func resetZoomTraversal() {
        self.currentIndex = 0
    }
    
}

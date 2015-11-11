//
//  Cursor.swift
//  Swiftris
//
//  Created by Bruno Chroniaris on 11/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class Cursor: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    var timer: NSTimer?
    
    private func setup() {
        self.addTarget(self, action: "touchUp:event:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: "touchDown:event:", forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: "touchUp:event:", forControlEvents: UIControlEvents.TouchUpOutside)
    }
    
    @objc func move(sender: AnyObject){}
    
    @objc final func touchUp(sender:UIButton!,event:UIEvent!){
        self.timer?.invalidate()
    }
    @objc final func touchDown(sender:UIButton!,event:UIEvent!){
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "move:", userInfo: nil, repeats: true)
        self.timer?.fire()
    }
}
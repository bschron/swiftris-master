//
//  RightCursor.swift
//  Swiftris
//
//  Created by Bruno Chroniaris on 11/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RightCursor: Cursor {
    override func move(sender: AnyObject) {
        super.move(sender)
        Swiftris.singleton.moveShapeRight()
    }
}
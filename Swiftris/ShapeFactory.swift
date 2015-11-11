//
//  ShapeFactory.swift
//  Swiftris
//
//  Created by Bruno Chroniaris on 10/10/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

import Foundation
import UIKit

class ShapeFactory {
    private lazy var pool: Set<Shape> = Set<Shape>()
    
    private init(){}
    
    final func freeShapes() {
        for shape in pool {
            shape.isFree = true
        }
    }
    
    final func colapseShapes() {
        for shape in self.pool.filter({$0.isFree == false}) {
            shape.moveTo(Swiftris.previewColumn, row: Swiftris.previewRow)
        }
    }
    
    final func make(startingColumn: Int, startingRow: Int) -> Shape {
        let type = ShapeFactory.getRandomType()
        
        var result: Shape?
        
        for cur in self.pool {
            if cur.isFree && cur.dynamicType.self === type {
                result = cur
                break
            }
        }
        
        if result == nil {
            result = ShapeFactory.initShape(type, startingColumn: startingColumn, startingRow: startingRow)
        }
        
        result!.isFree = false
        
        self.pool.insert(result!)
        
        return result!
    }
    
    class var numShapeTypes: UInt32 {
        struct Wrap {
            static let numShapeTypes: UInt32 = 7
        }
        
        return Wrap.numShapeTypes
    }
    
    class var singleton: ShapeFactory {
        struct Wrap {
            static let singleton: ShapeFactory = ShapeFactory()
        }
        
        return Wrap.singleton
    }
    
    class private func initShape<T: Shape>(type : T.Type, startingColumn:Int, startingRow:Int) -> T? {
        var result: T?
        
        if type === SquareShape.self {
            result = SquareShape(column:startingColumn, row:startingRow) as? T
        }
        else if type === LineShape.self {
            result = LineShape(column:startingColumn, row:startingRow) as? T
        }
        else if type === TShape.self {
            result = TShape(column:startingColumn, row:startingRow) as? T
        }
        else if type === SShape.self {
            result = SShape(column:startingColumn, row:startingRow) as? T
        }
        else if type === ZShape.self {
            result = ZShape(column:startingColumn, row:startingRow) as? T
        }
        else if type === LShape.self {
            result = LShape(column:startingColumn, row:startingRow) as? T
        }
        else if type === JShape.self {
            result = JShape(column:startingColumn, row:startingRow) as? T
        }
        
        return result
    }
    
    class private func getRandomType<T: Shape>() -> T.Type {
        switch Int(arc4random_uniform(self.numShapeTypes)) {
        case 0:
            return SquareShape.self as! T.Type
        case 1:
            return LineShape.self as! T.Type
        case 2:
            return TShape.self as! T.Type
        case 3:
            return SShape.self as! T.Type
        case 4:
            return ZShape.self as! T.Type
        case 5:
            return LShape.self as! T.Type
        default:
            return JShape.self as! T.Type
        }
    }
}
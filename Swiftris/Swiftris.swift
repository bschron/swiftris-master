class Swiftris {
    static let numColumns = 10
    static let numRows = 20
    
    static let startingColumn = 4
    static let startingRow = 0
    
    static let previewColumn = 12
    static let previewRow = 1
    
    static let pointsPerLine = 10
    static let levelThreshold = 1000
    
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    
    var score:Int
    var level:Int
    
    static let singleton: Swiftris = Swiftris()
    
    private init() {
        score = 0
        level = 1
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: Swiftris.numColumns, rows: Swiftris.numRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = ShapeFactory.singleton.make(Swiftris.previewColumn, startingRow: Swiftris.previewRow)
        }
        GameDidBeginNotificationHandler.singleton.post()
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = ShapeFactory.singleton.make(Swiftris.previewColumn, startingRow: Swiftris.previewRow)
        fallingShape?.moveTo(Swiftris.startingColumn, row: Swiftris.startingRow)
        if detectIllegalPlacement() {
            nextShape = fallingShape
            nextShape!.moveTo(Swiftris.previewColumn, row: Swiftris.previewRow)
            endGame()
            return (nil, nil)
        }
        
        nextShape?.row = Swiftris.previewRow
        nextShape?.column = Swiftris.previewColumn
        
        return (fallingShape, nextShape)
    }
    
    func detectIllegalPlacement() -> Bool {
        if let shape = fallingShape {
            for block in shape.blocks {
                if block.column < 0 || block.column >= Swiftris.numColumns
                    || block.row < 0 || block.row >= Swiftris.numRows {
                    return true
                } else if blockArray[block.column, block.row] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    func settleShape() {
        if let shape = fallingShape {
            for block in shape.blocks {
                blockArray[block.column, block.row] = block
            }
            fallingShape = nil
            ShapeDidLandNotificationHandler.singleton.post()
        }
    }
    
    
    func detectTouch() -> Bool {
        if let shape = fallingShape {
            for bottomBlock in shape.bottomBlocks {
                if bottomBlock.row == Swiftris.numRows - 1 ||
                    blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                        return true
                }
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        GameDidEndNotificationHandler.singleton.post()
    }
    
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        for row in 0..<Swiftris.numRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<Swiftris.numColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                    blockArray[column, row] = nil
                }
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for var row = Swiftris.numRows - 1; row > 0; row-- {
            var rowOfBlocks = Array<Block>()
            for column in 0..<Swiftris.numColumns {
                if let block = blockArray[column, row] {
                    rowOfBlocks.append(block)
                }
            }
            if rowOfBlocks.count == Swiftris.numColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        if removedLines.count == 0 {
            return ([], [])
        }
        let pointsEarned = removedLines.count * Swiftris.pointsPerLine * level
        score += pointsEarned
        if score >= level * Swiftris.levelThreshold {
            level += 1
            GameDidLevelupNotificationHandler.singleton.post()
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<Swiftris.numColumns {
            var fallenBlocksArray = Array<Block>()
            for var row = removedLines[0][0].row - 1; row > 0; row-- {
                if let block = blockArray[column, row] {
                    var newRow = row
                    while (newRow < Swiftris.numRows - 1 && blockArray[column, newRow + 1] == nil) {
                        newRow++
                    }
                    block.row = newRow
                    blockArray[column, row] = nil
                    blockArray[column, newRow] = block
                    fallenBlocksArray.append(block)
                }
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    func dropShape() {
        if let shape = fallingShape {
            while detectIllegalPlacement() == false {
                shape.lowerShapeByOneRow()
            }
            shape.raiseShapeByOneRow()
            ShapeDidDropNotificationHandler.singleton.post()
        }
    }
    
    func letShapeFall() {
        if let shape = fallingShape {
            shape.lowerShapeByOneRow()
            if detectIllegalPlacement() {
                shape.raiseShapeByOneRow()
                if detectIllegalPlacement() {
                    endGame()
                } else {
                    settleShape()
                }
            } else {
                ShapeDidMoveNotificationHandler.singleton.post()
                if detectTouch() {
                    settleShape()
                }
            }
        }
    }
    
    func rotateShape() {
        if let shape = fallingShape {
            shape.rotateClockwise()
            if detectIllegalPlacement() {
                shape.rotateCounterClockwise()
            } else {
                ShapeDidMoveNotificationHandler.singleton.post()
            }
        }
    }
    
    
    func moveShapeLeft() {
        if let shape = fallingShape {
            shape.shiftLeftByOneColumn()
            if detectIllegalPlacement() {
                shape.shiftRightByOneColumn()
                return
            }
            ShapeDidMoveNotificationHandler.singleton.post()
        }
    }
    
    func moveShapeRight() {
        if let shape = fallingShape {
            shape.shiftRightByOneColumn()
            if detectIllegalPlacement() {
                shape.shiftLeftByOneColumn()
                return
            }
            ShapeDidMoveNotificationHandler.singleton.post()
        }
    }
}
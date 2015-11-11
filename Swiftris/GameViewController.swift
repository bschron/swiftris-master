//
//  GameViewController.swift
//  Swiftris
//
//  Created by Stanley Idesis on 7/14/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, UIGestureRecognizerDelegate {

    var scene: GameScene!
    var panPointReference:CGPoint?
    
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupObserver()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        
        Swiftris.singleton.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func setupObserver() {
        GameDidEndNotificationHandler.singleton.observe(self, selector: Selector("gameDidEnd:"))
        GameDidBeginNotificationHandler.singleton.observe(self, selector: Selector("gameDidBegin:"))
        GameDidLevelupNotificationHandler.singleton.observe(self, selector: Selector("gameDidLevelUp:"))
        ShapeDidMoveNotificationHandler.singleton.observe(self, selector: Selector("gameShapeDidMove:"))
        ShapeDidDropNotificationHandler.singleton.observe(self, selector: Selector("gameShapeDidDrop:"))
        ShapeDidLandNotificationHandler.singleton.observe(self, selector: Selector("gameShapeDidLand:"))
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        Swiftris.singleton.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    Swiftris.singleton.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    Swiftris.singleton.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        Swiftris.singleton.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = gestureRecognizer as? UISwipeGestureRecognizer {
            if let _ = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let _ = gestureRecognizer as? UIPanGestureRecognizer {
            if let _ = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func didTick() {
        Swiftris.singleton.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = Swiftris.singleton.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(notification: NSNotification) {
        levelLabel.text = "\(Swiftris.singleton.level)"
        scoreLabel.text = "\(Swiftris.singleton.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if Swiftris.singleton.nextShape != nil && Swiftris.singleton.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(Swiftris.singleton.nextShape!) {
                self.nextShape()
            }
        } else {
            self.nextShape()
        }
    }
    
    func gameDidEnd(notification: NSNotification) {
        view.userInteractionEnabled = false
        
        ShapeFactory.singleton.colapseShapes()
        
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        scene.animateCollapsingLines(Swiftris.singleton.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            Swiftris.singleton.beginGame()
        }
        ShapeFactory.singleton.freeShapes()
    }
    
    func gameDidLevelUp(notification: NSNotification) {
        levelLabel.text = "\(Swiftris.singleton.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
        ShapeFactory.singleton.freeShapes()
    }
    
    func gameShapeDidDrop(notification: NSNotification) {
        scene.stopTicking()
        scene.redrawShape(Swiftris.singleton.fallingShape!) {
            Swiftris.singleton.letShapeFall()
        }
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(notification: NSNotification) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        let removedLines = Swiftris.singleton.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(Swiftris.singleton.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                ShapeDidLandNotificationHandler.singleton.post()
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(notification: NSNotification) {
        scene.redrawShape(Swiftris.singleton.fallingShape!) {}
    }
}

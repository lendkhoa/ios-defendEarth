//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 10/30/15.
//  Copyright © 2015 Razeware LLC. All rights reserved.
//

import Foundation
import SpriteKit
 
class GameOverScene: SKScene {
 
  init(size: CGSize, won:Bool) {
 
    super.init(size: size)
 
    let bgTexture = SKTexture(imageNamed: "universe")
    let background = SKSpriteNode(texture: bgTexture)
    background.position = CGPoint(x: self.frame.width, y: self.frame.height)
    background.size = CGSize(width: 1720 , height: 880)
    background.zPosition = -1
    self.addChild(background)
 
    // 2
    let message = won ? "You Save our world Captain!" : "Earth has fallen!"
 
    // 3
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.whiteColor()
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
 
    // 4
    runAction(SKAction.sequence([
      SKAction.waitForDuration(3.0),
      SKAction.runBlock() {
        // 5
        _ = SKTransition.flipHorizontalWithDuration(0.5)
        let scene = GameScene(size: size)
        //self.view?.presentScene(scene, transition:reveal)
        self.view?.presentScene(scene)
      }
    ]))
 
  }
 
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
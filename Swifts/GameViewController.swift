//
//  GameViewController.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 10/30/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import SpriteKit
 
class GameViewController: UIViewController {
 
  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .ResizeFill
    skView.showsPhysics = false
    skView.presentScene(scene)
  }
 
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

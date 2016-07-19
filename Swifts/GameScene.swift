//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 10/30/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct PhysicsCategory
{
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Asteroid   : UInt32 = 0b1
  static let Missile: UInt32 = 0b10
  static let Spaceship: UInt32 = 0x1<<2
  static let Sun : UInt32 = 0x1<<3
    
}

func + (left: CGPoint, right: CGPoint) -> CGPoint
{
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
 
func - (left: CGPoint, right: CGPoint) -> CGPoint
{
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
 
func * (point: CGPoint, scalar: CGFloat) -> CGPoint
{
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
 
func / (point: CGPoint, scalar: CGFloat) -> CGPoint
{
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
 
#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif
 
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
 
  func normalized() -> CGPoint {
    return self / length()
  }
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    let shipTexture = SKTexture(imageNamed: "spaceship")
    
    var ship = SKSpriteNode()
    
    var asteroidDestroyed = 0
    
    var score = 0
    
    var scoreLabel = SKLabelNode()
    
    var sun = SKSpriteNode()
    
    var sunGravityLabel = SKLabelNode()
    
    var sunLight = SKLightNode()
  
  override func didMoveToView(view: SKView)
  {
    // background
    let bgTexture = SKTexture(imageNamed: "universe")
    let background = SKSpriteNode(texture: bgTexture)
    background.size = self.frame.size
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    background.zPosition = -1
    self.addChild(background)
    
    ship = SKSpriteNode(texture: shipTexture)
    ship.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    ship.size = CGSize(width: 125, height: 100)
    //ship.physicsBody? = SKPhysicsBody(texture: ship.texture!, size: CGSize(width: 155, height: 110))
    ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width/3)

    ship.physicsBody?.dynamic = false
    ship.physicsBody?.categoryBitMask = PhysicsCategory.Spaceship
    ship.physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid
    ship.physicsBody?.collisionBitMask = PhysicsCategory.None
    ship.physicsBody?.usesPreciseCollisionDetection = true
    self.addChild(ship)
    shipUpDown(ship)
    
    //setup score label
    scoreLabel.fontName = "HChalkduster"
    scoreLabel.fontSize = 60
    scoreLabel.text = "0"
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
    self.addChild(scoreLabel)
    
    //set up the sun
    let suntexture =  SKTexture(imageNamed: "suncore")
    let sun = SKSpriteNode(texture: suntexture)
    sun.position = CGPoint(x: size.width/2, y: size.height/2)
    sun.size = CGSizeMake(3, 3)  //CGSize(width: 30, height: 30)
    sun.position = CGPointMake(self.frame.width-30, self.frame.height-30)
    sun.physicsBody = SKPhysicsBody(texture: sun.texture!, size: CGSize(width: 30,height: 30))
    sun.physicsBody?.dynamic = true
    sun.physicsBody?.categoryBitMask = PhysicsCategory.Sun
    sun.physicsBody?.contactTestBitMask = PhysicsCategory.Missile | PhysicsCategory.Asteroid
    sun.physicsBody?.collisionBitMask = 0
    sun.physicsBody?.usesPreciseCollisionDetection = true
    sun.physicsBody?.linearDamping = 1
    sun.physicsBody?.angularDamping = 1
    sun.physicsBody?.angularVelocity = 0.7
    
    sunLight.ambientColor = UIColor.cyanColor()
    sunLight.position = sun.position
    sunLight.falloff = 1
    sunLight.lightColor = UIColor.orangeColor()
    self.addChild(sun)
    self.addChild(sunLight)
    
    //sun gravity field
    let gravityField = SKFieldNode.radialGravityField()
    gravityField.enabled = true;
    gravityField.position = CGPoint(x: self.frame.width-30, y: self.frame.height-30)
    gravityField.strength = 1.0
    self.addChild(gravityField)
    
    
    physicsWorld.gravity = CGVectorMake(0, 0)
    physicsWorld.contactDelegate = self
    
    runAction(SKAction.repeatActionForever(
      SKAction.sequence([
        SKAction.runBlock(spawnAsteroid),
        SKAction.waitForDuration(5.0)
      ])
    ))
    
    //preload sound
    do {
        let sounds = ["launch","explosionSound"]
        for sound in sounds {
            let player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "wav")!))
            player.prepareToPlay()
        }
    } catch {
        
    }
}
    
    func shipUpDown (myship: SKSpriteNode) {
        let up =  SKAction.moveToY(350, duration: 3)
        let down = SKAction.moveToY(10, duration: 3)
        let sequence = SKAction.sequence([up, down])
        myship.runAction(SKAction.repeatActionForever(sequence))
    }
    
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
   
  func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  func spawnAsteroid() {
   
    // Create sprite
    let rockTexture = SKTexture(imageNamed: "asteroid1")
    let asteroid = SKSpriteNode(texture: rockTexture)
    asteroid.name = "asteroid"
    asteroid.size = CGSize(width: 150, height: 115)
   
    asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: CGSize(width: 130, height: 100))
    asteroid.physicsBody?.dynamic = true
    asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
    asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Missile | PhysicsCategory.Spaceship
    asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
   
    // Determine where to spawn the asteroid along the Y axis
    let actualY = random(min: asteroid.size.height/2, max: size.height - asteroid.size.height/2)
   
    // Position the asteroid slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    asteroid.position = CGPoint(x: size.width + asteroid.size.width/2, y: actualY)
    
    //add rotation
    let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
    asteroid.runAction(SKAction.repeatActionForever(action))
    addChild(asteroid)
   
    // Determine speed of the asteroid
    let actualDuration = random(min: CGFloat(3.0), max: CGFloat(4.0))
   
    // Create the actions
    let actionMove = SKAction.moveTo(CGPoint(x: -asteroid.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let loseAction = SKAction.runBlock() {
    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
    let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
   asteroid.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
   
  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

    // Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.locationInNode(self)
   
    // Set up initial location of projectile
    let rockTexture = SKTexture(imageNamed: "missile")
    let missile = SKSpriteNode(texture: rockTexture)
    missile.size = CGSize(width: 75, height: 35)
    missile.position = ship.position
   
    //projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    missile.physicsBody = SKPhysicsBody(texture: missile.texture!, size: CGSize(width: 75, height:25))
    missile.physicsBody?.dynamic = true
    missile.physicsBody?.categoryBitMask = PhysicsCategory.Missile
    missile.physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid
    missile.physicsBody?.collisionBitMask = PhysicsCategory.None
    missile.physicsBody?.usesPreciseCollisionDetection = true
   
    // Determine offset of location to projectile
    let offset = touchLocation - missile.position
   
    // Bail out if you are shooting down or backwards
    if (offset.x < 0) { return }
   
    // OK to add now - you've double checked position
    addChild(missile)
   
    // Get the direction of where to shoot
    let direction = offset.normalized()
   
    // Make it shoot far enough to be guaranteed off screen
    let shootAmount = direction * 1000
   
    // Add the shoot amount to the current position
    let realDest = shootAmount + missile.position
    
    //flying frame of missile, smaller means faster
    var missileSpeed = 4.0
   
    // Create the shooting actions
    let actionMove = SKAction.moveTo(realDest, duration: missileSpeed)
    let actionMoveDone = SKAction.removeFromParent()
    missile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    self.runAction(SKAction.playSoundFileNamed("launch.wav", waitForCompletion: true))
    
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
  
  func didBeginContact(contact: SKPhysicsContact)
  {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
    {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else
    {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
        
    if ((contact.bodyA.node?.name == "asteroid") || (contact.bodyB.node?.name == "asteroid")) {
        contact.bodyA.node?.removeFromParent()
        contact.bodyB.node?.removeFromParent()
        addSoundLight(contact)
        score += 1
    }
        
    scoreLabel.text = String(score)
    
    if (secondBody.categoryBitMask & PhysicsCategory.Spaceship != 0) && (firstBody.categoryBitMask & PhysicsCategory.Asteroid != 0)
    {
        addSoundLight(contact)
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    if ((secondBody.categoryBitMask & PhysicsCategory.Sun != 0) && (firstBody.categoryBitMask & PhysicsCategory.Missile != 0) || (secondBody.categoryBitMask & PhysicsCategory.Sun != 0) && (firstBody.categoryBitMask & PhysicsCategory.Asteroid != 0))
    {
        print("hit sun")
        firstBody.node?.removeFromParent()
        addSoundLight(contact)
    }
        
  }
    
    func addSoundLight(contact: SKPhysicsContact) {
        let spark:SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
        let orange = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        spark.particleColor = orange
        spark.position = (contact.contactPoint)
        self.runAction(SKAction.playSoundFileNamed("explosionSound", waitForCompletion: true))
        self.addChild(spark)
    }
  
}

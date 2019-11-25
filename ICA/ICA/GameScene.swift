//
//  GameScene.swift
//  ICA
//
//  Created by TAYLOR, NATHAN on 25/11/2019.
//  Copyright © 2019 TAYLOR, NATHAN. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory //sets a struct of constants for all of the physics catagories
{
    static let none : UInt32 = 0
    static let all  : UInt32 = UInt32.max
    static let monster    : UInt32 = 0b1
    static let projectile : UInt32 = 0b10
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
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



class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player = SKSpriteNode(imageNamed: "PforPlayer")
    
    override func didMove(to view: SKView) {
        
        //Adding the background
        backgroundColor = SKColor.white
        //Adding the player position
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(createMonster), SKAction.wait(forDuration: 1.0)])))
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))

        }
    }

    
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 4294967296)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    func createMonster()
    {
        let monster = SKSpriteNode(imageNamed: "EforEnemy") //Enemy sprite
        let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2) //Spawning location
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY) //Spawns slightly off screen to start and along random Y coords
        addChild(monster)
        //monster physics collision
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none

        let durationTime = random(min: 4, max: 8) //Sets the speed of the monster
        //Creating the actions
        let actionsMoved = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: actualY), duration: TimeInterval(durationTime))
        let actionsMovedFinished = SKAction.removeFromParent()
        monster.run(SKAction.sequence([actionsMoved, actionsMovedFinished]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) //After touch has ended
    {
        guard let touch = touches.first else
        {
            return
        }
        let touchLocation = touch.location(in: self) //setting initial location for projectiles
        let projectile = SKSpriteNode(imageNamed: "PforProjectile") //projectile sprite
        projectile.position = player.position //setting the projectile position at the players position
        
        //projectile physics collision
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        let offset = touchLocation - projectile.position
        if offset.x < 0 //ends if the shooting is less than the 0 coord
        {
            return
        }
        addChild(projectile)
        let direction = offset.normalized() //gets the direction where to shoot
        let shootAmount = direction * 1200 //ensures it shoots further than the screen
        let realdestination = shootAmount + projectile.position //adds the shoot amount to the current position
        //Creating the actions
        let actionMove = SKAction.move(to: realdestination, duration: 2.0)
        let actionMoveFinished = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveFinished]))
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster:SKSpriteNode)
    {
        print ("Test to see if the projectile actually hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    
}
 
extension GameScene: SKPhysicsContactDelegate
{
    func didBegin(_ contact: SKPhysicsContact) {
      // 1
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
     
      // 2
      if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
        if let monster = firstBody.node as? SKSpriteNode,
          let projectile = secondBody.node as? SKSpriteNode {
          projectileDidCollideWithMonster(projectile: projectile, monster: monster)
        }
      }
    }

}

// add swipe
// add shake
// add point
// add soundtrack
// add soundeffect
// add win or lose screen


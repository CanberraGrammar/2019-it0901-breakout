//
//  GameScene.swift
//  Pong-IT0901
//
//  Created by MPP on 9/9/19.
//  Copyright © 2019 Matthew Purcell. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory: UInt32 = 0x1 << 0
    let BrickCategory: UInt32 = 0x1 << 1
    let BottomCategory: UInt32 = 0x1 << 2
        
    var bottomPaddle: SKSpriteNode?
    var fingerOnBottomPaddle: Bool = false
    var bottomScoreLabel: SKLabelNode?
    
    var ball: SKSpriteNode?
    
    var gameRunning = false
    
    var bottomScore = 0
        
    override func didMove(to view: SKView) {
        
        bottomPaddle = childNode(withName: "bottomPaddle") as? SKSpriteNode
        bottomPaddle!.physicsBody = SKPhysicsBody(rectangleOf: bottomPaddle!.frame.size)
        bottomPaddle!.physicsBody!.isDynamic = false
        
        bottomScoreLabel = childNode(withName: "bottomScoreLabel") as? SKLabelNode
        
        ball = childNode(withName: "ball") as? SKSpriteNode
        ball!.physicsBody = SKPhysicsBody(rectangleOf: ball!.frame.size)
        ball!.physicsBody!.restitution = 1
        ball!.physicsBody!.friction = 0
        ball!.physicsBody!.linearDamping = 0
        ball!.physicsBody!.angularDamping = 0
        ball!.physicsBody!.allowsRotation = false
        ball!.physicsBody!.categoryBitMask = BallCategory
        ball!.physicsBody!.contactTestBitMask = BottomCategory | BrickCategory
        
        //let smokeEmitterNode = SKEmitterNode(fileNamed: "SmokeEmitter")
        //smokeEmitterNode!.targetNode = self
        //ball!.addChild(smokeEmitterNode!)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        let bottomNode = SKNode()
        let bottomLeftPoint = CGPoint(x: -(self.size.width / 2), y: -(self.size.height / 2))
        let bottomRightPoint = CGPoint(x: self.size.width / 2, y: -(self.size.height / 2))
        bottomNode.physicsBody = SKPhysicsBody(edgeFrom: bottomLeftPoint, to: bottomRightPoint)
        bottomNode.physicsBody!.categoryBitMask = BottomCategory
        self.addChild(bottomNode)
        
        let numberOfBricks = 6
        let brickWidth = self.size.width / CGFloat(numberOfBricks)
        
        for i in 0..<numberOfBricks {
            
            let xCoordinate = (CGFloat(i) * brickWidth) - (self.size.width / 2) + (brickWidth / 2)
            
            let brickNode = SKSpriteNode(color: (i % 2 == 0 ? .blue : .red), size: CGSize(width: brickWidth, height: 25))
            brickNode.position = CGPoint(x: xCoordinate, y: (self.size.height / 2) - 100)
            
            brickNode.physicsBody = SKPhysicsBody(rectangleOf: brickNode.size)
            brickNode.physicsBody!.isDynamic = false
            brickNode.physicsBody!.categoryBitMask = BrickCategory
            brickNode.name = "brick"
            
            self.addChild(brickNode)
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch  = touches.first!
        let touchLocation = touch.location(in: self)
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode == bottomPaddle {
            fingerOnBottomPaddle = true
        }
                
        if gameRunning == false {
            
            // Generate a random number between 0 and 1 (inclusive)
            let randomNumber = arc4random_uniform(2)
            
            if randomNumber == 0 {
            
                ball!.physicsBody!.applyImpulse(CGVector(dx: 8.0, dy: 8.0))
                
            }
            
            else {
                
                ball!.physicsBody!.applyImpulse(CGVector(dx: -8.0, dy: -8.0))
                
            }

            gameRunning = true
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch  = touches.first!
        let touchLocation = touch.location(in: self)
        let previousTouchLocation = touch.previousLocation(in: self)
        
        let distanceMoved = touchLocation.x - previousTouchLocation.x
        
        if touchLocation.y < 0 && fingerOnBottomPaddle {
            
            let paddleX = bottomPaddle!.position.x + distanceMoved
            
            if (paddleX + bottomPaddle!.size.width / 2) < (self.size.width / 2) && (paddleX - bottomPaddle!.size.width / 2) > -(self.size.width / 2) {
                
                bottomPaddle!.position.x = bottomPaddle!.position.x + distanceMoved
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if fingerOnBottomPaddle {
            fingerOnBottomPaddle = false
        }
        
    }
    
    func resetGame() {
        
        // Put the ball back in the centre of the screen
        ball!.position.x = 0
        ball!.position.y = 0
        
        // Reset the position of the paddle
        bottomPaddle!.position.x = 0
        
        // Stop the ball from moving
        ball!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        gameRunning = false
        
        // Remove all bricks from the scene
        self.enumerateChildNodes(withName: "brick") { (node, finished) in
            node.removeFromParent()
        }
        
        // Unpause the view
        view!.isPaused = false
        
    }
    
    func gameOver() {
        
        // Pause the game
        view!.isPaused = true
        
        // Show an alert saying "Game Over" - you need a UIAlertController
        let gameOverAlert = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        let gameOverAction = UIAlertAction(title: "Okay", style: .default) { (alertAction) in
            
            // Write the code to run when the button is tapped
            self.resetGame()
            
        }
        
        gameOverAlert.addAction(gameOverAction)
        
        view!.window!.rootViewController!.present(gameOverAlert, animated: true, completion: nil)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == BottomCategory) || (contact.bodyB.categoryBitMask == BottomCategory) {
            
            print("Bottom collision")
                        
            gameOver()
            
        }
        
        else if (contact.bodyA.categoryBitMask == BrickCategory) {
            
            contact.bodyA.node!.removeFromParent()
            
        }
        
        else if (contact.bodyB.categoryBitMask == BrickCategory) {
            
            contact.bodyB.node!.removeFromParent()
            
        }
                
    }
    
}

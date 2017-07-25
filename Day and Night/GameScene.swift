
//
//  GameScene.swift
//  Day and Night
//
//  Created by Lisa on 7/24/17.
//  Copyright © 2017 Lisa Ye. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    var score: CFTimeInterval = 0 //score of player
    let scrollSpeed: CGFloat = 90
    
    var egg: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var jumpButton: MSButtonNode!
    var shootButton: MSButtonNode!
    var scrollLayer: SKNode!
    
    var playerOnGround: Bool = true //a variable that checks if player is on the ground
    
    //++++++++++++++++++++++++VARIABLES ABOVE++++++++++++++++++++++++++++++++
    
    override func didMove(to view: SKView) {
        
        egg = childNode(withName: "//egg") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        jumpButton = childNode(withName: "jumpButton") as! MSButtonNode
        shootButton = childNode(withName: "shootButton") as! MSButtonNode
        scrollLayer = childNode(withName: "scrollLayer")
        
       
        
        physicsWorld.contactDelegate = self //set up physics
        
        
        
        jumpButton.selectedHandler = {
            if self.playerOnGround {
                self.egg.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 28))//apply vertical impulse as jumping
                let eggPosition = self.egg.convert(self.egg.position, to: self)
                
                print(eggPosition.y)
                
                self.playerOnGround = false //deactivate this button until contact sets this to true
            }
        }
        
        shootButton.selectedHandler = {
            
            //make a bullet when button is touched
            let eggBullet = Bullet()
            
            //add the bullet to the screen
            self.addChild(eggBullet)
            
            let eggPosition = self.egg.convert(self.egg.position, to: self)
            
            //Move the bullet to in front of the egg
            eggBullet.position.x = eggPosition.x + 15
            eggBullet.position.y = eggPosition.y - 2
            
            //ensure the player's y velocity doesn't affect the bullet's y velocity(so the bullet doesn't go diagonally up when playe jumps)
            if self.playerOnGround == false {
                eggBullet.physicsBody?.velocity.dy = 0
            }
            
            //limit the bullet height
            if eggBullet.position.y > 160 {
                eggBullet.position.y = 160
            }
            
            //impluse vector, how fast the bullet goes
            let launchImpulse = CGVector(dx: 10, dy: 0)
            
            //Apply impulse to penguin
            eggBullet.physicsBody?.applyImpulse(launchImpulse)
            
        }
        
        
        
    }//closing brackets for didMove function
    
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space, ground is child of scrollLayer but not necess a child of scene so gotta convert */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width , y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //when player hits ground
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2 ||
            contact.bodyA.categoryBitMask == 2 && contact.bodyB.categoryBitMask == 1 {
            //contact.bodyB.node?.removeFromParent()  //removes the node that is bodyB
            playerOnGround = true // if egg touches ground, it's on the ground
        }
        
        //when bullet hits enemy
        if contact.bodyA.categoryBitMask == 4 && contact.bodyB.categoryBitMask == 8 || contact.bodyA.categoryBitMask == 8 && contact.bodyB.categoryBitMask == 4 {
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            score += 50
        }
        
    
        
    }//closing brackets for didBegin function
    
    
    override func update(_ currentTime: TimeInterval) {
        
        score += fixedDelta //adds 1 to score every second
        scoreLabel.text = "\(Int(score))" //updates scoreLabel
        
        scrollWorld()
        
        
        
    }//CLOSING BRACKETS FOR UPDATE FUNCTION
    
    
}//Closing brackets for the gamescene class

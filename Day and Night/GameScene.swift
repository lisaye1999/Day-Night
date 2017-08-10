
//  GameScene.swift
//  Day and Night
//
//  Created by Lisa on 7/24/17.
//  Copyright © 2017 Lisa Ye. All rights reserved.


import SpriteKit
import GameplayKit


enum GameState {
    case gameActive, gameOver
}

enum WorldState {
    case day, night
}

public var dayTime = true
public var nightTime = false

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //stored values
    var highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
    var eggshellTotal = UserDefaults.standard.integer(forKey: "EGGSHELL")
    
    //time related variable
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    var score: CFTimeInterval = 0 //score of player
    var spawnTimer: CFTimeInterval = 0
    var obstacleSpawnTimer: CFTimeInterval = 0
    let scrollSpeed: CGFloat = 250
    
    var switchTimer: CFTimeInterval = 0
    var worldTimer: CFTimeInterval = 0
    
    var obstacleTravelSpeed: CGFloat = 250
    var npcTravelSpeed: CGFloat = 280
    var obstacleDensity = 2.0
    var npcDensity = 1.8 //time inbetween a new enemy(lower = more enemy)
    var npcsOnScreen = 2
    var totalNpc: Int = 0
    
    var dayCount: Int = 0 {
        didSet{
            if dayCount % 2 == 0 {
                npcsOnScreen += 1
            }
            if npcsOnScreen > totalNpc {
                npcsOnScreen = totalNpc
            }
        }
    }
    var karmaBar: SKSpriteNode!
    var karmaValue: CGFloat = 1.0 {
        didSet{
            
            if karmaValue > 1.0 {
                karmaValue = 1.0
            }
            else if karmaValue < 0 {
                karmaValue = 0
                karmaBar.xScale = karmaValue
            }
            else {
                karmaBar.xScale = karmaValue * 3
            }
            
        }
    }
    
    var egg: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var dayCountLabel: SKLabelNode!
    var restartButton: MSButtonNode!
    var scrollLayer: SKNode!
    var scrollLayerNight: SKNode!
    
    //booleans for game management
    var playerOnGround: Bool = true //a variable that checks if player is on the ground
    var bulletHitEnemy = false
    var bulletHitFriend = false
    var playerTouchFriend = false
    var npcjump = false
    
    var npcsArray: SKNode!
    var npcScrollLayer: SKNode!
    var obstacleScrollLayer: SKNode!
    var obstacleArray: SKNode!
    var obstacleSource: SKNode!
    
    //npc Sources
    var watermelonSource: SKSpriteNode!
    var bunnySource: SKSpriteNode!
    var coneSource: SKSpriteNode!
    var fishSource: SKSpriteNode!
    
    var npcList: [SKSpriteNode]!
    
    //graphics nodes
    var cloudScrollLayer: SKNode!
    var backgroundLayer: SKNode!
    var heartSource: SKSpriteNode!
    var heartbreakSource: SKSpriteNode!
    
    //states
    var gameState: GameState = .gameActive
    var worldState: WorldState = .day {
        didSet {
            for npc in npcScrollLayer.children as! [SKSpriteNode] {
                if npc.physicsBody?.categoryBitMask == 8 {
                    npc.physicsBody?.categoryBitMask = 16
                }
                else if npc.physicsBody?.categoryBitMask == 16 {
                    npc.physicsBody?.categoryBitMask = 8
                }
            }
            for childReference in npcsArray.children {
                for childSKNode in childReference.children {
                    for child in childSKNode.children {
                        if child.physicsBody?.categoryBitMask == 8 {
                            child.physicsBody?.categoryBitMask = 16
                        }
                        else if child.physicsBody?.categoryBitMask == 16 {
                            child.physicsBody?.categoryBitMask = 8
                        }
                    }
                }
            }
        }
    }
    
    //actions
    let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.1)
    let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.7)
    
    //temp
    var highScoreLabel: SKLabelNode!

   
    //++++++++++++++++++++++++VARIABLES ABOVE++++++++++++++++++++++++++++++++
    
    override func didMove(to view: SKView) {
        
        egg = self.childNode(withName: "//egg") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        dayCountLabel = childNode(withName: "dayCountLabel") as! SKLabelNode
        
        restartButton = childNode(withName: "restartButton") as! MSButtonNode
        scrollLayer = childNode(withName: "scrollLayer")
        scrollLayerNight = childNode(withName: "scrollLayerNight")
        npcsArray = childNode(withName: "npcsArray")
        npcScrollLayer = childNode(withName: "npcScrollLayer")
        obstacleScrollLayer = childNode(withName: "obstacleScrollLayer")
        obstacleArray = childNode(withName: "obstacleArray")
        obstacleSource = childNode(withName: "obstacle")
        cloudScrollLayer = childNode(withName: "cloudScrollLayer")
        backgroundLayer = childNode(withName: "backgroundLayer")
        heartSource = childNode(withName: "heartSource") as! SKSpriteNode
        heartbreakSource = childNode(withName: "heartbreakSource") as! SKSpriteNode
        
        highScoreLabel = childNode(withName: "highScore") as! SKLabelNode
        highScoreLabel.alpha = 0
        
        karmaBar = childNode(withName: "karmaBar") as! SKSpriteNode
        
        //npc Souce Connection
        watermelonSource = childNode(withName: "//watermelon") as! SKSpriteNode
        bunnySource = childNode(withName: "//bunny") as! SKSpriteNode
        coneSource = childNode(withName: "//cone") as! SKSpriteNode
        fishSource = childNode(withName: "//fish") as! SKSpriteNode
        
        npcList = [watermelonSource, bunnySource, coneSource, fishSource]
        totalNpc = npcList.count
        
        physicsWorld.contactDelegate = self //set up physics
        
    //////Button Related Code below
        
        /* Hide restart button */
        restartButton.state = .MSButtonNodeStateHidden
        
        restartButton.selectedHandler = { [unowned self] in
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
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
            if groundPosition.x <= (-ground.size.width + 5)  {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width * 2)  , y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
    }

    func scrollBackground() {
        
        if worldState != .day {return}
        cloudScrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for cloud in cloudScrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space, ground is child of scrollLayer but not necess a child of scene so gotta convert */
            let cloudPosition = cloudScrollLayer.convert(cloud.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if cloudPosition.x <= (-cloud.size.width + 5)  {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width * 5)  , y: cloudPosition.y)
                
                /* Convert new node position back to scroll layer space */
                cloud.position = self.convert(newPosition, to: cloudScrollLayer)
            }
        }
    }
    
    
    func spawnNpc() {
        
        //scroll npcLayer so it moves across
        npcScrollLayer.position.x -= npcTravelSpeed * CGFloat(fixedDelta)
        npcScrollLayer.position.y = 0
        
//        for childReference in npcsArray.children {
//            for childSKNode in childReference.children {
//                for child in childSKNode.children {
//                    npcList.append(child as! SKSpriteNode)
//                }
//            }
//        }

        /* Loop through obstacle layer nodes*/
        for npc in npcScrollLayer.children {
            
            /* Get obstacle node postion, convert node position to scene space */
            let npcPosition = npcScrollLayer.convert(npc.position, to: self)
            
            /* Check if obstacle has left the scene */
            if npcPosition.x <= -40 {
                
                /* Remove obstacle node from obstacle layer */
                npc.removeFromParent()
            }
        }
        
        if spawnTimer >= npcDensity {
            
            //change max number to npcList.count for ALL sprites at once, change it to npcOnScreen for incremental increase of sprites
            let randomNpcIndex = randomInteger(min: 0, max: npcsOnScreen)
            
            let newEnemy = npcList[randomNpcIndex].copy() as! SKSpriteNode //newEnemy is the first child
            
            npcScrollLayer.addChild(newEnemy) //adds new enemy
            
            //            let eggPosition = self.egg.convert(self.egg.position, to: self)
            let randomPosition = CGPoint(x: 800 , y: 80)
            
            newEnemy.position = self.convert(randomPosition, to: npcScrollLayer)
            
            
            // Reset spawn timer
            spawnTimer = 0
            
        }
    }
    
    func spawnObstacle() {
        
        obstacleScrollLayer.position.x -= obstacleTravelSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes*/
        for obstacle in obstacleScrollLayer.children  {
            
            /* Get obstacle node postion, convert node position to scene space */
            let obstaclePosition = obstacleScrollLayer.convert(obstacle.position, to: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= -30 {
                // 26 is one half the width of an obstacle
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
                
            }
            
            
        }
        
        var obstacleList = [SKNode]()
        
        for obstacle in obstacleArray.children {
            obstacleList.append(obstacle)
        }
        
        if obstacleSpawnTimer > obstacleDensity {
            
            let randomObstacleIndex = randomInteger(min: 0, max: obstacleList.count)
            
            /* Create a new obstacle by copying the source obstacle*/
            
            let newObstacle = obstacleList[randomObstacleIndex].copy() as! SKNode
            
            let obstaclePosition = obstacleScrollLayer.convert(newObstacle.position, to: self)
            
            obstacleScrollLayer.addChild(newObstacle)
            
            /* Generate new obstacle position, start just outside screen and with a random y value*/
            let randomPosition = CGPoint(x: 750, y: obstaclePosition.y)
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convert(randomPosition, to: obstacleScrollLayer)
            
            // Reset spawn timer
            obstacleSpawnTimer = 0
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //only need one single touch here
        let touch = touches.first!
        
        //get touch position in scene
        let location = touch.location(in: self)
        
        //figure out which side of the screen was touched
        if location.x > size.width / 2 {
            
            // right(jumping)
            
            if self.gameState != .gameActive {return}
            
            if self.playerOnGround {
                self.egg.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 23))//apply vertical impulse as jumping
                
                
                self.npcjump = true
                self.playerOnGround = false //deactivate this button until contact sets this to true
            }
        }
        else {
            //left(shooting)
            
            if self.gameState != .gameActive {return}
            
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
            
            print("day" + "\(dayTime)")
            print("night" + "\(nightTime)")
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //changing between friend and enemy by changing category bit mask
        
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        
        //when player hits ground
        if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2 ||
            contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1 {
            //contact.bodyB.node?.removeFromParent()  //removes the node that is bodyB
            playerOnGround = true // if egg touches ground, it's on the ground
        }
        
        
        //when player touches enemy
        if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 8 || contactA.categoryBitMask == 8 && contactB.categoryBitMask == 1 {
            
            if gameState != .gameActive { return }
            
            gameOver()
        }
        
        
        //when bullet hits enemy
        if contactA.categoryBitMask == 4 && contactB.categoryBitMask == 8 || contactA.categoryBitMask == 8 && contactB.categoryBitMask == 4 {
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            bulletHitEnemy = true
        }
        
        //when player hits an obstacle
        if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 32 || contactA.categoryBitMask == 32 && contactB.categoryBitMask == 1 {
            
            if gameState != .gameActive { return }
            
            gameOver()
        }
        
        //when bullet hits an obstacle
        if contactA.categoryBitMask == 4 && contactB.categoryBitMask == 32 {
            
            contactA.node?.removeFromParent()
            contactB.node?.physicsBody?.velocity.dx = 0
        }
        else if contactA.categoryBitMask == 32 && contactB.categoryBitMask == 4 {
            contactB.node?.removeFromParent()
            contactA.node?.physicsBody?.velocity.dx = 0
        }
        
        //when enemy bumps into obstacle
        if contactA.categoryBitMask == 8 && contactB.categoryBitMask == 32 {
            
            contactB.node?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            contactA.node?.physicsBody?.velocity.dx = 15
        }
        else if contactA.categoryBitMask == 32 && contactB.categoryBitMask == 8 {
            
            contactA.node?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            contactB.node?.physicsBody?.velocity.dx = 15
            
        }
        
        //when bullet hits friend
        if contactA.categoryBitMask == 4 && contactB.categoryBitMask == 16 || contactA.categoryBitMask == 16 && contactB.categoryBitMask == 4 {
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            bulletHitFriend = true
        }
        
        //when player contacts enemy
        if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 16 {
            
            contact.bodyB.node?.removeFromParent()
            playerTouchFriend = true
        }
        else if contactA.categoryBitMask == 16 && contactB.categoryBitMask == 1 {
            
            contact.bodyA.node?.removeFromParent()
            playerTouchFriend = true
            
        }
        
    }//closing brackets for didBegin function
    
    
    func gameOver() {
        
        /* Change game state to game over */
        gameState = .gameOver
        
        if gameState != .gameOver {return}
        
        if Int(score) > highScore {
            saveHighScore()
        }
        
        addEggshell()
        
        /* Show restart button */
        restartButton.state = .MSButtonNodeStateActive
        
        
        //loops through EVERYTHING in the scene
//        enumerateChildNodes(withName: "//*", using:
//            { (node, stop) -> Void in
//                if let spriteNode = node as? SKSpriteNode {
//                    spriteNode.removeAllActions()
//                    spriteNode.physicsBody?.velocity.dx = 0
//                }
//        })
        
        for npc in npcScrollLayer.children as! [SKSpriteNode] {
            if let spriteNode = npc as? SKSpriteNode {
                spriteNode.removeAllActions()
                spriteNode.physicsBody?.velocity.dx = 0
            }
        }
        
        egg.run(SKAction(named: "eggDeath", duration: 0.2)!) {
           self.egg.removeAllActions()
        }
        
        highScoreLabel.alpha = 1
        
    }
    
    func switchWorld() {
        
        let randomTime = randomInteger(min: 15, max: 25)
        
        if switchTimer >= CFTimeInterval(randomTime) {
            
            //worldState changes after animation is completed
            let backgroundSwitch = SKAction(named: "backgroundSwitch")!
            backgroundLayer.run(backgroundSwitch){
                
                if self.worldState == .day {
                    self.worldState = .night
                    //darken the ground
                    for ground in self.scrollLayer.children {
                        ground.run(SKAction.colorize(with: UIColor.black, colorBlendFactor: 0.5, duration: 0.3))
                    }
                    self.cloudScrollLayer.run(self.fadeOut)
                }
                else {
                    self.worldState = .day
                    //change ground color to normal
                    for ground in self.scrollLayer.children {
                        ground.run(SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0.1))
                    }
                    self.cloudScrollLayer.run(self.fadeIn)
                    self.dayCount += 1
                    self.dayCountLabel.text = String(self.dayCount)
                }
            }
            switchTimer = 0
        }
    }
    
    func updateNpcOnScreen() {
        for multiples in 1...(totalNpc - 2) {
            //adds a new npc at multiples of 50
            if Int(score) > 50 * multiples && Int(score) < (50 * multiples) + 10 {
                npcsOnScreen = 2 + multiples
            }
        }

        if npcsOnScreen > totalNpc {
            npcsOnScreen = totalNpc
        }
    }
    
    func spawnHeart() {
        let newHeart = heartSource.copy() as! SKSpriteNode
        self.addChild(newHeart)
        let eggPosition = self.egg.convert(self.egg.position, to: self)
        newHeart.position.x = eggPosition.x
        newHeart.position.y = eggPosition.y + 25
        newHeart.run(SKAction(named: "spawnHeart", duration: 0.3)!) {
            newHeart.removeFromParent()
        }
    }
    
    func spawnHeartBreak() {
        let newHeartbreak = heartbreakSource.copy() as! SKSpriteNode
        self.addChild(newHeartbreak)
        let eggPosition = self.egg.convert(self.egg.position, to: self)
        newHeartbreak.position.x = eggPosition.x
        newHeartbreak.position.y = eggPosition.y + 25
        newHeartbreak.run(SKAction(named: "spawnHeartBreak", duration: 0.3)!) {
            newHeartbreak.removeFromParent()
        }
    }
    
    func saveHighScore() {
        UserDefaults().set(score, forKey: "HIGHSCORE")
    }
    
    func addEggshell() {
//        eggshellTotal += eggshell
//        UserDefaults().set(eggshellTotal, forKey: "EGGSHELL")
    }
    
/////////////////////////UPDATE FUNCTION BELOW//////////////////////////////////
    
    override func update(_ currentTime: TimeInterval) {
        
        
        highScoreLabel.text = "\(UserDefaults().integer(forKey: "HIGHSCORE"))"
        
        if gameState != .gameActive { return }
        
        score += fixedDelta //adds 1 to score every second
        scoreLabel.text = "\(Int(score))" //updates scoreLabel
        spawnTimer += fixedDelta
        obstacleSpawnTimer += fixedDelta
        switchTimer += fixedDelta
        worldTimer += fixedDelta
        
        scrollWorld()
        scrollBackground()
        spawnNpc()
        spawnObstacle()
        switchWorld()
        //updateNpcOnScreen() //turns on incremental increase of npcs according to score
        
        //reward 5 points for each enemy shot, boolean exist to work around multiple contacts
        if bulletHitEnemy {
            score += 5
            bulletHitEnemy = false
        }
        
        //decrease karmaValue when you shoot a friend, boolean exists to work around multiple contacts
        if bulletHitFriend {
            karmaValue -= 0.3
            karmaBar.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.18)) {
                self.karmaBar.run(SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0.1))
            }
            spawnHeartBreak()
            bulletHitFriend = false
        }
        
        //player games karmaValue when contact a friend, boolean exist to work around multiple contacts
        if playerTouchFriend {
            karmaValue += 0.05
            karmaBar.run(SKAction.colorize(with: UIColor.green, colorBlendFactor: 1, duration: 0.18)) {
                self.karmaBar.run(SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0.1))
            }
            spawnHeart()
            playerTouchFriend = false
        }
        
        //ends game if karmaValue is 0
        if karmaValue == 0 {
            gameOver()
        }
        
        //makes npc jumps at a random height if player jumps
        if npcjump {
            let randomJumpHeight = randomInteger(min: 6, max: 18)
            for npc in self.npcScrollLayer.children {
                npc.physicsBody?.applyImpulse(CGVector(dx: 0, dy: randomJumpHeight))
            }
            npcjump = false
        }
        
        //limit bullet range
        enumerateChildNodes(withName: "bullet*", using:
            { (node, stop) -> Void in
                if let bullet = node as? SKSpriteNode {
                    let bulletPosition = bullet.convert(bullet.position, to: self)
                    if bulletPosition.x > 800{
                        bullet.removeFromParent()
                    }
                }
        })
        
        
        //limits character's jump height
        if egg.position.y > 117 {
            egg.position.y = 115
        }
        
    }//CLOSING BRACKETS FOR UPDATE FUNCTION
    
    
}//Closing brackets for the gamescene class

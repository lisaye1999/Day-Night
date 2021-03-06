//
//  MainMenu.swift
//  Day and Night
//
//  Created by Lisa on 8/14/17.
//  Copyright © 2017 Lisa Ye. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

var musicShouldPlay = true

//name: Wawati TC

class MainMenu: SKScene, GKGameCenterControllerDelegate {
    
    //UI Connection
    var startButton: MSButtonNode!
    var highScoreButton: MSButtonNode!
    var tutorialButton: MSButtonNode!
    var musicButton: MSButtonNode!
    
    var showCredits: MSButtonNode!
    var creditsScreen: SKSpriteNode!
    var closeButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        //set up scene here
        
        //UI connection
        startButton = self.childNode(withName: "startButton") as! MSButtonNode
        tutorialButton = self.childNode(withName: "tutorialButton") as! MSButtonNode
        highScoreButton = self.childNode(withName: "highScoreButton") as! MSButtonNode
        closeButton = childNode(withName: "closeButton") as! MSButtonNode
        musicButton = childNode(withName: "musicButton") as! MSButtonNode
        
        let backgroundSound = SKAudioNode(fileNamed: "Little Boy Music Box")
        
        if musicShouldPlay {
        self.addChild(backgroundSound)
        musicButton.texture = SKTexture(imageNamed: "music icon")
        }
        
        if musicShouldPlay == false {
            musicButton.texture = SKTexture(imageNamed: "no music icon")
        }
        
        showCredits = childNode(withName: "showCredits") as! MSButtonNode
        creditsScreen = childNode(withName: "creditsScreen") as! SKSpriteNode
        creditsScreen.alpha = 0
        closeButton.alpha = 0
        
       let buttonClickSound = SKAction.playSoundFileNamed("button", waitForCompletion: false)
        
        //Allow the button to run when tapped
        
        showCredits.selectedHandler = { [unowned self] in
            self.run(buttonClickSound)
            self.run(SKAction.wait(forDuration: 0.1)) {
                self.creditsScreen.alpha = 1
                self.closeButton.alpha = 1
              
        }
        }
        
        closeButton.selectedHandler = { [unowned self] in

            self.run(buttonClickSound)
            self.run(SKAction.wait(forDuration: 0.1)) {
            self.closeButton.alpha = 0
            self.creditsScreen.alpha = 0
            }
        }
        
        startButton.selectedHandler = { [unowned self] in
            self.run(buttonClickSound)
            self.run(SKAction.wait(forDuration: 0.1)) {
            self.loadGame()
            }
            
        }
        
        tutorialButton.selectedHandler = { [unowned self] in
            self.run(buttonClickSound)
            self.run(SKAction.wait(forDuration: 0.1)) {
            self.startTutorial()
            }
        }
        
        musicButton.selectedHandler = { [unowned self] in
            
            if musicShouldPlay {
            self.run(buttonClickSound)
            self.run(SKAction.wait(forDuration: 0.1)) {
            backgroundSound.removeFromParent()
            self.musicButton.texture = SKTexture(imageNamed: "no music icon")
            musicShouldPlay = false
            }
            }
            
            if musicShouldPlay == false { 
                self.run(buttonClickSound)
                self.run(SKAction.wait(forDuration: 0.1)) {
                self.addChild(backgroundSound)
                self.musicButton.texture = SKTexture(imageNamed: "music icon")
                musicShouldPlay = true
                }
            }
            
        }
        
        highScoreButton.selectedHandler = { [unowned self] in
            self.run(buttonClickSound)
            self.run(SKAction.wait(forDuration: 0.1)) {
             self.showLeader()
            }
        }
    
        
    }
  
    
    func loadGame() {
        
        // 1) Grab reference to our SpriteKit view
        guard let skView = self.view as SKView! else {
            print("Could not get SKview")
            return
        }
        
        // 2) Load Game scene
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        // 3) Ensure correct aspect mode
        scene.scaleMode = .aspectFit
        
        //Show debug
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        // 4) Start game scene
        skView.presentScene(scene)
        
    }
    
    func startTutorial() {
        // 1) Grab reference to our SpriteKit view
        guard let skView = self.view as SKView! else {
            print("Could not get SKview")
            return
        }
        
        // 2) Load Game scene
        guard let scene = Tutorial(fileNamed:"Tutorial") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        // 3) Ensure correct aspect mode
        scene.scaleMode = .aspectFit
        
        //Show debug
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        // 4) Start game scene
        skView.presentScene(scene)
        
    }
    
    //shows leaderboard screen
    func showLeader() {
        let viewControllerVar = self.view?.window?.rootViewController
        let gKGCViewController = GKGameCenterViewController()
        gKGCViewController.gameCenterDelegate = self
        viewControllerVar?.present(gKGCViewController, animated: true, completion: nil)
    }
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    
}//CLOSING BRACKETS FOR THE CLASS DON'T TOUCH



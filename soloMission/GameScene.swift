//
//  GameScene.swift
//  soloMission
//
//  Created by Joshua Hudson on 11/30/16.
//  Copyright © 2016 com.ParanoidPenguinProductions. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    //Set up sound effect
    //let bulletSound = SKAction.playSoundFileNamed("bulletSound.wav, waitForCompletion: false)
    //let explosionSound = SKAction.playSoundFileNamed("explosionSound.wav", waitFor Completion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    enum gameState {
        
        case preGame //when the gameState is before the start of the game
        case inGame // when the gameState is during the game
        case afterGame //when the gameState is after the game
        
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories {
        
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
        static let Asteroid : UInt32 = 0b1010 //10    
    }
    
    
    //Utility function: Random Number
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRation: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRation
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        //Reset score to 0 when move into Game Scene
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1 {
            
            let background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height*CGFloat(i))
            background.zPosition = 0
            self.addChild(background)
        }
       
        //Set size of the ship
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOntoScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOntoScreenAction)
        livesLabel.run(moveOntoScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    
    //Increase to speed up the background movement
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        //let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        //Set up moving background
        //self.enumerateChildNodes(withName: <#T##String#>, using: <#T##(SKNode, UnsafeMutablePointer<ObjCBool>) -> Void#>)
        /*
        if self.currentGameState == .inGame {
            background.position.y -= amountToMoveBackground
        }
        
        if background.position.y < -self.size.height {
            background.position.y += self.size.height*2
        }
         */
        
        
    }
    
    
    func startGame() {
        
        currentGameState = .inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    
    
    func loseALife() {
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
    }
    
    func addScore() {
        
        gameScore += 1
        scoreLabel.text = "Score : \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 || gameScore == 100 || gameScore == 200 {
            
            startNewLevel()
        }
    }
    
    func runGameOver() {
        
        // currentGameState = gameState.afterGame
        currentGameState = .afterGame
        
        self.removeAllActions()
        
        //Bullet
        //self.enumerateChildNodes(withName: <#T##String#>, using: <#T##(SKNode, UnsafeMutablePointer<ObjCBool>) -> Void#>)
        //bullet.removeAllActions()
        
        //Enemy
        //self.enumerateChildNodes(withName: <#T##String#>, using: <#T##(SKNode, UnsafeMutablePointer<ObjCBool>) -> Void#>)
        //enemy.removeAllActions()
        
        let changeSceneAction = SKAction.run(changeScene)
        
        //Creates pause in changing scene
        let waitToChangeScene = SKAction.wait(forDuration: 0)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene() {
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.contactTestBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            
            //If the player has hit the enemy
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height {
            
            //If the bullet has hit the enemy
            
            addScore()
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Asteroid && (body2.node?.position.y)! < self.size.height {
            
            //If the bullet has hit the asteroid
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Asteroid && (body2.node?.position.y)! < self.size.height {
            
            //If the player has hit the asteroid
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeIn(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        //let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    
    func startNewLevel() {
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1:
            levelDuration = 1.2
        case 2:
            levelDuration = 1
        case 3:
            levelDuration = 0.8
        case 4:
            levelDuration = 0.5
        case 4:
            levelDuration = 0.3
        case 5:
            levelDuration = 0.15
        default:
            levelDuration = 0.15
            print("Cannot find level info")
        }
        
        let spawnE = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawnE])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        
        //Delete the bullet to remove nodes and keep the game from overloading
        let deleteBullet = SKAction.removeFromParent()
        
        //New bulletSequence with sound
        //let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
        let spawnA = arc4random()%7
        
        if spawnA == 0 {
            spawnAsteroid()
        }
    }
    
    
    func spawnEnemy() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        //Decreasing duration increases difficulty
        let moveEnemy = SKAction.move(to: endPoint, duration: 3)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == .inGame {
            enemy.run(enemySequence)
        }
        
        //Rotate the ship image to face the direction the enemy is travelling
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    func spawnAsteroid() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let asteroid = SKSpriteNode(imageNamed: "cartoonAsteroid")
        let asteroidRadius = asteroid.size.width/2
        asteroid.name = "Asteroid"
        asteroid.setScale(1)
        asteroid.position = startPoint
        asteroid.zPosition = 2
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroidRadius)
        
        // asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        asteroid.physicsBody!.affectedByGravity = false
        asteroid.physicsBody!.categoryBitMask = PhysicsCategories.Asteroid
        asteroid.physicsBody!.collisionBitMask = PhysicsCategories.None
        asteroid.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(asteroid)
        
        //Decreasing duration increases difficulty
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let asteroidSequence = SKAction.sequence([moveEnemy, deleteEnemy])
        
        if currentGameState == .inGame {
            asteroid.run(asteroidSequence)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == .preGame {
            startGame()
        }
        
         else if currentGameState == .inGame {
           fireBullet()
        }
    }
    
    
    //Control the ship
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == .inGame {
                player.position.x += amountDragged
            
                if player.position.x > gameArea.maxX - player.size.width/2 {
                
                    player.position.x = gameArea.maxX - player.size.width/2
                }
            
                if player.position.x < gameArea.minX + player.size.width/2 {
                
                    player.position.x = gameArea.minX + player.size.width/2
                }
            }
        }
    }
    
    
    
}







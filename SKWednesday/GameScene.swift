//
//  GameScene.swift
//  SKWednesday
//
//  Created by localadmin on 29.10.18.
//  Copyright © 2018 ch.cqd.skwednesday. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum categories {
        static let noCat:UInt32 = 0
        static let laserCat:UInt32 = 0b1
        static let playerCat:UInt32 = 0b1 << 1
        static let enemyCat:UInt32 = 0b1 << 2
        static let itemCat:UInt32 = 0b1 << 3
        static let bombCat:UInt32 = 0b1 << 4
    }
    
    var player:SKSpriteNode?
    var enemy: SKSpriteNode?
    var fireRate:TimeInterval!
    var timeSinceFire:TimeInterval = 0
    var lastTime:TimeInterval = 0
    var box: SKShapeNode?
    var laser: SKSpriteNode?
    var bomb: SKSpriteNode?
    var gameover: SKLabelNode!
    var lives: Int!
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("contact \(contact.bodyA.node?.name) \(contact.bodyB.node?.name)")
        contact.bodyA.node?.removeFromParent()
        contact.bodyB.node?.removeFromParent()
        if contact.bodyA.node?.name == "player" {
            gameOver()
        }
    }
    
    override func didMove(to view: SKView) {
//        player = self.childNode(withName: "player") as? SKSpriteNode
        let gameData = GameData.shared
        fireRate = gameData.firerate
        lives = gameData.lives
        self.physicsWorld.contactDelegate = self
        
        player = SKSpriteNode(imageNamed: "noun_player_702307")
        
        let baseY = setScene().y + (player?.size.height)!
        player?.position = CGPoint(x: self.view!.bounds.minX, y: baseY)

        player?.physicsBody = SKPhysicsBody(rectangleOf: player!.size)
        player?.physicsBody?.isDynamic = false
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        // category that this physics body belongs too
        player?.physicsBody?.categoryBitMask = categories.playerCat
        // category that defines which bodies will react it
        player?.physicsBody?.collisionBitMask = categories.noCat
        // respond with cause delegate calls
        player?.physicsBody?.contactTestBitMask = categories.bombCat | categories.enemyCat
        player?.name = "player"
        
        addChild(player!)
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        box = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 256, height: 256))
        box?.lineWidth = 0
        addChild(box!)
        
        let alienA = SKTextureAtlas(named: "A1")
        let alienB = SKTextureAtlas(named: "B1")
        let alienC = SKTextureAtlas(named: "C1")
        
        let alienAT = buildTexture(tag2U: "noun_alien_A", alien2U: alienA)
        let alienBT = buildTexture(tag2U: "noun_alien_B", alien2U: alienB)
        let alienCT = buildTexture(tag2U: "noun_alien_C", alien2U: alienC)
        
        for yCord in stride(from: 0, to: 257, by: 64) {

            
            for xCord in stride(from: 0, to: 257, by: 64) {
                if yCord < 128 {
                enemy = SKSpriteNode(imageNamed: "noun_alien_A1")
                enemy?.run(SKAction.repeatForever(SKAction.animate(with: alienAT, timePerFrame: 0.5, resize: false, restore: true)), withKey:"mutationA")
                } else {
                    if yCord > 127 && yCord < 127 + 128{
                    enemy = SKSpriteNode(imageNamed: "noun_alien_B1")
                    enemy?.run(SKAction.repeatForever(SKAction.animate(with: alienBT, timePerFrame: 0.5, resize: false, restore: true)), withKey:"mutationB")
                    } else {
                        enemy = SKSpriteNode(imageNamed: "noun_alien_C1")
                        enemy?.run(SKAction.repeatForever(SKAction.animate(with: alienCT, timePerFrame: 0.5, resize: false, restore: true)), withKey:"mutationC")
                    }
                }
                
                enemy?.scale(to: CGSize(width: 50, height: 50))
                enemy?.position = CGPoint(x: xCord, y: yCord)
                enemy?.physicsBody = SKPhysicsBody(rectangleOf: enemy!.size)
                enemy?.physicsBody?.isDynamic = true
                enemy?.physicsBody?.affectedByGravity = false
                enemy?.physicsBody?.allowsRotation = true
                enemy?.physicsBody?.categoryBitMask = categories.enemyCat
                // category that defines which bodies will react it
                enemy?.physicsBody?.collisionBitMask = categories.noCat
                // respond with cause delegate calls
                enemy?.physicsBody?.contactTestBitMask = categories.playerCat | categories.laserCat
                enemy?.name = "enemy"
                box?.addChild(enemy!)
                
            }
        }
    }
    
    func buildTexture(tag2U: String, alien2U: SKTextureAtlas) -> [SKTexture] {
        var lightFrames: [SKTexture] = []
        let numImages = alien2U.textureNames.count
        for i in 1...numImages {
            let alienTexture = "\(tag2U)\(i)"
            lightFrames.append(alien2U.textureNamed(alienTexture))
        }
        return lightFrames
    }
    
    func setScene() -> CGPoint {
        let xScene = scene?.view?.bounds.midX
        let yScene = scene?.view?.bounds.maxY
        let sceneBottom = scene?.convertPoint(fromView:CGPoint(x:xScene!,y:yScene!))
        let nodeBottom = player!.convert(sceneBottom!,from:scene!)
        return nodeBottom
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        
        let pointTouched = touches.first?.location(in: self.view)
        print("pointTouched \(pointTouched!.y)")
        if pointTouched!.y < 64 {
            let doors = SKTransition.crossFade(withDuration: 2)
            doors.pausesIncomingScene = false
            doors.pausesOutgoingScene = true
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                view!.presentScene(scene, transition: doors)
            }
        }
        
        if player?.parent == nil {
            return
        }
        
        if pointTouched!.x < (self.view?.bounds.minX)! + 128 {
            let moveLeft = SKAction.moveBy(x: -24, y: 0, duration: 0)
                        print("LeftSide")
            player!.run(moveLeft)
            return
        }
        if pointTouched!.x > (self.view?.bounds.maxX)! - 128 {
                        print("RightSide")
            let moveRight = SKAction.moveBy(x: 24, y: 0, duration: 0)
            player!.run(moveRight)
            return
        }
        
        spawnLaser()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
 
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        checkLaser(currentTime - lastTime)
        lastTime = currentTime
        if laser != nil {
            if (!intersects(laser!)) {
                laser?.removeFromParent()
                laser = nil
            }
        }
        fireRate -= 0.0001
    }
    
    var needToMoveRight: Bool = false
    var needToMoveLeft: Bool = true
    var moveDown:Int = 0
    var movedDown:Int = 0
    var pixel2M:Int? = nil
    
    func checkLaser(_ frameRate:TimeInterval) {
        // add time to timer
        timeSinceFire += frameRate
        
        // return if it hasn't been enough time to fire laser
        if timeSinceFire < fireRate {
            return
        }
        
        //spawn laser
//        spawnLaser()
        if pixel2M != nil {
            if moveDown > pixel2M! {
                let moveAction = SKAction.moveBy(x: 0, y: -4, duration: 0)
                self.box?.run(moveAction)
                moveDown = 0
            }
        }
        
        if needToMoveLeft && Int((self.box?.position.x)!) > -256 {
            let moveAction = SKAction.moveBy(x: -4, y: 0, duration: 0)
            self.box?.run(moveAction)
            moveDown += 1
        } else {
            needToMoveRight = true
            needToMoveLeft = false
            if pixel2M == nil {
                pixel2M = moveDown
            }
        }
        if needToMoveRight && Int((self.box?.position.x)!+256) < 256 {
            let moveAction = SKAction.moveBy(x: 4, y: 0, duration: 0)
            self.box?.run(moveAction)
            moveDown += 1
        } else {
            needToMoveLeft = true
            needToMoveRight = false
        }
        
        
//        print("self.enemy?.position.x \(self.enemy?.position.x) \(moveDown)")
        
        // reset timer
        timeSinceFire = 0
    }
    
    func spawnLaser() {
        if laser?.parent != nil {
            if box!.children.count == 0 {
                GameData.shared.firerate = fireRate/2
                let doors = SKTransition.crossFade(withDuration: 2)
                doors.pausesIncomingScene = false
                doors.pausesOutgoingScene = true
                if let scene = SKScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    view!.presentScene(scene, transition: doors)
                }
            } else {
                spawnBomb()
                let options = box!.children.count
                let randP = GKRandomSource.sharedRandom().nextInt(upperBound: options)
                let alienToarm = box!.children[randP]
                bomb?.position = alienToarm.position
                bomb?.position.y = (box?.position.y)!
                addChild(bomb!)
            }
            return
        }
        let laserColor:UIColor = UIColor(displayP3Red: 41.0 / 255.0, green: 184.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        laser = SKSpriteNode(color: laserColor, size: CGSize(width: 7, height: 21))
        laser?.position = player!.position
        self.addChild(laser!)
        
        laser?.physicsBody = SKPhysicsBody(rectangleOf: laser!.size)
        laser?.physicsBody?.isDynamic = true
        laser?.physicsBody?.allowsRotation = true
        laser?.physicsBody?.affectedByGravity = true
        laser?.physicsBody?.friction = 0.0
        laser?.physicsBody?.restitution = 0.0
        laser?.physicsBody?.angularDamping = 0.0
        laser?.physicsBody?.mass = 0.006
        laser?.physicsBody?.linearDamping = 0
        laser?.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        laser?.physicsBody?.categoryBitMask = categories.laserCat
        laser?.physicsBody?.collisionBitMask = categories.noCat
        laser?.physicsBody?.contactTestBitMask = categories.enemyCat
        laser?.name = "laser"
        
    }
    
    func spawnBomb() {
        bomb = SKSpriteNode(color: UIColor.green, size: CGSize(width: 7, height: 21))
        bomb?.physicsBody = SKPhysicsBody(rectangleOf: bomb!.size)
        bomb?.physicsBody?.isDynamic = true
        bomb?.physicsBody?.allowsRotation = true
        bomb?.physicsBody?.affectedByGravity = true
        bomb?.physicsBody?.friction = 0.0
        bomb?.physicsBody?.restitution = 0.0
        bomb?.physicsBody?.angularDamping = 0.0
        bomb?.physicsBody?.mass = 0.006
        bomb?.physicsBody?.linearDamping = 0
        bomb?.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
        bomb?.physicsBody?.categoryBitMask = categories.bombCat
        bomb?.physicsBody?.collisionBitMask = categories.noCat
        bomb?.physicsBody?.contactTestBitMask = categories.playerCat
        bomb?.name = "bomb"
    }
    
    func gameOver() {
        let switchToLeaderboard = SKAction.run {
//            if let scene = SKScene(fileNamed: "Leaderboard") {
//                scene.scaleMode = .aspectFill
//                let doors = SKTransition.crossFade(withDuration: 2)
//                doors.pausesIncomingScene = false
//                doors.pausesOutgoingScene = true
//                self.view!.presentScene(scene, transition: doors)
//            }
        }
        gameover = SKLabelNode(fontNamed: "HoeflerText-Italic")
        gameover.text = "Game Over"
        gameover.fontSize = 65
        gameover.fontColor = SKColor.white
        gameover.position = CGPoint(x: frame.midX, y: frame.midY)
        self.lives -= 1
        print(lives)
        if lives == 0 {
            self.run(switchToLeaderboard)
        }
        //
        //        removeAction(forKey: enableGestures)
        //      removeAction(forKey: respondToGesture())
        addChild(gameover)
    }
}

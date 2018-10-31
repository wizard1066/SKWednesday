//
//  OpenScene.swift
//  SKWednesday
//
//  Created by localadmin on 31.10.18.
//  Copyright © 2018 ch.cqd.skwednesday. All rights reserved.
//

import SpriteKit

class OpenScene: SKScene {
    
    override func didMove(to view: SKView) {
        makeLogo()
    }
    
    func makeLogo() {
        let logo = SKSpriteNode(imageNamed: "noun_alien_702288")
        logo.scale(to: CGSize(width: 256, height: 256))
        // let logoImage = UIImage(named:"Agario Power")
        logo.position = CGPoint(x: (self.view?.bounds.minX)!, y: (self.view?.bounds.minY)!)
        self.addChild(logo)
        
        let smoker = SKEmitterNode(fileNamed: "MyParticle")
        smoker?.position = logo.position
        addChild(smoker!)
        
        let label = SKLabelNode(text: "Space Invaders")
        label.position = CGPoint(x: (self.view?.bounds.minX)!, y: (self.view?.bounds.minY)! - 200)
        label.fontSize = 48
        label.fontName = "MarkerFelt-Thin"
        self.addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let doors = SKTransition.crossFade(withDuration: 2)
        
        doors.pausesIncomingScene = true
        doors.pausesOutgoingScene = true
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            view!.presentScene(scene, transition: doors)
        }
    }
}

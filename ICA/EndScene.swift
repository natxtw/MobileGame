//
//  EndScene.swift
//  ICA
//
//  Created by TAYLOR, NATHAN on 02/12/2019.
//  Copyright © 2019 TAYLOR, NATHAN. All rights reserved.
//

import Foundation
import SpriteKit

class EndScene: SKScene {
    init(size: CGSize, won:Bool){
        super.init(size: size)
        backgroundColor = SKColor.white //sets background to white
        let endMessage = won ? "Congratulation, You Won!" : "Commiserations, You Lost!" //Final message for player
        //adding he endgame label
        let label = SKLabelNode (fontNamed: "Chalkduster")
        label.text = endMessage
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
        
        run (SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self] in
            
                guard let `self` = self else {return}
                let reveal = SKTransition.fade(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition: reveal)
            }]))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been impleented")
    }
}



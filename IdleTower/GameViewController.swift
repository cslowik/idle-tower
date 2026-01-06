//
//  GameViewController.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import UIKit
import SpriteKit
import IdleTowerCore

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize simulator with starting resources
        let startingState = GameState(materials: 10) // Enough to buy first Miner
        let simulator = Simulator(state: startingState)
        
        // Create scene
        guard let view = self.view as? SKView else { return }
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Set simulator on scene
        scene.simulator = simulator
        
        // Present the scene
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

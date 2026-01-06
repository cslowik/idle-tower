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

    private var scene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize simulator with starting resources
        let startingState = GameState(materials: 10) // Enough to buy first Miner
        let simulator = Simulator(state: startingState)
        
        // Create scene
        guard let view = self.view as? SKView else { return }
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        self.scene = scene
        
        // Set simulator on scene
        scene.simulator = simulator
        
        // Present the scene
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Safe area insets are now definitely available
        guard let view = self.view as? SKView else { return }
        scene?.safeAreaInsets = view.safeAreaInsets
        scene?.updateResourceBarPosition()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Update safe area insets when they change (e.g., device rotation)
        guard let view = self.view as? SKView else { return }
        scene?.safeAreaInsets = view.safeAreaInsets
        scene?.updateResourceBarPosition()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure safe area insets are set after layout
        guard let view = self.view as? SKView else { return }
        scene?.safeAreaInsets = view.safeAreaInsets
        scene?.updateResourceBarPosition()
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

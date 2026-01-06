//
//  GameScene.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

class GameScene: SKScene {
    
    private var lastUpdateTime : TimeInterval = 0
    
    var simulator: Simulator? {
        didSet {
            if simulator != nil && resourceBar == nil {
                setupUI()
            }
        }
    }
    private var resourceBar: ResourceBar?
    private var shopView: ShopView?
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    func setupUI() {
        guard let simulator = simulator else { return }
        
        // Create resource bar at top
        let resourceBar = ResourceBar()
        resourceBar.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(resourceBar)
        self.resourceBar = resourceBar
        
        // Create shop view
        let shopView = ShopView(simulator: simulator, size: CGSize(width: size.width, height: size.height - 120))
        shopView.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        addChild(shopView)
        self.shopView = shopView
        
        // Initial UI update
        updateUI()
    }
    
    func updateUI() {
        guard let simulator = simulator else { return }
        resourceBar?.update(state: simulator.state)
        shopView?.updateAllItems()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update simulator
        if let simulator = simulator {
            simulator.tick(dt: dt)
            updateUI()
        }
        
        self.lastUpdateTime = currentTime
    }
}

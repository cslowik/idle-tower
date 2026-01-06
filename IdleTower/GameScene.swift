//
//  GameScene.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import UIKit
import IdleTowerCore

class GameScene: SKScene {
    
    private var lastUpdateTime : TimeInterval = 0
    var safeAreaInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    var simulator: Simulator? {
        didSet {
            if simulator != nil && resourceBar == nil {
                setupUI()
            }
        }
    }
    private var resourceBar: ResourceBar?
    private var shopView: ShopView?
    private var cardsView: CardsView?
    private var researchView: ResearchView?
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    func setupUI() {
        guard let simulator = simulator else { return }
        
        // Create resource bar at top
        let resourceBar = ResourceBar(size: size)
        // Position below safe area with padding
        // Background height is 90, so center should be at height - safeAreaTop - 45 - padding
        let topPadding: CGFloat = 10
        let safeAreaTop = safeAreaInsets.top
        resourceBar.position = CGPoint(x: size.width / 2, y: size.height - safeAreaTop - 45 - topPadding)
        addChild(resourceBar)
        self.resourceBar = resourceBar
        
        // Create shop view - leave space for resource bar (90 height + safe area + padding)
        let resourceBarBottom = size.height - safeAreaTop - 90 - topPadding
        let availableHeight = resourceBarBottom
        
        // Split available space: Shop (40%), Cards (30%), Research (30%)
        let shopHeight = availableHeight * 0.4
        let cardsHeight = availableHeight * 0.3
        let researchHeight = availableHeight * 0.3
        
        // Shop view - top section
        let shopView = ShopView(simulator: simulator, size: CGSize(width: size.width, height: shopHeight))
        shopView.position = CGPoint(x: size.width / 2, y: resourceBarBottom - shopHeight / 2)
        addChild(shopView)
        self.shopView = shopView
        
        // Cards view - middle section
        let cardsView = CardsView(simulator: simulator, size: CGSize(width: size.width, height: cardsHeight))
        let cardsY = resourceBarBottom - shopHeight - cardsHeight / 2
        cardsView.position = CGPoint(x: size.width / 2, y: cardsY)
        addChild(cardsView)
        self.cardsView = cardsView
        
        // Research view - bottom section
        let researchView = ResearchView(simulator: simulator, size: CGSize(width: size.width, height: researchHeight))
        let researchY = resourceBarBottom - shopHeight - cardsHeight - researchHeight / 2
        researchView.position = CGPoint(x: size.width / 2, y: researchY)
        addChild(researchView)
        self.researchView = researchView
        
        // Initial UI update
        updateUI()
    }
    
    func updateUI() {
        guard let simulator = simulator else { return }
        resourceBar?.update(state: simulator.state)
        shopView?.updateAllItems()
        cardsView?.updateCards()
        researchView?.updateResearch()
    }
    
    func updateResourceBarPosition() {
        guard let resourceBar = resourceBar else { return }
        
        // Update resource bar position based on current safe area insets
        let topPadding: CGFloat = 10
        let safeAreaTop = safeAreaInsets.top
        resourceBar.position = CGPoint(x: size.width / 2, y: size.height - safeAreaTop - 45 - topPadding)
        
        // Update shop, cards, and research view positions
        if let shopView = shopView, let cardsView = cardsView, let researchView = researchView {
            let resourceBarBottom = size.height - safeAreaTop - 90 - topPadding
            let availableHeight = resourceBarBottom
            let shopHeight = availableHeight * 0.4
            let cardsHeight = availableHeight * 0.3
            let researchHeight = availableHeight * 0.3
            
            shopView.position = CGPoint(x: size.width / 2, y: resourceBarBottom - shopHeight / 2)
            let cardsY = resourceBarBottom - shopHeight - cardsHeight / 2
            cardsView.position = CGPoint(x: size.width / 2, y: cardsY)
            let researchY = resourceBarBottom - shopHeight - cardsHeight - researchHeight / 2
            researchView.position = CGPoint(x: size.width / 2, y: researchY)
        }
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

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
    private var cardsButton: SKNode?
    private var researchButton: SKNode?
    
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
        
        // Shop view - takes full available space
        let shopView = ShopView(simulator: simulator, size: CGSize(width: size.width, height: availableHeight))
        shopView.position = CGPoint(x: size.width / 2, y: availableHeight / 2)
        addChild(shopView)
        self.shopView = shopView
        
        // Create modal views (initially hidden)
        // Position modals at center of scene so overlay covers entire screen
        let cardsView = CardsView(simulator: simulator, size: size)
        cardsView.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cardsView.zPosition = 1000 // High zPosition to appear above everything
        cardsView.onClose = { [weak self] in
            // Modal closed callback
        }
        addChild(cardsView)
        self.cardsView = cardsView
        
        let researchView = ResearchView(simulator: simulator, size: size)
        researchView.position = CGPoint(x: size.width / 2, y: size.height / 2)
        researchView.zPosition = 1000 // High zPosition to appear above everything
        researchView.onClose = { [weak self] in
            // Modal closed callback
        }
        addChild(researchView)
        self.researchView = researchView
        
        // Create buttons to open modals
        setupModalButtons(size: size, resourceBarBottom: resourceBarBottom)
        
        // Initial UI update
        updateUI()
    }
    
    private func setupModalButtons(size: CGSize, resourceBarBottom: CGFloat) {
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 20
        let buttonY = resourceBarBottom - 30
        
        // Cards button - use SKShapeNode directly for better hit testing
        let cardsButtonBackground = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        cardsButtonBackground.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.9)
        cardsButtonBackground.strokeColor = SKColor.cyan
        cardsButtonBackground.lineWidth = 2
        cardsButtonBackground.position = CGPoint(x: size.width / 2 - buttonWidth / 2 - buttonSpacing / 2, y: buttonY)
        cardsButtonBackground.isUserInteractionEnabled = true
        cardsButtonBackground.zPosition = 10
        addChild(cardsButtonBackground)
        self.cardsButton = cardsButtonBackground
        
        let cardsButtonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        cardsButtonLabel.fontSize = 18
        cardsButtonLabel.fontColor = SKColor.white
        cardsButtonLabel.text = "Cards"
        cardsButtonLabel.verticalAlignmentMode = .center
        cardsButtonLabel.position = cardsButtonBackground.position
        cardsButtonLabel.zPosition = 11
        addChild(cardsButtonLabel)
        
        // Research button - use SKShapeNode directly for better hit testing
        let researchButtonBackground = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        researchButtonBackground.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 0.9)
        researchButtonBackground.strokeColor = SKColor.green
        researchButtonBackground.lineWidth = 2
        researchButtonBackground.position = CGPoint(x: size.width / 2 + buttonWidth / 2 + buttonSpacing / 2, y: buttonY)
        researchButtonBackground.isUserInteractionEnabled = true
        researchButtonBackground.zPosition = 10
        addChild(researchButtonBackground)
        self.researchButton = researchButtonBackground
        
        let researchButtonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        researchButtonLabel.fontSize = 18
        researchButtonLabel.fontColor = SKColor.white
        researchButtonLabel.text = "Research"
        researchButtonLabel.verticalAlignmentMode = .center
        researchButtonLabel.position = researchButtonBackground.position
        researchButtonLabel.zPosition = 11
        addChild(researchButtonLabel)
    }
    
    func updateUI() {
        guard let simulator = simulator else { return }
        resourceBar?.update(state: simulator.state)
        shopView?.updateAllItems()
        // Only update modals if they're visible
        if let cardsView = cardsView, !cardsView.isHidden {
            cardsView.updateCards()
        }
        if let researchView = researchView, !researchView.isHidden {
            researchView.updateResearch()
        }
    }
    
    func updateResourceBarPosition() {
        guard let resourceBar = resourceBar else { return }
        
        // Update resource bar position based on current safe area insets
        let topPadding: CGFloat = 10
        let safeAreaTop = safeAreaInsets.top
        resourceBar.position = CGPoint(x: size.width / 2, y: size.height - safeAreaTop - 45 - topPadding)
        
        // Update shop view position
        if let shopView = shopView {
            let resourceBarBottom = size.height - safeAreaTop - 90 - topPadding
            let availableHeight = resourceBarBottom
            shopView.position = CGPoint(x: size.width / 2, y: availableHeight / 2)
        }
        
        // Update modal button positions
        if let cardsButton = cardsButton as? SKShapeNode, let researchButton = researchButton as? SKShapeNode {
            let resourceBarBottom = size.height - safeAreaTop - 90 - topPadding
            let buttonY = resourceBarBottom - 30
            let buttonWidth: CGFloat = 120
            let buttonSpacing: CGFloat = 20
            
            cardsButton.position = CGPoint(x: size.width / 2 - buttonWidth / 2 - buttonSpacing / 2, y: buttonY)
            researchButton.position = CGPoint(x: size.width / 2 + buttonWidth / 2 + buttonSpacing / 2, y: buttonY)
            
            // Update label positions too
            for child in children {
                if let label = child as? SKLabelNode, label.text == "Cards" {
                    label.position = cardsButton.position
                } else if let label = child as? SKLabelNode, label.text == "Research" {
                    label.position = researchButton.position
                }
            }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touching cards button
        if let cardsButton = cardsButton as? SKShapeNode {
            if cardsButton.contains(location) {
                cardsView?.updateCards()
                cardsView?.show()
                return
            }
        }
        
        // Check if touching research button
        if let researchButton = researchButton as? SKShapeNode {
            if researchButton.contains(location) {
                researchView?.updateResearch()
                researchView?.show()
                return
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Touch handling moved to touchesBegan for better responsiveness
    }
}

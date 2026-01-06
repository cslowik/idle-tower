//
//  ShopItemNode.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

class ShopItemNode: SKNode {
    private let producerDef: ProducerDef
    private let simulator: Simulator
    private var nameLabel: SKLabelNode!
    private var costLabel: SKLabelNode!
    private var ownedLabel: SKLabelNode!
    private var background: SKShapeNode!
    
    var onPurchase: (() -> Void)?
    
    init(producerDef: ProducerDef, simulator: Simulator, width: CGFloat) {
        self.producerDef = producerDef
        self.simulator = simulator
        super.init()
        setupUI(width: width)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(width: CGFloat) {
        // Background
        background = SKShapeNode(rectOf: CGSize(width: width - 20, height: 80))
        background.fillColor = SKColor(white: 0.2, alpha: 0.9)
        background.strokeColor = SKColor(white: 0.4, alpha: 1.0)
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
        
        // Name label
        nameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nameLabel.fontSize = 20
        nameLabel.fontColor = SKColor.white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -width/2 + 20, y: 20)
        nameLabel.text = producerDef.name
        addChild(nameLabel)
        
        // Cost label
        costLabel = SKLabelNode(fontNamed: "Arial")
        costLabel.fontSize = 16
        costLabel.fontColor = SKColor.lightGray
        costLabel.horizontalAlignmentMode = .left
        costLabel.position = CGPoint(x: -width/2 + 20, y: -5)
        addChild(costLabel)
        
        // Owned label
        ownedLabel = SKLabelNode(fontNamed: "Arial")
        ownedLabel.fontSize = 16
        ownedLabel.fontColor = SKColor.green
        ownedLabel.horizontalAlignmentMode = .right
        ownedLabel.position = CGPoint(x: width/2 - 20, y: 0)
        addChild(ownedLabel)
        
        // Make background interactive
        background.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
        
        updateDisplay()
    }
    
    func updateDisplay() {
        let cost = simulator.producerCost(id: producerDef.id)
        let owned = simulator.state.producers[producerDef.id] ?? 0
        
        // Format cost string
        var costParts: [String] = []
        if cost.materials > 0 {
            costParts.append(String(format: "M:%.1f", cost.materials))
        }
        if cost.energy > 0 {
            costParts.append(String(format: "E:%.1f", cost.energy))
        }
        if cost.data > 0 {
            costParts.append(String(format: "D:%.1f", cost.data))
        }
        costLabel.text = costParts.isEmpty ? "Free" : costParts.joined(separator: " ")
        
        // Update owned count
        ownedLabel.text = "Owned: \(owned)"
        
        // Update background color based on affordability
        let canAfford = simulator.state.materials >= cost.materials &&
                       simulator.energyCapacity() >= cost.energy &&
                       simulator.state.data >= cost.data
        
        background.fillColor = canAfford ?
            SKColor(white: 0.3, alpha: 0.9) :
            SKColor(white: 0.15, alpha: 0.9)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if background.contains(location) {
            if simulator.buyProducer(id: producerDef.id) {
                updateDisplay()
                onPurchase?()
            }
        }
    }
}


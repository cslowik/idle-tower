//
//  ResourceBar.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

class ResourceBar: SKNode {
    private var materialsLabel: SKLabelNode!
    private var energyLabel: SKLabelNode!
    private var dataLabel: SKLabelNode!
    
    init(size: CGSize) {
        super.init()
        setupUI(size: size)
    }
    
    override init() {
        super.init()
        // Default size if needed
        setupUI(size: CGSize(width: 1000, height: 90))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Default size if needed
        setupUI(size: CGSize(width: 1000, height: 90))
    }
    
    private func setupUI(size: CGSize) {
        let barWidth = size.width - 40
        let barHeight: CGFloat = 90
        
        // Create background bar - taller to accommodate stacked rows
        let background = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        background.fillColor = SKColor(white: 0.1, alpha: 0.8)
        background.strokeColor = SKColor(white: 0.3, alpha: 1.0)
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
        
        let leftMargin: CGFloat = -barWidth / 2 + 20
        
        // Materials label - top row
        materialsLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        materialsLabel.fontSize = 24
        materialsLabel.fontColor = SKColor.orange
        materialsLabel.horizontalAlignmentMode = .left
        materialsLabel.position = CGPoint(x: leftMargin, y: 20)
        materialsLabel.text = "Materials: 0"
        addChild(materialsLabel)
        
        // Energy label - middle row
        energyLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        energyLabel.fontSize = 24
        energyLabel.fontColor = SKColor.yellow
        energyLabel.horizontalAlignmentMode = .left
        energyLabel.position = CGPoint(x: leftMargin, y: -10)
        energyLabel.text = "Energy: 0"
        addChild(energyLabel)
        
        // Data label - bottom row
        dataLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        dataLabel.fontSize = 24
        dataLabel.fontColor = SKColor.cyan
        dataLabel.horizontalAlignmentMode = .left
        dataLabel.position = CGPoint(x: leftMargin, y: -40)
        dataLabel.text = "Data: 0"
        addChild(dataLabel)
    }
    
    func update(state: GameState) {
        materialsLabel.text = String(format: "Materials: %.1f", state.materials)
        energyLabel.text = String(format: "Energy: %.1f", state.energy)
        dataLabel.text = String(format: "Data: %.1f", state.data)
    }
}


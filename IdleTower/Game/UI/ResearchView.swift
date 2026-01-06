//
//  ResearchView.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

class ResearchView: SKNode {
    private let simulator: Simulator
    private let viewSize: CGSize
    private var scrollContainer: SKNode!
    private var researchNodes: [String: SKNode] = [:] // Maps research ID to node
    private var lastTouchY: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var isScrolling: Bool = false
    private let itemHeight: CGFloat = 90
    private let spacing: CGFloat = 10
    
    init(simulator: Simulator, size: CGSize) {
        self.simulator = simulator
        self.viewSize = size
        super.init()
        setupUI(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(size: CGSize) {
        // Create scroll container
        scrollContainer = SKNode()
        addChild(scrollContainer)
        
        // Enable user interaction for scrolling
        self.isUserInteractionEnabled = true
        
        updateResearch()
    }
    
    func updateResearch() {
        let width = viewSize.width - 40
        
        // Clear existing research nodes
        for (_, node) in researchNodes {
            node.removeFromParent()
        }
        researchNodes.removeAll()
        
        // Sort research by prerequisites (root nodes first)
        let sortedResearch = sortResearchByPrerequisites(simulator.catalog.availableResearchTree)
        
        // Create research items
        var currentY: CGFloat = 0
        for researchDef in sortedResearch {
            let researchNode = createResearchNode(researchDef: researchDef, width: width)
            researchNode.position = CGPoint(x: 0, y: currentY)
            scrollContainer.addChild(researchNode)
            researchNodes[researchDef.id] = researchNode
            currentY -= (itemHeight + spacing)
        }
    }
    
    private func sortResearchByPrerequisites(_ research: [ResearchDef]) -> [ResearchDef] {
        var sorted: [ResearchDef] = []
        var remaining = research
        var addedIds = Set<String>()
        
        // Keep adding research that has all prerequisites satisfied
        while !remaining.isEmpty {
            var madeProgress = false
            
            for def in remaining {
                let prerequisitesMet = def.prerequisites.allSatisfy { addedIds.contains($0) }
                if prerequisitesMet {
                    sorted.append(def)
                    addedIds.insert(def.id)
                    remaining.removeAll { $0.id == def.id }
                    madeProgress = true
                }
            }
            
            // If no progress was made, add remaining items anyway (shouldn't happen with valid tree)
            if !madeProgress {
                sorted.append(contentsOf: remaining)
                break
            }
        }
        
        return sorted
    }
    
    private func createResearchNode(researchDef: ResearchDef, width: CGFloat) -> SKNode {
        let container = SKNode()
        
        let isResearched = simulator.state.researchedTech.contains(researchDef.id)
        let canBuy = simulator.canBuyResearch(researchId: researchDef.id)
        
        // Background
        let background = SKShapeNode(rectOf: CGSize(width: width - 20, height: itemHeight))
        
        if isResearched {
            background.fillColor = SKColor(white: 0.1, alpha: 0.9)
            background.strokeColor = SKColor.green
        } else if canBuy {
            background.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.9)
            background.strokeColor = SKColor.cyan
        } else {
            background.fillColor = SKColor(white: 0.15, alpha: 0.9)
            background.strokeColor = SKColor.gray
        }
        
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        container.addChild(background)
        
        // Research name
        let nameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nameLabel.fontSize = 18
        nameLabel.fontColor = isResearched ? SKColor.green : SKColor.white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -width/2 + 20, y: 25)
        nameLabel.text = researchDef.name
        container.addChild(nameLabel)
        
        // Research description
        let descLabel = SKLabelNode(fontNamed: "Arial")
        descLabel.fontSize = 14
        descLabel.fontColor = SKColor.lightGray
        descLabel.horizontalAlignmentMode = .left
        descLabel.position = CGPoint(x: -width/2 + 20, y: 5)
        descLabel.text = researchDef.description
        container.addChild(descLabel)
        
        // Cost label
        let costLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        costLabel.fontSize = 16
        costLabel.fontColor = SKColor.yellow
        costLabel.horizontalAlignmentMode = .right
        costLabel.position = CGPoint(x: width/2 - 20, y: 15)
        
        if isResearched {
            costLabel.text = "RESEARCHED"
            costLabel.fontColor = SKColor.green
        } else {
            costLabel.text = String(format: "Data: %.0f", researchDef.cost)
            
            // Show if affordable
            if simulator.state.data >= researchDef.cost {
                costLabel.fontColor = SKColor.green
            } else {
                costLabel.fontColor = SKColor.red
            }
        }
        container.addChild(costLabel)
        
        // Prerequisites indicator
        if !researchDef.prerequisites.isEmpty {
            let prereqLabel = SKLabelNode(fontNamed: "Arial")
            prereqLabel.fontSize = 12
            prereqLabel.fontColor = SKColor.orange
            prereqLabel.horizontalAlignmentMode = .left
            prereqLabel.position = CGPoint(x: -width/2 + 20, y: -20)
            
            let prereqNames = researchDef.prerequisites.compactMap { id in
                simulator.catalog.availableResearchTree.first(where: { $0.id == id })?.name
            }
            let allPrereqsMet = researchDef.prerequisites.allSatisfy { simulator.state.researchedTech.contains($0) }
            
            prereqLabel.text = "Requires: \(prereqNames.joined(separator: ", "))"
            prereqLabel.fontColor = allPrereqsMet ? SKColor.green : SKColor.orange
            container.addChild(prereqLabel)
        }
        
        // Purchase button for available research
        if !isResearched && canBuy {
            let buyLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
            buyLabel.fontSize = 14
            buyLabel.fontColor = SKColor.green
            buyLabel.horizontalAlignmentMode = .right
            buyLabel.position = CGPoint(x: width/2 - 20, y: -25)
            buyLabel.text = "TAP TO BUY"
            container.addChild(buyLabel)
            
            // Store research ID for tap handling
            background.userData = ["researchId": researchDef.id]
        }
        
        // Make interactive if purchasable
        container.isUserInteractionEnabled = !isResearched && canBuy
        background.isUserInteractionEnabled = false
        
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchY = touch.location(in: self).y
        isScrolling = false
        
        // Check if touching a purchasable research item
        let locationInView = touch.location(in: self)
        for (researchId, researchNode) in researchNodes {
            if researchNode.isUserInteractionEnabled {
                let locationInNode = touch.location(in: researchNode)
                if researchNode.contains(locationInNode) {
                    if simulator.buyResearch(researchId: researchId) {
                        updateResearch()
                    }
                    return
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentY = touch.location(in: self).y
        let deltaY = abs(currentY - lastTouchY)
        
        // Only scroll if movement is significant
        if deltaY > 5 {
            isScrolling = true
            scrollOffset += (currentY - lastTouchY)
            
            // Clamp scroll offset
            let totalHeight = CGFloat(simulator.catalog.availableResearchTree.count) * (itemHeight + spacing)
            let maxOffset = max(0, totalHeight - 400)
            scrollOffset = max(0, min(maxOffset, scrollOffset))
            
            scrollContainer.position = CGPoint(x: 0, y: scrollOffset)
            lastTouchY = currentY
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isScrolling = false
    }
}


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
    private var overlayBackground: SKShapeNode!
    private var modalContainer: SKNode!
    private var contentContainer: SKNode!
    private var scrollContainer: SKNode!
    private var closeButton: SKNode!
    private var researchNodes: [String: SKNode] = [:] // Maps research ID to node
    private var lastTouchY: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var isScrolling: Bool = false
    private let itemHeight: CGFloat = 90
    private let spacing: CGFloat = 10
    
    var onClose: (() -> Void)?
    
    init(simulator: Simulator, size: CGSize) {
        self.simulator = simulator
        self.viewSize = size
        super.init()
        setupModal(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupModal(size: CGSize) {
        // Create overlay background (semi-transparent black)
        // Position relative to this node (which is centered in scene)
        overlayBackground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlayBackground.fillColor = SKColor(white: 0, alpha: 0.7)
        overlayBackground.strokeColor = SKColor.clear
        overlayBackground.position = CGPoint(x: 0, y: 0) // Center of this node
        overlayBackground.zPosition = 100
        addChild(overlayBackground)
        
        // Create modal container (centered)
        modalContainer = SKNode()
        modalContainer.position = CGPoint(x: 0, y: 0) // Center of this node
        modalContainer.zPosition = 101
        addChild(modalContainer)
        
        // Modal window background
        let modalWidth = size.width * 0.9
        let modalHeight = size.height * 0.8
        let modalBackground = SKShapeNode(rectOf: CGSize(width: modalWidth, height: modalHeight), cornerRadius: 10)
        modalBackground.fillColor = SKColor(white: 0.15, alpha: 0.95)
        modalBackground.strokeColor = SKColor.white
        modalBackground.lineWidth = 3
        modalBackground.position = CGPoint(x: 0, y: 0)
        modalContainer.addChild(modalBackground)
        
        // Title label
        let titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.fontSize = 28
        titleLabel.fontColor = SKColor.green
        titleLabel.text = "Research"
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: modalHeight / 2 - 40)
        modalContainer.addChild(titleLabel)
        
        // Close button
        let closeButtonSize: CGFloat = 40
        closeButton = SKNode()
        let closeBackground = SKShapeNode(rectOf: CGSize(width: closeButtonSize, height: closeButtonSize), cornerRadius: 5)
        closeBackground.fillColor = SKColor.red
        closeBackground.strokeColor = SKColor.white
        closeBackground.lineWidth = 2
        closeButton.addChild(closeBackground)
        
        let closeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        closeLabel.fontSize = 24
        closeLabel.fontColor = SKColor.white
        closeLabel.text = "×"
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
        
        closeButton.position = CGPoint(x: modalWidth / 2 - closeButtonSize / 2 - 10, y: modalHeight / 2 - closeButtonSize / 2 - 10)
        closeButton.isUserInteractionEnabled = true
        modalContainer.addChild(closeButton)
        
        // Content container (scrollable area)
        contentContainer = SKNode()
        contentContainer.position = CGPoint(x: 0, y: -20) // Offset down from title
        modalContainer.addChild(contentContainer)
        
        // Create scroll container
        scrollContainer = SKNode()
        contentContainer.addChild(scrollContainer)
        
        // Enable user interaction
        self.isUserInteractionEnabled = true
        
        // Initially hidden
        self.isHidden = true
        self.alpha = 0
        
        updateResearch()
    }
    
    func show() {
        self.isHidden = false
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        self.run(fadeIn)
    }
    
    func hide() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let hideAction = SKAction.run { [weak self] in
            self?.isHidden = true
        }
        self.run(SKAction.sequence([fadeOut, hideAction]))
    }
    
    func updateResearch() {
        let modalWidth = viewSize.width * 0.9
        let width = modalWidth - 60 // Padding inside modal
        
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
        
        // Check if touching close button
        let locationInModal = touch.location(in: modalContainer)
        if closeButton.contains(locationInModal) {
            hide()
            onClose?()
            return
        }
        
        // Check if touching overlay (outside modal) - close modal
        let locationInModalForBackground = touch.location(in: modalContainer)
        
        // Get the modal background (first child of modalContainer)
        if let modalBackground = modalContainer.children.first as? SKShapeNode {
            if !modalBackground.contains(locationInModalForBackground) {
                // Touched outside modal content - close modal
                hide()
                onClose?()
                return
            }
        }
        
        lastTouchY = touch.location(in: self).y
        isScrolling = false
        
        // Check if touching a purchasable research item
        let locationInContent = touch.location(in: contentContainer)
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
            let modalHeight = viewSize.height * 0.8
            let totalHeight = CGFloat(simulator.catalog.availableResearchTree.count) * (itemHeight + spacing)
            let maxOffset = max(0, totalHeight - modalHeight + 100) // 100 for title/close button area
            scrollOffset = max(0, min(maxOffset, scrollOffset))
            
            scrollContainer.position = CGPoint(x: 0, y: scrollOffset)
            lastTouchY = currentY
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isScrolling = false
    }
}


//
//  CardsView.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

class CardsView: SKNode {
    private let simulator: Simulator
    private let viewSize: CGSize
    private var scrollContainer: SKNode!
    private var inHandSection: SKNode!
    private var playedSection: SKNode!
    private var inHandLabel: SKLabelNode!
    private var playedLabel: SKLabelNode!
    private var cardNodes: [String: SKNode] = [:] // Maps card ID to node
    private var lastTouchY: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var isScrolling: Bool = false
    private let cardHeight: CGFloat = 100
    private let spacing: CGFloat = 10
    private let sectionSpacing: CGFloat = 30
    
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
        
        // Create section labels
        inHandLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        inHandLabel.fontSize = 22
        inHandLabel.fontColor = SKColor.cyan
        inHandLabel.horizontalAlignmentMode = .left
        inHandLabel.text = "Cards in Hand"
        scrollContainer.addChild(inHandLabel)
        
        playedLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        playedLabel.fontSize = 22
        playedLabel.fontColor = SKColor.green
        playedLabel.horizontalAlignmentMode = .left
        playedLabel.text = "Played Cards"
        scrollContainer.addChild(playedLabel)
        
        // Create section containers
        inHandSection = SKNode()
        scrollContainer.addChild(inHandSection)
        
        playedSection = SKNode()
        scrollContainer.addChild(playedSection)
        
        // Enable user interaction for scrolling
        self.isUserInteractionEnabled = true
        
        updateCards()
    }
    
    func updateCards() {
        let width = viewSize.width - 40
        
        // Clear existing card nodes
        for (_, node) in cardNodes {
            node.removeFromParent()
        }
        cardNodes.removeAll()
        
        // Position section labels
        var currentY: CGFloat = 0
        
        // In Hand section
        inHandLabel.position = CGPoint(x: -width/2 + 20, y: currentY)
        currentY -= 30
        
        inHandSection.removeAllChildren()
        if simulator.state.inHand.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "Arial")
            emptyLabel.fontSize = 16
            emptyLabel.fontColor = SKColor.gray
            emptyLabel.horizontalAlignmentMode = .left
            emptyLabel.text = "No cards in hand"
            emptyLabel.position = CGPoint(x: -width/2 + 20, y: currentY)
            inHandSection.addChild(emptyLabel)
            currentY -= 30
        } else {
            for card in simulator.state.inHand {
                let cardNode = createCardNode(card: card, width: width, isPlayable: true)
                cardNode.position = CGPoint(x: 0, y: currentY)
                inHandSection.addChild(cardNode)
                cardNodes[card.id] = cardNode
                currentY -= (cardHeight + spacing)
            }
        }
        
        currentY -= sectionSpacing
        
        // Played section
        playedLabel.position = CGPoint(x: -width/2 + 20, y: currentY)
        currentY -= 30
        
        playedSection.removeAllChildren()
        if simulator.state.playedCards.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "Arial")
            emptyLabel.fontSize = 16
            emptyLabel.fontColor = SKColor.gray
            emptyLabel.horizontalAlignmentMode = .left
            emptyLabel.text = "No cards played"
            emptyLabel.position = CGPoint(x: -width/2 + 20, y: currentY)
            playedSection.addChild(emptyLabel)
        } else {
            for card in simulator.state.playedCards {
                let cardNode = createCardNode(card: card, width: width, isPlayable: false)
                cardNode.position = CGPoint(x: 0, y: currentY)
                playedSection.addChild(cardNode)
                cardNodes[card.id] = cardNode
                currentY -= (cardHeight + spacing)
            }
        }
    }
    
    private func createCardNode(card: Card, width: CGFloat, isPlayable: Bool) -> SKNode {
        let container = SKNode()
        
        // Background
        let background = SKShapeNode(rectOf: CGSize(width: width - 20, height: cardHeight))
        background.fillColor = isPlayable ? SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.9) : SKColor(white: 0.15, alpha: 0.9)
        background.strokeColor = isPlayable ? SKColor.cyan : SKColor.green
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        container.addChild(background)
        
        // Card name
        let nameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nameLabel.fontSize = 18
        nameLabel.fontColor = SKColor.white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -width/2 + 30, y: 25)
        nameLabel.text = card.name
        container.addChild(nameLabel)
        
        // Card description
        let descLabel = SKLabelNode(fontNamed: "Arial")
        descLabel.fontSize = 14
        descLabel.fontColor = SKColor.lightGray
        descLabel.horizontalAlignmentMode = .left
        descLabel.position = CGPoint(x: -width/2 + 30, y: 5)
        descLabel.text = card.description
        container.addChild(descLabel)
        
        // Effect value
        let effectLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        effectLabel.fontSize = 16
        effectLabel.fontColor = SKColor.yellow
        effectLabel.horizontalAlignmentMode = .right
        effectLabel.position = CGPoint(x: width/2 - 30, y: 0)
        
        let effectValue = Int(card.effectValue * 100)
        effectLabel.text = "+\(effectValue)%"
        container.addChild(effectLabel)
        
        // Play button for in-hand cards
        if isPlayable {
            let playLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
            playLabel.fontSize = 14
            playLabel.fontColor = SKColor.green
            playLabel.horizontalAlignmentMode = .right
            playLabel.position = CGPoint(x: width/2 - 30, y: -30)
            playLabel.text = "TAP TO PLAY"
            container.addChild(playLabel)
            
            // Store card ID for tap handling
            background.userData = ["cardId": card.id]
        }
        
        // Make interactive if playable
        container.isUserInteractionEnabled = isPlayable
        background.isUserInteractionEnabled = false
        
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchY = touch.location(in: self).y
        isScrolling = false
        
        // Check if touching a playable card
        let locationInView = touch.location(in: self)
        for (cardId, cardNode) in cardNodes {
            if cardNode.isUserInteractionEnabled {
                let locationInNode = touch.location(in: cardNode)
                if cardNode.contains(locationInNode) {
                    // Check if it's a playable card (in hand)
                    if simulator.state.inHand.contains(where: { $0.id == cardId }) {
                        if simulator.playCard(cardId: cardId) {
                            updateCards()
                        }
                        return
                    }
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
            let totalHeight = calculateTotalHeight()
            let maxOffset = max(0, totalHeight - 400)
            scrollOffset = max(0, min(maxOffset, scrollOffset))
            
            scrollContainer.position = CGPoint(x: 0, y: scrollOffset)
            lastTouchY = currentY
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isScrolling = false
    }
    
    private func calculateTotalHeight() -> CGFloat {
        let inHandCount = simulator.state.inHand.count
        let playedCount = simulator.state.playedCards.count
        let totalCards = max(1, inHandCount) + max(1, playedCount)
        return CGFloat(totalCards) * (cardHeight + spacing) + sectionSpacing + 60 // Labels and spacing
    }
}


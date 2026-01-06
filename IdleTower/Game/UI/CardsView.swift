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
    private var overlayBackground: SKShapeNode!
    private var modalContainer: SKNode!
    private var contentContainer: SKNode!
    private var scrollContainer: SKNode!
    private var inHandSection: SKNode!
    private var playedSection: SKNode!
    private var inHandLabel: SKLabelNode!
    private var playedLabel: SKLabelNode!
    private var closeButton: SKNode!
    private var cardNodes: [String: SKNode] = [:] // Maps card ID to node
    private var lastTouchY: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var isScrolling: Bool = false
    private let cardHeight: CGFloat = 100
    private let spacing: CGFloat = 10
    private let sectionSpacing: CGFloat = 30
    
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
        titleLabel.fontColor = SKColor.cyan
        titleLabel.text = "Cards"
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
        
        // Enable user interaction
        self.isUserInteractionEnabled = true
        
        // Initially hidden
        self.isHidden = true
        self.alpha = 0
        
        updateCards()
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
    
    func updateCards() {
        let modalWidth = viewSize.width * 0.9
        let width = modalWidth - 60 // Padding inside modal
        
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
        
        // Check if touching close button
        let locationInModal = touch.location(in: modalContainer)
        if closeButton.contains(locationInModal) {
            hide()
            onClose?()
            return
        }
        
        // Check if touching overlay (outside modal) - close modal
        let locationInView = touch.location(in: self)
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
        
        // Check if touching a playable card
        let locationInContent = touch.location(in: contentContainer)
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
            let modalHeight = viewSize.height * 0.8
            let contentHeight = calculateTotalHeight()
            let maxOffset = max(0, contentHeight - modalHeight + 100) // 100 for title/close button area
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


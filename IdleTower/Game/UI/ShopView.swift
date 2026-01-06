//
//  ShopView.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

class ShopView: SKNode {
    private let simulator: Simulator
    private var scrollContainer: SKNode!
    private var shopItems: [ShopItemNode] = []
    private var lastTouchY: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var isScrolling: Bool = false
    private let itemHeight: CGFloat = 90
    private let spacing: CGFloat = 10
    
    init(simulator: Simulator, size: CGSize) {
        self.simulator = simulator
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
        
        // Create shop items for each producer
        let width = size.width - 40
        var yPosition: CGFloat = 0
        
        for producerDef in simulator.catalog.producers {
            let item = ShopItemNode(producerDef: producerDef, simulator: simulator, width: width)
            item.position = CGPoint(x: 0, y: yPosition)
            item.onPurchase = { [weak self] in
                self?.updateAllItems()
            }
            scrollContainer.addChild(item)
            shopItems.append(item)
            
            yPosition -= (itemHeight + spacing)
        }
        
        // Enable user interaction for scrolling
        self.isUserInteractionEnabled = true
    }
    
    func updateAllItems() {
        for item in shopItems {
            item.updateDisplay()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchY = touch.location(in: self).y
        isScrolling = false
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
            let minOffset: CGFloat = 0
            let maxOffset = max(0, CGFloat(shopItems.count) * (itemHeight + spacing) - 400)
            scrollOffset = max(minOffset, min(maxOffset, scrollOffset))
            
            scrollContainer.position = CGPoint(x: 0, y: scrollOffset)
            lastTouchY = currentY
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If we weren't scrolling, touches will naturally propagate to child nodes
        // ShopItemNode has isUserInteractionEnabled = true, so it will receive touchesEnded
        isScrolling = false
    }
}


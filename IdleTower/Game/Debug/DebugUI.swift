//
//  DebugUI.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import SpriteKit
import IdleTowerCore

/// Debug overlay UI for testing and debugging
final class DebugUI {
    private let controller: DebugController
    private let scene: SKScene
    private var containerNode: SKNode?
    private var isVisible: Bool = false
    private var materialsLabel: SKLabelNode?
    private var energyLabel: SKLabelNode?
    private var dataLabel: SKLabelNode?
    
    // UI Constants
    private let buttonHeight: CGFloat = 40
    private let buttonSpacing: CGFloat = 10
    private let panelPadding: CGFloat = 20
    private let panelWidth: CGFloat = 350
    
    init(scene: SKScene, controller: DebugController) {
        self.scene = scene
        self.controller = controller
    }
    
    /// Toggle debug UI visibility
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    /// Show the debug UI overlay
    func show() {
        guard !isVisible else { return }
        
        let container = SKNode()
        container.zPosition = 1000
        container.name = "DebugUI"
        container.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        
        // Background panel (increased height to accommodate resource display)
        let background = SKShapeNode(rectOf: CGSize(width: panelWidth, height: 600))
        background.fillColor = SKColor.black.withAlphaComponent(0.8)
        background.strokeColor = SKColor.white
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 0)
        container.addChild(background)
        
        var yOffset: CGFloat = 300 - panelPadding // background.frame.height / 2 - panelPadding
        
        // Title
        let titleLabel = SKLabelNode(text: "DEBUG CONTROLS")
        titleLabel.fontName = "Arial-BoldMT"
        titleLabel.fontSize = 20
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: 0, y: yOffset)
        container.addChild(titleLabel)
        yOffset -= 40
        
        // Current Resources Section
        let resourcesLabel = SKLabelNode(text: "Current Resources:")
        resourcesLabel.fontName = "Arial-BoldMT"
        resourcesLabel.fontSize = 16
        resourcesLabel.fontColor = SKColor.white
        resourcesLabel.horizontalAlignmentMode = .left
        resourcesLabel.position = CGPoint(x: -panelWidth / 2 + panelPadding, y: yOffset)
        container.addChild(resourcesLabel)
        yOffset -= 30
        
        // Materials display
        let materialsLabel = SKLabelNode(text: "Materials: 0.0")
        materialsLabel.fontName = "Arial"
        materialsLabel.fontSize = 14
        materialsLabel.fontColor = SKColor.orange
        materialsLabel.horizontalAlignmentMode = .left
        materialsLabel.position = CGPoint(x: -panelWidth / 2 + panelPadding + 5, y: yOffset)
        materialsLabel.name = "resource_materials"
        container.addChild(materialsLabel)
        self.materialsLabel = materialsLabel
        yOffset -= 25
        
        // Energy display
        let energyLabel = SKLabelNode(text: "Energy: 0.0")
        energyLabel.fontName = "Arial"
        energyLabel.fontSize = 14
        energyLabel.fontColor = SKColor.yellow
        energyLabel.horizontalAlignmentMode = .left
        energyLabel.position = CGPoint(x: -panelWidth / 2 + panelPadding + 5, y: yOffset)
        energyLabel.name = "resource_energy"
        container.addChild(energyLabel)
        self.energyLabel = energyLabel
        yOffset -= 25
        
        // Data display
        let dataLabel = SKLabelNode(text: "Data: 0.0")
        dataLabel.fontName = "Arial"
        dataLabel.fontSize = 14
        dataLabel.fontColor = SKColor.cyan
        dataLabel.horizontalAlignmentMode = .left
        dataLabel.position = CGPoint(x: -panelWidth / 2 + panelPadding + 5, y: yOffset)
        dataLabel.name = "resource_data"
        container.addChild(dataLabel)
        self.dataLabel = dataLabel
        yOffset -= 35
        
        // Time Scale Section
        let timeScaleLabel = SKLabelNode(text: "Time Scale:")
        timeScaleLabel.fontName = "Arial"
        timeScaleLabel.fontSize = 16
        timeScaleLabel.fontColor = SKColor.white
        timeScaleLabel.horizontalAlignmentMode = .left
        timeScaleLabel.position = CGPoint(x: -panelWidth / 2 + panelPadding, y: yOffset)
        container.addChild(timeScaleLabel)
        yOffset -= 30
        
        // Time scale buttons
        let timeScales: [(label: String, value: Double)] = [("1x", 1.0), ("10x", 10.0), ("100x", 100.0)]
        let buttonWidth = (panelWidth - panelPadding * 2 - buttonSpacing * 2) / 3
        
        for (index, scale) in timeScales.enumerated() {
            let button = createButton(
                text: scale.label,
                width: buttonWidth,
                position: CGPoint(
                    x: -panelWidth / 2 + panelPadding + buttonWidth / 2 + CGFloat(index) * (buttonWidth + buttonSpacing),
                    y: yOffset
                )
            )
            button.name = "timeScale_\(scale.value)"
            container.addChild(button)
        }
        yOffset -= 50
        
        // Grant Resources Section
        let grantLabel = SKLabelNode(text: "Grant Resources:")
        grantLabel.fontName = "Arial"
        grantLabel.fontSize = 16
        grantLabel.fontColor = SKColor.white
        grantLabel.horizontalAlignmentMode = .left
        grantLabel.position = CGPoint(x: -panelWidth / 2 + panelPadding, y: yOffset)
        container.addChild(grantLabel)
        yOffset -= 30
        
        // Resource grant buttons
        let resources: [(type: ResourceType, label: String, amount: Double)] = [
            (.materials, "Mats +100", 100),
            (.materials, "Mats +1000", 1000),
            (.energy, "Energy +10", 10),
            (.energy, "Energy +100", 100),
            (.data, "Data +10", 10),
            (.data, "Data +100", 100)
        ]
        
        for (index, resource) in resources.enumerated() {
            let row = index / 2
            let col = index % 2
            let button = createButton(
                text: resource.label,
                width: (panelWidth - panelPadding * 2 - buttonSpacing) / 2,
                position: CGPoint(
                    x: -panelWidth / 2 + panelPadding + (panelWidth - panelPadding * 2 - buttonSpacing) / 4 + CGFloat(col) * ((panelWidth - panelPadding * 2 - buttonSpacing) / 2 + buttonSpacing),
                    y: yOffset - CGFloat(row) * (buttonHeight + buttonSpacing)
                )
            )
            button.name = "grant_\(resource.type.rawValue)_\(resource.amount)"
            container.addChild(button)
        }
        yOffset -= CGFloat((resources.count + 1) / 2) * (buttonHeight + buttonSpacing) + 20
        
        // Dump State Button
        let dumpButton = createButton(
            text: "Dump State to Console",
            width: panelWidth - panelPadding * 2,
            position: CGPoint(x: 0, y: yOffset)
        )
        dumpButton.name = "dumpState"
        container.addChild(dumpButton)
        yOffset -= 50
        
        // Close Button
        let closeButton = createButton(
            text: "Close Debug",
            width: panelWidth - panelPadding * 2,
            position: CGPoint(x: 0, y: yOffset)
        )
        closeButton.name = "closeDebug"
        container.addChild(closeButton)
        
        scene.addChild(container)
        containerNode = container
        isVisible = true
        
        // Initial resource update
        updateResources()
    }
    
    /// Hide the debug UI overlay
    func hide() {
        containerNode?.removeFromParent()
        containerNode = nil
        materialsLabel = nil
        energyLabel = nil
        dataLabel = nil
        isVisible = false
    }
    
    /// Update resource display labels
    func updateResources() {
        let state = controller.getState()
        // Format numbers to prevent very long strings
        let formatMaterials = state.materials >= 1000 ? String(format: "Materials: %.2f", state.materials) : String(format: "Materials: %.1f", state.materials)
        let formatEnergy = state.energy >= 1000 ? String(format: "Energy: %.2f", state.energy) : String(format: "Energy: %.1f", state.energy)
        let formatData = state.data >= 1000 ? String(format: "Data: %.2f", state.data) : String(format: "Data: %.1f", state.data)
        materialsLabel?.text = formatMaterials
        energyLabel?.text = formatEnergy
        dataLabel?.text = formatData
    }
    
    /// Handle touch events on debug UI
    /// - Parameter location: The touch location in scene coordinates
    /// - Returns: True if the touch was handled by debug UI
    @discardableResult
    func handleTouch(at location: CGPoint) -> Bool {
        guard containerNode != nil else { return false }
        
        let nodes = scene.nodes(at: location)
        for node in nodes {
            guard let name = node.name else { continue }
            
            if name == "closeDebug" {
                hide()
                return true
            } else if name == "dumpState" {
                let stateJSON = controller.dumpState()
                print("=== GAME STATE DUMP ===")
                print(stateJSON)
                print("======================")
                return true
            } else if name.hasPrefix("timeScale_") {
                let scaleString = name.replacingOccurrences(of: "timeScale_", with: "")
                if let scale = Double(scaleString) {
                    controller.setTimeScale(scale)
                    updateTimeScaleButtons(selectedScale: scale)
                    return true
                }
            } else if name.hasPrefix("grant_") {
                let parts = name.replacingOccurrences(of: "grant_", with: "").split(separator: "_")
                if parts.count == 2,
                   let resourceType = ResourceType(rawValue: String(parts[0])),
                   let amount = Double(String(parts[1])) {
                    controller.grantResource(resourceType, amount: amount)
                    updateResources()
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Create a button node
    private func createButton(text: String, width: CGFloat, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        
        let background = SKShapeNode(rectOf: CGSize(width: width, height: buttonHeight))
        background.fillColor = SKColor.darkGray
        background.strokeColor = SKColor.white
        background.lineWidth = 1
        container.addChild(background)
        
        let label = SKLabelNode(text: text)
        label.fontName = "Arial"
        label.fontSize = 14
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        return container
    }
    
    /// Update time scale button appearance to show selected state
    private func updateTimeScaleButtons(selectedScale: Double) {
        guard let container = containerNode else { return }
        
        container.enumerateChildNodes(withName: "timeScale_*") { node, _ in
            if let shapeNode = node.children.first as? SKShapeNode {
                if let name = node.name, name == "timeScale_\(selectedScale)" {
                    shapeNode.fillColor = SKColor.green.withAlphaComponent(0.5)
                } else {
                    shapeNode.fillColor = SKColor.darkGray
                }
            }
        }
    }
}


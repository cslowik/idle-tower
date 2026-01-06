//
//  Simulator.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public enum ResourceType: String, CaseIterable {
    case materials
    case energy
    case data
}

public final class Simulator {
    public private(set) var state: GameState
    public let catalog: Catalog
    
    /// Time scale multiplier for simulation speed (1x, 10x, 100x)
    public var timeScale: Double = 1.0

    public init(state: GameState = GameState(), catalog: Catalog = .demo) {
        self.state = state
        self.catalog = catalog
    }

    public func tick(dt: TimeInterval) {
        // Apply time scale multiplier
        let scaledDt = dt * timeScale
        
        // production
        for def in catalog.producers {
            let count = state.producers[def.id, default: 0]
            let production = def.baseOutput
            state.materials += Double(count) * production.materials * scaledDt
            // Energy is a capacity limit, not accumulated - only Materials and Data accumulate
            state.data += Double(count) * production.data * scaledDt
        }
        // Update energy capacity (sum of all generator capacities)
        state.energy = energyCapacity()
        state.lastUpdate = Date()
    }
    
    /// Calculates total energy capacity from all generators
    public func energyCapacity() -> Double {
        var totalCapacity: Double = 0
        for def in catalog.producers {
            let count = state.producers[def.id, default: 0]
            // Energy output represents capacity per unit
            totalCapacity += Double(count) * def.baseOutput.energy
        }
        return totalCapacity
    }

    public func buyProducer(id: String) -> Bool {
        guard let def = catalog.producers.first(where: { $0.id == id }) else { return false }

        let owned = state.producers[id, default: 0]
        let cost = Economy.cost(base: def.baseCost, owned: owned)

        guard state.materials >= cost.materials else { return false }
        // Check energy capacity (not accumulated energy) for energy costs
        guard energyCapacity() >= cost.energy else { return false }
        guard state.data >= cost.data else { return false }

        state.materials -= cost.materials
        state.data -= cost.data
        state.producers[id] = owned + 1
        // Update energy capacity after purchase
        state.energy = energyCapacity()
        return true
    }

    public func producerCost(id: String) -> ResourceCost {
        guard let def = catalog.producers.first(where: { $0.id == id }) else {
            return ResourceCost(materials: .infinity, energy: .infinity, data: .infinity)
        }
        let owned = state.producers[id, default: 0]
        return Economy.cost(base: def.baseCost, owned: owned)
    }
    
    /// Save the current game state to a file
    /// - Parameter fileURL: The URL where the state should be saved
    /// - Returns: True if save succeeded, false otherwise
    public func save(to fileURL: URL) -> Bool {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            try data.write(to: fileURL, options: .atomic)
            return true
        } catch {
            print("Failed to save game state: \(error)")
            return false
        }
    }
    
    /// Load game state from a file
    /// - Parameter fileURL: The URL where the state should be loaded from
    /// - Returns: True if load succeeded, false otherwise
    public func load(from fileURL: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loadedState = try decoder.decode(GameState.self, from: data)
            self.state = loadedState
            return true
        } catch {
            print("Failed to load game state: \(error)")
            return false
        }
    }
    
    /// Debug method to grant resources
    /// - Parameters:
    ///   - resource: The type of resource to grant
    ///   - amount: The amount to grant
    public func grant(resource: ResourceType, amount: Double) {
        switch resource {
        case .materials:
            state.materials += amount
        case .energy:
            // Energy is capacity, so we can't directly grant it, but we can add a temporary generator
            // For debug purposes, we'll just increase the energy capacity directly
            state.energy += amount
        case .data:
            state.data += amount
        }
    }
    
    /// Debug method to dump current game state as JSON string
    /// - Returns: JSON string representation of the current game state, or error message if encoding fails
    public func dumpState() -> String {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(state)
            if let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            } else {
                return "Failed to convert state to string"
            }
        } catch {
            return "Failed to encode game state: \(error)"
        }
    }
    
    // MARK: - Card Methods
    
    /// Generates a random card based on prestige level and available CardDefs
    /// Higher prestige levels may unlock more powerful cards or increase effect values
    /// - Returns: A randomly generated Card instance, or nil if no CardDefs are available
    private func generateRandomCard() -> Card? {
        guard !catalog.cardDefs.isEmpty else { return nil }
        
        // Select a random CardDef from available templates
        let randomIndex = Int.random(in: 0..<catalog.cardDefs.count)
        let cardDef = catalog.cardDefs[randomIndex]
        
        // Generate unique card ID
        let cardId = UUID().uuidString
        
        // Scale effect value based on prestige level (higher prestige = stronger effects)
        // Base effect value is multiplied by (1 + prestige * 0.1), so prestige 10 = 2x effect
        let prestigeMultiplier = 1.0 + (Double(state.prestige) * 0.1)
        let scaledEffectValue = cardDef.effectValue * prestigeMultiplier
        
        // Create card instance from CardDef
        return Card(
            id: cardId,
            defId: cardDef.id,
            name: cardDef.name,
            description: cardDef.description,
            effectType: cardDef.effectType,
            effectValue: scaledEffectValue
        )
    }
    
    /// Awards a random card to the player's hand
    /// Card is generated on-the-fly based on prestige level and CardDef templates
    /// - Returns: True if card was successfully awarded, false otherwise
    @discardableResult
    public func awardRandomCard() -> Bool {
        guard let card = generateRandomCard() else { return false }
        state.inHand.append(card)
        return true
    }
    
    /// Plays a card from the player's hand, moving it to playedCards
    /// - Parameter cardId: The unique ID of the card to play
    /// - Returns: True if card was successfully played, false if card not found in hand
    public func playCard(cardId: String) -> Bool {
        guard let index = state.inHand.firstIndex(where: { $0.id == cardId }) else {
            return false
        }
        
        let card = state.inHand.remove(at: index)
        state.playedCards.append(card)
        return true
    }
    
    // MARK: - Research Methods
    
    /// Purchases a research item using Data
    /// Validates prerequisites and available Data before purchasing
    /// - Parameter researchId: The ID of the research to purchase
    /// - Returns: True if research was successfully purchased, false otherwise
    public func buyResearch(researchId: String) -> Bool {
        // Find the research definition
        guard let researchDef = catalog.availableResearchTree.first(where: { $0.id == researchId }) else {
            return false
        }
        
        // Check if already researched
        guard !state.researchedTech.contains(researchId) else {
            return false
        }
        
        // Check prerequisites
        for prerequisiteId in researchDef.prerequisites {
            guard state.researchedTech.contains(prerequisiteId) else {
                return false
            }
        }
        
        // Check if player has enough Data
        guard state.data >= researchDef.cost else {
            return false
        }
        
        // Purchase the research
        state.data -= researchDef.cost
        state.researchedTech.append(researchId)
        return true
    }
    
    /// Gets the research definition for a given research ID
    /// - Parameter researchId: The ID of the research
    /// - Returns: The ResearchDef if found, nil otherwise
    public func researchDef(id researchId: String) -> ResearchDef? {
        return catalog.availableResearchTree.first(where: { $0.id == researchId })
    }
    
    /// Checks if a research item is available for purchase (prerequisites met, not already researched)
    /// - Parameter researchId: The ID of the research to check
    /// - Returns: True if research can be purchased, false otherwise
    public func canBuyResearch(researchId: String) -> Bool {
        guard let researchDef = catalog.availableResearchTree.first(where: { $0.id == researchId }) else {
            return false
        }
        
        // Check if already researched
        if state.researchedTech.contains(researchId) {
            return false
        }
        
        // Check prerequisites
        for prerequisiteId in researchDef.prerequisites {
            if !state.researchedTech.contains(prerequisiteId) {
                return false
            }
        }
        
        // Check if player has enough Data
        return state.data >= researchDef.cost
    }
}


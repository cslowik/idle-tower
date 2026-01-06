//
//  Simulator.swift
//  IdleTowerCore
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation

public final class Simulator {
    public private(set) var state: GameState
    public let catalog: Catalog

    public init(state: GameState = GameState(), catalog: Catalog = .demo) {
        self.state = state
        self.catalog = catalog
    }

    public func tick(dt: TimeInterval) {
        // production
        for def in catalog.producers {
            let count = state.producers[def.id, default: 0]
            let production = def.baseOutput
            state.materials += Double(count) * production.materials * dt
            // Energy is a capacity limit, not accumulated - only Materials and Data accumulate
            state.data += Double(count) * production.data * dt
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
}


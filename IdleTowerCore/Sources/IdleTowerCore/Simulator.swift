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
            state.energy += Double(count) * production.energy * dt
            state.data += Double(count) * production.data * dt
        }
        state.lastUpdate = Date()
    }

    public func buyProducer(id: String) -> Bool {
        guard let def = catalog.producers.first(where: { $0.id == id }) else { return false }

        let owned = state.producers[id, default: 0]
        let cost = Economy.cost(base: def.baseCost, owned: owned)

        guard state.materials >= cost.materials else { return false }
        guard state.energy >= cost.energy else { return false }
        guard state.data >= cost.data else { return false }

        state.materials -= cost.materials
        state.energy -= cost.energy
        state.data -= cost.data
        state.producers[id] = owned + 1
        return true
    }

    public func producerCost(id: String) -> ResourceCost {
        guard let def = catalog.producers.first(where: { $0.id == id }) else {
            return ResourceCost(materials: .infinity, energy: .infinity, data: .infinity)
        }
        let owned = state.producers[id, default: 0]
        return Economy.cost(base: def.baseCost, owned: owned)
    }
}


//
//  DebugController.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation
import IdleTowerCore

/// Handles debug commands for the simulator
final class DebugController {
    private let simulator: Simulator
    
    init(simulator: Simulator) {
        self.simulator = simulator
    }
    
    /// Set the time scale multiplier
    /// - Parameter scale: The time scale multiplier (1.0, 10.0, or 100.0)
    func setTimeScale(_ scale: Double) {
        simulator.timeScale = scale
    }
    
    /// Grant resources to the player
    /// - Parameters:
    ///   - resource: The type of resource to grant
    ///   - amount: The amount to grant
    func grantResource(_ resource: ResourceType, amount: Double) {
        simulator.grant(resource: resource, amount: amount)
    }
    
    /// Dump the current game state as a JSON string
    /// - Returns: JSON string representation of the game state
    func dumpState() -> String {
        return simulator.dumpState()
    }
    
    /// Get the current time scale
    /// - Returns: Current time scale multiplier
    func getTimeScale() -> Double {
        return simulator.timeScale
    }
    
    /// Get the current game state
    /// - Returns: Current game state
    func getState() -> GameState {
        return simulator.state
    }
}


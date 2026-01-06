//
//  OfflineProgress.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation
import IdleTowerCore

/// Calculates and applies offline progress for the game
enum OfflineProgress {
    /// Maximum offline progress time (1 hour)
    static let maxOfflineTime: TimeInterval = 3600 // 1 hour in seconds
    
    /// Calculate elapsed time since last update, capped at maxOfflineTime
    /// - Parameter lastUpdate: The date of the last update
    /// - Returns: The elapsed time, capped at maxOfflineTime
    static func calculateElapsedTime(since lastUpdate: Date) -> TimeInterval {
        let elapsed = Date().timeIntervalSince(lastUpdate)
        return min(elapsed, maxOfflineTime)
    }
    
    /// Apply offline progress to a simulator by simulating the elapsed time
    /// - Parameter simulator: The Simulator instance to apply progress to
    /// - Returns: The amount of time that was simulated
    static func apply(to simulator: Simulator) -> TimeInterval {
        let elapsed = calculateElapsedTime(since: simulator.state.lastUpdate)
        
        if elapsed > 0 {
            // Simulate progress using tick intervals
            // Use 0.1 second intervals for accuracy
            let tickInterval: TimeInterval = 0.1
            var remaining = elapsed
            
            while remaining > 0 {
                let dt = min(remaining, tickInterval)
                simulator.tick(dt: dt)
                remaining -= dt
            }
        }
        
        return elapsed
    }
}


//
//  main.swift
//  TestHarness
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation
import IdleTowerCore

// TEMPORARY: For testing producers - grant initial resources and buy some
var testState = GameState()
testState.materials = 1000  // Enough to buy several producers
let simulator = Simulator(state: testState)

// Buy some producers to test production
print("Buying test producers...")
simulator.buyProducer(id: "miner")  // Costs 10 materials
simulator.buyProducer(id: "miner")  // Costs 11.5 materials (1.15x)
simulator.buyProducer(id: "miner")  // Costs 13.225 materials
simulator.buyProducer(id: "generator")  // Costs 50 materials
print("Initial state: Materials=\(simulator.state.materials), Energy=\(simulator.state.energy), Data=\(simulator.state.data)")
print("Producers: \(simulator.state.producers)")
print("")

let startTime = Date()
let duration: TimeInterval = 120 // 2 minutes
let tickInterval: TimeInterval = 0.1
let printInterval: TimeInterval = 1.0

var lastPrintElapsed: TimeInterval = 0

print("Starting simulator test run for \(duration) seconds...")
print("Tick interval: \(tickInterval)s, Print interval: \(printInterval)s")
print(String(repeating: "=", count: 60))

while Date().timeIntervalSince(startTime) < duration {
    simulator.tick(dt: tickInterval)
    
    let elapsed = Date().timeIntervalSince(startTime)
    if elapsed - lastPrintElapsed >= printInterval {
        let state = simulator.state
        print(String(format: "t=%.1fs | Materials: %.2f | Energy: %.2f | Data: %.2f | Producers: %@",
                     elapsed,
                     state.materials,
                     state.energy,
                     state.data,
                     state.producers.map { "\($0.key):\($0.value)" }.joined(separator: ", ")))
        lastPrintElapsed = elapsed
    }
    
    // Small sleep to prevent CPU spinning
    Thread.sleep(forTimeInterval: tickInterval)
}

print(String(repeating: "=", count: 60))
print("Test run complete!")
let finalState = simulator.state
print("Final state:")
print("  Materials: \(finalState.materials)")
print("  Energy: \(finalState.energy)")
print("  Data: \(finalState.data)")
print("  Producers: \(finalState.producers)")


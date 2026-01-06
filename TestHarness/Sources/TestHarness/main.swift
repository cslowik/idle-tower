//
//  main.swift
//  TestHarness
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation
import IdleTowerCore

// Test configuration
let runSimulationTest = true
let runPersistenceTests = true
let runOfflineProgressTests = true

// MARK: - Test 1: Save/Load Functionality

func testSaveLoad() {
    print("\n" + String(repeating: "=", count: 70))
    print("TEST 1: Save/Load Functionality")
    print(String(repeating: "=", count: 70))
    
    // Setup initial state
    var initialState = GameState()
    initialState.materials = 500.123
    initialState.energy = 100.456
    initialState.data = 50.789
    initialState.producers = ["miner": 3, "generator": 2, "analyzer": 1]
    initialState.lastUpdate = Date()
    
    let simulator1 = Simulator(state: initialState)
    
    // Make some changes
    _ = simulator1.buyProducer(id: "miner")
    let materialsAfterPurchase = simulator1.state.materials
    let producersAfterPurchase = simulator1.state.producers
    
    print("\n📝 Initial State:")
    print("  Materials: \(initialState.materials)")
    print("  Energy: \(initialState.energy)")
    print("  Data: \(initialState.data)")
    print("  Producers: \(initialState.producers)")
    print("  Last Update: \(initialState.lastUpdate)")
    
    print("\n💰 After Purchase:")
    print("  Materials: \(materialsAfterPurchase)")
    print("  Producers: \(producersAfterPurchase)")
    
    // Create temporary file URL
    let tempDir = FileManager.default.temporaryDirectory
    let testFileURL = tempDir.appendingPathComponent("test_gamestate_\(UUID().uuidString).json")
    
    // Test Save
    print("\n💾 Testing Save...")
    let saveSuccess = simulator1.save(to: testFileURL)
    if saveSuccess {
        print("✅ Save successful")
        print("   File: \(testFileURL.path)")
        
        // Verify file exists
        if FileManager.default.fileExists(atPath: testFileURL.path) {
            print("✅ File exists on disk")
            
            // Check file size
            if let attributes = try? FileManager.default.attributesOfItem(atPath: testFileURL.path),
               let fileSize = attributes[.size] as? Int64 {
                print("   File size: \(fileSize) bytes")
            }
        } else {
            print("❌ File not found on disk")
        }
    } else {
        print("❌ Save failed")
        return
    }
    
    // Create a new simulator to test loading (can't modify state directly)
    var modifiedState = GameState()
    modifiedState.materials = 99999
    modifiedState.producers = [:]
    let simulator2 = Simulator(state: modifiedState)
    
    print("\n🔀 Modified State (before load):")
    print("  Materials: \(simulator2.state.materials)")
    print("  Producers: \(simulator2.state.producers)")
    
    // Test Load
    print("\n📂 Testing Load...")
    let loadSuccess = simulator2.load(from: testFileURL)
    if loadSuccess {
        print("✅ Load successful")
        
        print("\n📊 Loaded State:")
        print("  Materials: \(simulator2.state.materials)")
        print("  Energy: \(simulator2.state.energy)")
        print("  Data: \(simulator2.state.data)")
        print("  Producers: \(simulator2.state.producers)")
        print("  Last Update: \(simulator2.state.lastUpdate)")
        
        // Verify all fields match
        let materialsMatch = abs(simulator2.state.materials - materialsAfterPurchase) < 0.01
        let energyMatch = abs(simulator2.state.energy - initialState.energy) < 0.01
        let dataMatch = abs(simulator2.state.data - initialState.data) < 0.01
        let producersMatch = simulator2.state.producers == producersAfterPurchase
        
        print("\n✅ Verification Results:")
        print("  Materials match: \(materialsMatch ? "✅" : "❌") (expected: \(materialsAfterPurchase), got: \(simulator2.state.materials))")
        print("  Energy match: \(energyMatch ? "✅" : "❌") (expected: \(initialState.energy), got: \(simulator2.state.energy))")
        print("  Data match: \(dataMatch ? "✅" : "❌") (expected: \(initialState.data), got: \(simulator2.state.data))")
        print("  Producers match: \(producersMatch ? "✅" : "❌")")
        
        if materialsMatch && energyMatch && dataMatch && producersMatch {
            print("\n🎉 All fields match! Save/Load test PASSED")
        } else {
            print("\n❌ Some fields don't match! Save/Load test FAILED")
        }
    } else {
        print("❌ Load failed")
    }
    
    // Cleanup
    try? FileManager.default.removeItem(at: testFileURL)
    print("\n🧹 Cleaned up test file")
}

// MARK: - Test 2: JSON Encoding/Decoding Verification

func testJSONEncoding() {
    print("\n" + String(repeating: "=", count: 70))
    print("TEST 2: JSON Encoding/Decoding Verification")
    print(String(repeating: "=", count: 70))
    
    // Create state with various values to test encoding
    var testState = GameState()
    testState.materials = 123.456789
    testState.energy = 987.654321
    testState.data = 42.1337
    testState.producers = ["miner": 5, "generator": 3, "analyzer": 2]
    
    // Set a specific date to test date encoding
    let testDate = Date(timeIntervalSince1970: 1704067200) // Fixed timestamp
    testState.lastUpdate = testDate
    
    print("\n📝 Original State:")
    print("  Materials: \(testState.materials)")
    print("  Energy: \(testState.energy)")
    print("  Data: \(testState.data)")
    print("  Producers: \(testState.producers)")
    print("  Last Update: \(testState.lastUpdate)")
    
    // Encode to JSON
    print("\n🔄 Encoding to JSON...")
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    guard let jsonData = try? encoder.encode(testState) else {
        print("❌ Encoding failed")
        return
    }
    
    print("✅ Encoding successful")
    print("   JSON size: \(jsonData.count) bytes")
    
    // Print JSON string (first 500 chars)
    if let jsonString = String(data: jsonData, encoding: .utf8) {
        let preview = String(jsonString.prefix(500))
        print("\n📄 JSON Preview:")
        print(preview + (jsonString.count > 500 ? "..." : ""))
    }
    
    // Decode from JSON
    print("\n🔄 Decoding from JSON...")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    guard let decodedState = try? decoder.decode(GameState.self, from: jsonData) else {
        print("❌ Decoding failed")
        return
    }
    
    print("✅ Decoding successful")
    
    print("\n📊 Decoded State:")
    print("  Materials: \(decodedState.materials)")
    print("  Energy: \(decodedState.energy)")
    print("  Data: \(decodedState.data)")
    print("  Producers: \(decodedState.producers)")
    print("  Last Update: \(decodedState.lastUpdate)")
    
    // Verify all fields
    let materialsMatch = abs(decodedState.materials - testState.materials) < 0.000001
    let energyMatch = abs(decodedState.energy - testState.energy) < 0.000001
    let dataMatch = abs(decodedState.data - testState.data) < 0.000001
    let producersMatch = decodedState.producers == testState.producers
    let dateMatch = abs(decodedState.lastUpdate.timeIntervalSince1970 - testState.lastUpdate.timeIntervalSince1970) < 1.0
    
    print("\n✅ Field Verification:")
    print("  Materials: \(materialsMatch ? "✅" : "❌") (precision check)")
    print("  Energy: \(energyMatch ? "✅" : "❌") (precision check)")
    print("  Data: \(dataMatch ? "✅" : "❌") (precision check)")
    print("  Producers: \(producersMatch ? "✅" : "❌")")
    print("  Date: \(dateMatch ? "✅" : "❌") (within 1 second)")
    
    // Test date encoding format
    print("\n📅 Date Encoding Test:")
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let dateString = dateFormatter.string(from: testState.lastUpdate)
    print("  ISO8601 format: \(dateString)")
    
    if let decodedDate = dateFormatter.date(from: dateString) {
        let dateRoundTrip = abs(decodedDate.timeIntervalSince1970 - testState.lastUpdate.timeIntervalSince1970) < 0.001
        print("  Date round-trip: \(dateRoundTrip ? "✅" : "❌")")
    }
    
    if materialsMatch && energyMatch && dataMatch && producersMatch && dateMatch {
        print("\n🎉 All fields preserved! JSON encoding test PASSED")
    } else {
        print("\n❌ Some fields not preserved! JSON encoding test FAILED")
    }
}

// MARK: - Test 3: Offline Progress Calculation

func testOfflineProgress() {
    print("\n" + String(repeating: "=", count: 70))
    print("TEST 3: Offline Progress Calculation")
    print(String(repeating: "=", count: 70))
    
    let maxOfflineTime: TimeInterval = 3600 // 1 hour
    
    // Helper function to calculate elapsed time (mimicking OfflineProgress logic)
    func calculateElapsedTime(since lastUpdate: Date) -> TimeInterval {
        let elapsed = Date().timeIntervalSince(lastUpdate)
        return min(elapsed, maxOfflineTime)
    }
    
    // Helper function to apply offline progress (mimicking OfflineProgress logic)
    func applyOfflineProgress(to simulator: Simulator) -> TimeInterval {
        let elapsed = calculateElapsedTime(since: simulator.state.lastUpdate)
        
        if elapsed > 0 {
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
    
    // Test 3a: Time calculation and capping
    print("\n⏱️  Test 3a: Time Calculation and Capping")
    
    let now = Date()
    let testCases: [(name: String, offset: TimeInterval, expectedCapped: TimeInterval)] = [
        ("30 minutes ago", -1800, 1800),
        ("1 hour ago", -3600, 3600),
        ("2 hours ago", -7200, 3600), // Should cap at 1 hour
        ("5 hours ago", -18000, 3600), // Should cap at 1 hour
        ("Just now", -10, 10),
    ]
    
    for testCase in testCases {
        let testDate = now.addingTimeInterval(testCase.offset)
        let elapsed = calculateElapsedTime(since: testDate)
        let passed = abs(elapsed - testCase.expectedCapped) < 1.0 // Allow 1 second tolerance
        
        print("  \(testCase.name):")
        print("    Elapsed: \(Int(elapsed))s, Expected: \(Int(testCase.expectedCapped))s")
        print("    \(passed ? "✅" : "❌")")
    }
    
    // Test 3b: Offline progress application
    print("\n📈 Test 3b: Offline Progress Application")
    
    // Create state with producers
    var stateWithProducers = GameState()
    stateWithProducers.materials = 100
    stateWithProducers.producers = ["miner": 2] // 2 miners producing 1 material/sec each = 2 materials/sec
    stateWithProducers.lastUpdate = Date().addingTimeInterval(-1800) // 30 minutes ago
    
    let simulator = Simulator(state: stateWithProducers)
    let materialsBefore = simulator.state.materials
    
    print("\n📊 State Before Offline Progress:")
    print("  Materials: \(materialsBefore)")
    print("  Producers: \(simulator.state.producers)")
    print("  Last Update: \(simulator.state.lastUpdate)")
    print("  Time Since Update: \(Int(Date().timeIntervalSince(simulator.state.lastUpdate)))s")
    
    // Apply offline progress
    let simulatedTime = applyOfflineProgress(to: simulator)
    let materialsAfter = simulator.state.materials
    let expectedIncrease = simulatedTime * 2.0 // 2 miners * 1 material/sec
    
    print("\n📊 State After Offline Progress:")
    print("  Materials: \(materialsAfter)")
    print("  Simulated Time: \(Int(simulatedTime))s")
    print("  Expected Increase: ~\(Int(expectedIncrease)) materials")
    print("  Actual Increase: \(Int(materialsAfter - materialsBefore)) materials")
    
    let increaseMatch = abs((materialsAfter - materialsBefore) - expectedIncrease) < 10.0 // Allow 10 material tolerance
    
    print("\n✅ Progress Verification:")
    print("  Increase matches expected: \(increaseMatch ? "✅" : "❌")")
    
    // Test 3c: Cap enforcement (2 hours offline should only progress 1 hour)
    print("\n⏰ Test 3c: Cap Enforcement (2 hours offline)")
    
    var cappedState = GameState()
    cappedState.materials = 0
    cappedState.producers = ["miner": 1] // 1 miner = 1 material/sec
    cappedState.lastUpdate = Date().addingTimeInterval(-7200) // 2 hours ago
    
    let cappedSimulator = Simulator(state: cappedState)
    let cappedBefore = cappedSimulator.state.materials
    
    let cappedSimulatedTime = applyOfflineProgress(to: cappedSimulator)
    let cappedAfter = cappedSimulator.state.materials
    
    // Should only progress for 1 hour (3600s), not 2 hours
    let expectedCappedIncrease = 3600.0 // 1 hour * 1 material/sec
    let actualCappedIncrease = cappedAfter - cappedBefore
    
    print("\n📊 Capped Progress Test:")
    print("  Time Since Update: 7200s (2 hours)")
    print("  Simulated Time: \(Int(cappedSimulatedTime))s (should be 3600)")
    print("  Expected Increase: \(Int(expectedCappedIncrease)) materials (1 hour)")
    print("  Actual Increase: \(Int(actualCappedIncrease)) materials")
    
    let capEnforced = abs(cappedSimulatedTime - 3600) < 1.0 && abs(actualCappedIncrease - expectedCappedIncrease) < 10.0
    
    print("\n✅ Cap Verification:")
    print("  Cap enforced correctly: \(capEnforced ? "✅" : "❌")")
    
    if increaseMatch && capEnforced {
        print("\n🎉 Offline progress test PASSED")
    } else {
        print("\n❌ Offline progress test FAILED")
    }
}

// MARK: - Original Simulation Test

func runOriginalSimulationTest() {
    print("\n" + String(repeating: "=", count: 70))
    print("ORIGINAL SIMULATION TEST")
    print(String(repeating: "=", count: 70))
    
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
}

// MARK: - Main Execution

print("🧪 IdleTower Test Harness")
print("Testing Persistence and Offline Progress Features\n")

if runPersistenceTests {
    testSaveLoad()
    testJSONEncoding()
}

if runOfflineProgressTests {
    testOfflineProgress()
}

if runSimulationTest {
    runOriginalSimulationTest()
}

print("\n" + String(repeating: "=", count: 70))
print("✅ All tests complete!")
print(String(repeating: "=", count: 70))


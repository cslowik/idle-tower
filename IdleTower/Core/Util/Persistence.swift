//
//  Persistence.swift
//  IdleTower
//
//  Created by Chris Slowik on 1/5/26.
//

import Foundation
import IdleTowerCore

/// File I/O helpers for saving and loading game state
enum Persistence {
    /// Default save file name
    static let defaultFileName = "gamestate.json"
    
    /// Get the URL for the save file in the Documents directory
    static func saveFileURL(fileName: String = defaultFileName) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    /// Save GameState to JSON file in Documents directory
    /// - Parameters:
    ///   - state: The GameState to save
    ///   - fileName: Optional custom file name (defaults to "gamestate.json")
    /// - Returns: True if save succeeded, false otherwise
    static func save(_ state: GameState, fileName: String = defaultFileName) -> Bool {
        guard let url = saveFileURL(fileName: fileName) else {
            return false
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            print("Failed to save game state: \(error)")
            return false
        }
    }
    
    /// Load GameState from JSON file in Documents directory
    /// - Parameter fileName: Optional custom file name (defaults to "gamestate.json")
    /// - Returns: Loaded GameState if successful, nil otherwise
    static func load(fileName: String = defaultFileName) -> GameState? {
        guard let url = saveFileURL(fileName: fileName) else {
            return nil
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let state = try decoder.decode(GameState.self, from: data)
            return state
        } catch {
            print("Failed to load game state: \(error)")
            return nil
        }
    }
    
    /// Save Simulator state using the default file name
    /// - Parameters:
    ///   - simulator: The Simulator instance to save
    ///   - fileName: Optional custom file name (defaults to "gamestate.json")
    /// - Returns: True if save succeeded, false otherwise
    static func save(_ simulator: Simulator, fileName: String = defaultFileName) -> Bool {
        guard let url = saveFileURL(fileName: fileName) else {
            return false
        }
        return simulator.save(to: url)
    }
    
    /// Load Simulator state from the default file and apply offline progress automatically
    /// - Parameters:
    ///   - simulator: The Simulator instance to load into
    ///   - fileName: Optional custom file name (defaults to "gamestate.json")
    /// - Returns: True if load succeeded, false otherwise
    static func load(into simulator: Simulator, fileName: String = defaultFileName) -> Bool {
        guard let url = saveFileURL(fileName: fileName) else {
            return false
        }
        
        guard simulator.load(from: url) else {
            return false
        }
        
        // Apply offline progress automatically after loading
        _ = OfflineProgress.apply(to: simulator)
        return true
    }
}


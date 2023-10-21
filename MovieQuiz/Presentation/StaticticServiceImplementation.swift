//
//  StaticticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 19.10.2023.
//

import Foundation

final class StaticticServiceImplementation: StaticticService {
    
    // MARK: - Public Properties
    var gamesCount: Int {
        userDefaults.integer(forKey: Keys.gamesCount.rawValue)}
    
    var totalAccuracy: Double {
        let corr = Double(userDefaults.integer(forKey: Keys.correct.rawValue))
        let total = Double(userDefaults.integer(forKey: Keys.total.rawValue))
        return (corr / total) * 100}
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.setValue(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let date = Date()
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private var correct: Int {
        userDefaults.integer(forKey: Keys.correct.rawValue)}
    private var total: Int {
        userDefaults.integer(forKey: Keys.total.rawValue)}
    
    // MARK: - Public Methods
    func store(correct count: Int, total amount: Int) {
        userDefaults.set(correct + count, forKey: Keys.correct.rawValue)
        userDefaults.set(total + amount, forKey: Keys.total.rawValue)
        let currentGame = GameRecord(correct: count, total: amount,  date: date)
        if GameRecord.bestRecord(currentGame: currentGame, bestGame: bestGame) {
            bestGame = currentGame
        }
    }
}

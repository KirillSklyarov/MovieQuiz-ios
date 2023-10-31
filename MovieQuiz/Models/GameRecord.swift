//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 19.10.2023.
//

import Foundation

struct GameRecord: Codable {
    
    let correct: Int
    let total: Int
    let date: Date
    
    static func bestRecord(currentGame: GameRecord, bestGame: GameRecord) -> Bool {
        return  currentGame.correct > bestGame.correct
    }
}



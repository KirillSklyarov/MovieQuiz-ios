//
//  StaticticService.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 19.10.2023.
//

import Foundation

protocol StaticticService {
    
    func store(correct count: Int, total amount: Int)
    
    var totalAccuracy: Double {get}
    var gamesCount: Int {get}
    var bestGame: GameRecord {get}
    
}

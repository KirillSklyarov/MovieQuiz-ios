//
//  StaticticService.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 19.10.2023.
//

import Foundation

protocol StaticticService {
    
    // MARK: - Public Propeties
    var totalAccuracy: Double {get}
    var gamesCount: Int {get}
    var bestGame: GameRecord {get}
    
    // MARK: - Public Methods
    func store(correct count: Int, total amount: Int)
    
}

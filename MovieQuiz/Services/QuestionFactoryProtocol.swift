//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 17.10.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    
    var delegate: QuestionFactoryDelegate? { get set }

    func requestNextQuestion()
    func loadData()
    
}

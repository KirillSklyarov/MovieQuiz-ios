//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 17.10.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    
    func didReceiveNextQuestion(question: QuizQuestion?)
}

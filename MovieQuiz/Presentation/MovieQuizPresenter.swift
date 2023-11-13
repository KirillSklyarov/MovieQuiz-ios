//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 11.11.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StaticticService!
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private var gamesCountHere: Int = 0
    private let questionsAmount: Int = 10
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StaticticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QiestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicatior()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Public methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1 }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        proccedWithAnswer(isCorrect: currentQuestion.correctAnswer)
    }
    
    func noButtonCLicked() {
        viewController?.noButton.isEnabled = true
        guard let currentQuestion = currentQuestion else {
            return
        }
        proccedWithAnswer(isCorrect: !currentQuestion.correctAnswer)
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bgCorrect = statisticService.bestGame.correct
        let bgTotal = statisticService.bestGame.total
        let bgDate = statisticService.bestGame.date.dateTimeString
        let message = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(bgCorrect)/\(bgTotal) (\(bgDate))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
        return message
    }
    
    // MARK: - Private methods
    
    private func proccedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        viewController?.noButton.isEnabled = false
        viewController?.yesButton.isEnabled = false

        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.viewController?.noButton.isEnabled = true
            self.viewController?.yesButton.isEnabled = true
            self.proccedToNextQuestionOrResults()
        }
    }
    
    private func proccedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}

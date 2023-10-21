import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    public var correctAnswers = 0
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var gamesCountHere: Int = 0
    private var statisticService: StaticticService = StaticticServiceImplementation()
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IB Actions
    @IBAction func noButton(_ sender: UIButton) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        if currentQuestion.correctAnswer == false {
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction func yesButton(_ sender: UIButton) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        if currentQuestion.correctAnswer == true {
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        if isCorrect {
            correctAnswers += 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            gamesCountHere += 1
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGameCorrect = statisticService.bestGame.correct,
                bestGameTotal = statisticService.bestGame.total,
                bestGameDate = statisticService.bestGame.date
            let model = AlertModel(title: "Этот раунд окончен!",
                                   message: """
                                    Ваш результат \(correctAnswers)/\(questionsAmount)
                                    Количество сыгранных квизов: \(gamesCountHere)
                                    Рекорд: \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate))
                                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                    """,
                                   buttonText: "Сыграть еще раз",
                                   completion: reset)
            let vc = AlertPresenter(controller: self)
            vc.show(quiz: model)
        }
        else {
            noButton.isEnabled = true
            yesButton.isEnabled = true
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func reset() {
        currentQuestionIndex = 0
        correctAnswers = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
        questionFactory.requestNextQuestion()
    }
}

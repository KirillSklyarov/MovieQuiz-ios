import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    public var correctAnswers = 0
    private var gamesCountHere: Int = 0
    private let presenter = MovieQuizPresenter()
    private var statisticService: StaticticService = StaticticServiceImplementation()
    
    var questionFactory: QuestionFactoryProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StaticticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - IB Actions
    @IBAction func noButton(_ sender: UIButton) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        presenter.noButtonCLicked()
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    @IBAction func yesButton(_ sender: UIButton) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        presenter.yesButtonClicked()
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    // MARK: - Public Methods
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        if isCorrect {
            correctAnswers += 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Private Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        
        if presenter.isLastQuestion() {
            gamesCountHere += 1
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let bgCorrect = statisticService.bestGame.correct
            let bgTotal = statisticService.bestGame.total
            let bgDate = statisticService.bestGame.date.dateTimeString
            message = """
                    Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                    Количество сыгранных квизов: \(gamesCountHere)
                    Рекорд: \(bgCorrect)/\(bgTotal) (\(bgDate))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
        }
        
        let model = AlertModel(title: "Этот раунд окончен!",
                               message: message,
                               buttonText: "Сыграть еще раз",
                               completion: reset)
        
        let vc = AlertPresenter(controller: self)
        vc.show(result: model)
    }
    
    func reset() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
        questionFactory?.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.color = .red
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else {return}
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        let vc = AlertPresenter(controller: self)
        vc.show(result: model)
    }
}


//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Kirill Sklyarov on 17.10.2023.
//

import UIKit

final class AlertPresenter {

    private let controller: MovieQuizViewController
    
    init(controller: MovieQuizViewController) {
        self.controller = controller
    }
    
    func show(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                result.completion()
            }
                
        alert.addAction(alertAction)
        controller.present(alert, animated: true, completion: nil)
    }
}

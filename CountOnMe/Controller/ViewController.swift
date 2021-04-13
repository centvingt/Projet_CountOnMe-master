//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var numberButtons: [UIButton]!
    
    var expression = Expression()
    
    // View Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTextView),
            name: .udpatedExpression,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentAlert),
            name: .operatorAlreadySet,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentAlert),
            name: .notCorrectExpression,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentAlert),
            name: .notEnoughElement,
            object: nil
        )
    }
    
    // View actions
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        guard let numberText = sender.title(for: .normal) else {
            return
        }
        expression.add(element: .number(numberText))
    }
    
    @IBAction func tappedAdditionButton(_ sender: UIButton) {
        expression.add(element: .plus)
    }
    
    @IBAction func tappedSubstractionButton(_ sender: UIButton) {
        expression.add(element: .minus)
    }
    
    @IBAction func tappedMultiplicationButton(_ sender: UIButton) {
        expression.add(element: .time)
    }
    
    @IBAction func tappedDivisionButton(_ sender: UIButton) {
        expression.add(element: .dividedBy)
    }
    
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        expression.add(element: .equal)
    }
    
    @objc private func updateTextView() {
        textView.text = expression.elements.joined(separator: " ")
    }
    @objc private func presentAlert(_ notification: Notification) {
        var message: String
        switch notification.name {
        case .notCorrectExpression:
            message = "Entrez une expression correcte !"
        case .notEnoughElement:
            message = "Démarrez un nouveau calcul !"
        default:
            message = "Un operateur est déja mis !"
        }
        let alertVC = UIAlertController(title: "Zéro!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}


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
    
    // Model's instance
    var expression = Expression()
    
    // View Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Update TextView content each time expression is changed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTextView),
            name: .udpatedExpression,
            object: nil
        )
        
        // Present alerts in case of the model's errors
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
    
    // Adding number typed by user
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        guard let numberText = sender.title(for: .normal) else {
            return
        }
        expression.add(element: .number(numberText))
    }
    
    // Adding plus typed by user
    @IBAction func tappedAdditionButton(_ sender: UIButton) {
        expression.add(element: .plus)
    }
    
    // Adding minus typed by user
    @IBAction func tappedSubstractionButton(_ sender: UIButton) {
        expression.add(element: .minus)
    }
    
    // Adding time typed by user
    @IBAction func tappedMultiplicationButton(_ sender: UIButton) {
        expression.add(element: .time)
    }
    
    // Adding division sign typed by user
    @IBAction func tappedDivisionButton(_ sender: UIButton) {
        expression.add(element: .dividedBy)
    }
    
    // Adding equal typed by user
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        expression.add(element: .equal)
    }
    
    /* Used by notification observer for update TextView content
     each time expression is changed */
    @objc private func updateTextView() {
        textView.text = expression.elements.joined(separator: " ")
    }
    
    // Used by notification observer for presenting alert in case of model's error
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


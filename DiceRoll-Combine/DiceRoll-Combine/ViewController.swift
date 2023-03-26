//
//  ViewController.swift
//  DiceRoll-Combine
//
//  Created by YILDIRIM on 26.03.2023.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    let imageView =  DiceImageView(frame: .zero)
    let button = BigButton(type: .custom)
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = DiceViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        viewModel.$diceImage
            .map { $0 as UIImage? }
            .assign(to: \.image, on: imageView)
            .store(in: &cancellables)
        
        viewModel.$isRolling
            .map { !$0 }
            .assign(to: \.isEnabled, on: button)
            .store(in: &cancellables)
        
        viewModel.$isRolling
            .sink { [weak self] isRolling in
                UIView.animate(withDuration: 0.5) {
                    self?.imageView.alpha = isRolling ? 0.5 : 1.0
                    self?.imageView.transform = isRolling ? CGAffineTransform(scaleX: 0.5, y: 0.5) : CGAffineTransform.identity
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [unowned self] error in
                let alert = UIAlertController(title: "Dice Error", message: "\(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                alert.addAction(UIAlertAction(title: "Reroll", style: .default, handler: { [weak self] _ in
                    self?.buttonTapper(self as Any)
                }))
                present(alert,animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc func buttonTapper(_ sender: Any) {
        viewModel.rollDice()
    }


    //MARK: -  Configure
    
    private func configure() {
        view.addSubview(imageView)
        view.addSubview(button)
        view.backgroundColor = .systemBackground
        imageView.image = UIImage(named: "dice-five")
        
        button.addTarget(self, action: #selector(buttonTapper(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
        
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -150),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 120),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -30),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}


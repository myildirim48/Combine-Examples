//
//  ViewController.swift
//  SigUpExample-Combine
//
//  Created by YILDIRIM on 26.03.2023.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    let emailField = UITextField()
    let passwordField = UITextField()
    let passwordConfirmationField = UITextField()
    let termSwitch = UISwitch()
    let termLabel = UILabel()
    let confirmButton = UIButton()
    
    //MARK: - Subject

    private var viewModel = SignUpViewModel()
    
    private var cancellables : Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        configure()
        
        viewModel.$email
            .map { $0 as String? }
            .assign(to: \.text, on: emailField)
            .store(in: &cancellables)
        
        viewModel.$emailFieldTextColor
            .assign(to: \.textColor, on: emailField)
            .store(in: &cancellables)
        
        viewModel.$passwordFieldTextColor
            .assign(to: \.textColor, on: passwordField)
            .store(in: &cancellables)
        
        viewModel.$passwordConfirmationFieldTextColor
            .assign(to: \.textColor, on: passwordConfirmationField)
            .store(in: &cancellables)
        
        viewModel.$signUpButtonEnabled
            .assign(to: \.isEnabled, on: confirmButton)
            .store(in: &cancellables)
    }
    

    //MARK: -  Publishers
    
    func setValidColor<P: Publisher> (field: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
            .map{ $0 ? UIColor.label : UIColor.systemRed}
            .assign(to: \.textColor, on: field)
            .store(in: &cancellables)
    }
    
    
    //MARK: - Actions
    
    @objc func buttonTapped() {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func emailFieldDidchange(_ textField: UITextField) {
        viewModel.email = textField.text ?? ""
    }
    @objc func passwordFiedDidChange(_ textField: UITextField) {
        viewModel.password = textField.text ?? ""
    }
    @objc func passwordConfirmationFiledDidchange(_ textField: UITextField) {
        viewModel.passwordConfirmation =  textField.text ?? ""
    }
    @objc func termSwitchChanged(_ termSwitch: UISwitch){
        viewModel.agreeTerms = termSwitch.isOn
    }
    
    //MARK: -  Configure
    
    private func configure(){
        view.addSubviews(emailField,passwordField,passwordConfirmationField,termSwitch,termLabel,confirmButton)
        
        confirmButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        emailField.addTarget(self, action: #selector(emailFieldDidchange(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordFiedDidChange(_:)), for: .editingChanged)
        passwordConfirmationField.addTarget(self, action: #selector(passwordConfirmationFiledDidchange(_:)), for: .editingChanged)
        termSwitch.addTarget(self, action: #selector(termSwitchChanged(_:)), for: .touchUpInside)
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordConfirmationField.translatesAutoresizingMaskIntoConstraints = false
        termSwitch.translatesAutoresizingMaskIntoConstraints = false
        termLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        emailField.backgroundColor = .secondarySystemBackground
        emailField.layer.cornerRadius = 8
        emailField.placeholder = "E-mail"
        
        passwordField.backgroundColor = .secondarySystemBackground
        passwordField.layer.cornerRadius = 8
        passwordField.placeholder = "Password"
        passwordField.textContentType = .password
        passwordField.isSecureTextEntry = true
        
        passwordConfirmationField.backgroundColor = .secondarySystemBackground
        passwordConfirmationField.layer.cornerRadius = 8
        passwordConfirmationField.placeholder = "Confirm Password"
        passwordConfirmationField.textContentType = .password
        passwordConfirmationField.isSecureTextEntry = true
        
        termLabel.text = "I agree to the terms."
        
        confirmButton.setTitle("Sign Up", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitle("Fill the form first.", for: .disabled)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.layer.cornerRadius = 8
        confirmButton.isUserInteractionEnabled = true
        
        
        let outerSpace: CGFloat = 40
        let innerSpace: CGFloat = 25
        
        NSLayoutConstraint.activate([
            
            emailField.topAnchor.constraint(equalTo: view.topAnchor,constant: 4*outerSpace),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: innerSpace),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -innerSpace),
            emailField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor,constant: innerSpace),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordConfirmationField.topAnchor.constraint(equalTo: passwordField.bottomAnchor,constant: innerSpace),
            passwordConfirmationField.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            passwordConfirmationField.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            passwordConfirmationField.heightAnchor.constraint(equalToConstant: 40),
            
            termSwitch.topAnchor.constraint(equalTo: passwordConfirmationField.bottomAnchor,constant: outerSpace),
            termSwitch.leadingAnchor.constraint(equalTo: passwordConfirmationField.trailingAnchor, constant: -2*outerSpace),
            
            termLabel.centerYAnchor.constraint(equalTo: termSwitch.centerYAnchor),
            termLabel.trailingAnchor.constraint(equalTo: termSwitch.leadingAnchor,constant: -outerSpace),
            
            confirmButton.topAnchor.constraint(equalTo: termLabel.bottomAnchor,constant: outerSpace),
            confirmButton.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor)
            
        ])
    }
}


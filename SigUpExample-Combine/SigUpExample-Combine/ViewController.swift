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
    
    private var emailSubject = CurrentValueSubject<String,Never>("")
    private var passwordSubject = CurrentValueSubject<String,Never>("")
    private var passwordConfirmationSubject = CurrentValueSubject<String,Never>("")
    private var agreeTermSubject = CurrentValueSubject<Bool,Never>(false)
    private var cancellable : Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        configure()
        
        formIsValid
            .assign(to: \.isEnabled, on: confirmButton)
            .store(in: &cancellable)
        
        setValidColor(field: emailField, publisher: emailIsValid)
        setValidColor(field: passwordField, publisher: passwordIsValid)
        setValidColor(field: passwordConfirmationField, publisher: passwordMatchesConfirmation)
        
        formattedEmailAddress
            .filter { [weak self] in $0 != self?.emailSubject.value }
            .map { $0 as String? }
            .assign(to: \.text,on: emailField)
            .store(in: &cancellable)
    }
    
    private func setValidColor<P: Publisher> (field: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
            .map{ $0 ? UIColor.label : UIColor.systemRed}
            .assign(to: \.textColor, on: field)
            .store(in: &cancellable)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
    //MARK: -  Publishers
    private var formIsValid: AnyPublisher<Bool, Never>{
        
        Publishers.CombineLatest3(emailIsValid, passwordValidandConfirmed,agreeTermSubject)
            .map{ $0.0 && $0.1 && $0.2}
            .eraseToAnyPublisher()
    }
    
    private var formattedEmailAddress: AnyPublisher<String, Never>{
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
            .eraseToAnyPublisher()
    }
    
    private var emailIsValid: AnyPublisher<Bool,Never>{
        formattedEmailAddress
            .map { [weak self] in self?.isValidEmail($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    private var passwordValidandConfirmed: AnyPublisher<Bool, Never>{
        passwordIsValid.combineLatest(passwordMatchesConfirmation)
            .map { valid, confirmed in
                valid && confirmed
            }.eraseToAnyPublisher()
    }
    
    private var passwordIsValid: AnyPublisher<Bool, Never>{
        passwordSubject
            .map{
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfirmationSubject)
            .map { pass, conf in
                pass == conf
            }.eraseToAnyPublisher()
        
    }
    
    
    //MARK: - Actions
    
    @objc func buttonTapped() {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func emailFieldDidchange(_ textField: UITextField) {
        emailSubject.send(textField.text ?? "")
    }
    @objc func passwordFiedDidChange(_ textField: UITextField) {
        passwordSubject.send(textField.text ?? "")
    }
    @objc func passwordConfirmationFiledDidchange(_ textField: UITextField) {
        passwordConfirmationSubject.send(textField.text ?? "")
    }
    @objc func termSwitchChanged(_ termSwitch: UISwitch){
        agreeTermSubject.send(termSwitch.isOn)
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


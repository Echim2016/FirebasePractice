//
//  LoginViewController.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    var userHasAccount = true
    var loginEmail = ""
    
    let db = Firestore.firestore()

    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pressLogin(_ sender: Any) {
        
        findUserEmail { hasAccount in
            if hasAccount {
                self.performSegue(withIdentifier: "loginSuccess", sender: nil)
            } else {
                self.performSegue(withIdentifier: "toSignUp", sender: sender)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let homeVC = segue.destination as? UITabBarController {
            homeVC.modalPresentationStyle = .fullScreen
        }
        
        if let signUpVC = segue.destination as? SignUpViewController {
            signUpVC.modalPresentationStyle = .fullScreen
            signUpVC.defaultEmail = loginEmail
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text,
              !text.isEmpty else {
            print("Please enter a valid input")
            return
        }
        
        loginEmail = text
    }
    
}

extension LoginViewController {
    
    func findUserEmail(completion: @escaping (Bool) -> Void) {
        
        
        userHasAccount = false
        
        db.collection(Collection.users.title).whereField(Users.email.field, isEqualTo: loginEmail).getDocuments {
            (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    print(document.data())
                    self.userHasAccount = true
                    completion(self.userHasAccount)
                    break
                }
                
            }
            self.userHasAccount = false
            completion(self.userHasAccount)
        }
        
        
    }
    
    
}

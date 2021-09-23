//
//  SignUpViewController.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.accessibilityLabel = "email"
            emailTextField.text = defaultEmail
            userEmail = defaultEmail
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.accessibilityLabel = "name"
            nameTextField.delegate = self
        }
    }
    
    var userEmail = ""
    var userName = ""
    
    var defaultEmail = ""
    
    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressSignUp(_ sender: Any) {
        
        createUser { isSignUp in
            if isSignUp {
                self.performSegue(withIdentifier: "signUpSuccess", sender: nil)
                self.showAlert(title: "Success", message: "成功創建帳號")
            } else {
                self.showAlert(title: "Error", message: "請重新註冊")
            }
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let homeVC = segue.destination as? TabBarController {
            homeVC.modalPresentationStyle = .fullScreen
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }

}

extension SignUpViewController {
    
    func createUser(completion: @escaping (Bool) -> Void) {
        
        let ref = db.collection(Collection.users.title).document()
        ref.setData([
            Users.id.field : ref.documentID,
            Users.email.field : userEmail,
            Users.name.field : userName
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("User added with ID: \(ref.documentID)")
                completion(true)
            }
        }
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text,
              !text.isEmpty else {
            print("Please enter a valid input")
            return
        }
        
        switch textField.accessibilityLabel {
        case "email":
            userEmail = text
        case "name":
            userName = text
        default:
            break
        }
    }
    
    
}

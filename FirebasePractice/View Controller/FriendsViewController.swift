//
//  FriendsViewController.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {

    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    var query = ""
    var users: [User] = []
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.delegate = self
        tableVIew.dataSource = self
        
        tableVIew.tableHeaderView?.isHidden
//        let searchController = UISearchController()
//        navigationItem.searchController = searchController
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressSearchButton(_ sender: Any) {
        
        findUserEmail { emailIsFound in
            if emailIsFound {
                print("found")
            }
        }
        
    }
    
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension FriendsViewController {
    
    func findUserEmail(completion: @escaping (Bool) -> Void) {
        
        print(query)
        db.collection(Collection.users.title).whereField(Users.email.field, isEqualTo: query).getDocuments {
            (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
//                    print(document.data())
                    
                    
                    guard let name = document.get("name") as? String,
                          let email = document.get("email") as? String,
                          let id = document.get("id") as? String else {
                        print("find email or name failed")
                        return
                    }
                    
                    let user = User.init(id: id, name: name, email: email)
                    self.users.append(user)
                    
                    completion(true)
                    break
                }
                
            }
        }
        
        
    }
}

extension FriendsViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text,
              !text.isEmpty else {
            print("Please enter a valid input")
            return
        }
        
        query = text
        
    }
    
}

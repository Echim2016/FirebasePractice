//
//  FriendsViewController.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {

    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    var selectedIndex = 0
    
    var query = ""
    var users: [User] = []
    let ownerEmail = "ychim26@gmail.com"
    let ownerID = "gMXI7dKxWrtQ9PdWPxUc"
    
    var invitationList: [String] = []
    var friendList: [String] = []
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.delegate = self
        tableVIew.dataSource = self
        
        tableVIew.tableHeaderView?.isHidden = false
//        let searchController = UISearchController()
//        navigationItem.searchController = searchController
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressSearchButton(_ sender: Any) {
        
        findUserEmail { emailIsFound in
            if emailIsFound {
                self.tableVIew.reloadData()
            }
        }
        
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            selectedIndex = 0
            tableVIew.tableHeaderView?.isHidden = false
            
            tableVIew.reloadData()
        case 1:
            selectedIndex = 1
            getInvitations()
            tableVIew.tableHeaderView?.isHidden = true
            
            tableVIew.reloadData()
        case 2:
            selectedIndex = 2
            tableVIew.tableHeaderView?.isHidden = true
            
            tableVIew.reloadData()
        default:
            break
        }
        
    }
    
    

    
}

extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch selectedIndex {
        case 0:
            return users.count
        case 1:
            return invitationList.count
        case 2:
            return friendList.count
        default:
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendResultCell", for: indexPath) as? FriendResultCell
        else { fatalError("Could not create FriendResultCell") }
        
       print("call")
        print(invitationList[0])
        
        switch selectedIndex {
        case 0:
            cell.emailLabel.isHidden = false
            cell.addFriend.isHidden = false
            cell.setCell(name: users[indexPath.row].name, email: users[indexPath.row].email)
            cell.addFriend.addTarget(self, action: #selector(pressAddFriend(_:)), for: .touchUpInside)
        case 1:
            cell.nameLabel.text = invitationList[indexPath.row]
            cell.emailLabel.isHidden = true
            cell.addFriend.isHidden = true
        case 2:
            cell.nameLabel.text = "test"
            cell.emailLabel.isHidden = false
            cell.addFriend.isHidden = true
        default:
            break
        }
        
        
        
        return cell
    }
    
    @objc func pressAddFriend(_ sender: UIButton) {
        
        addFriendRequst()
    }
    
}

extension FriendsViewController {
    
    func findUserEmail(completion: @escaping (Bool) -> Void) {
        
        users = []
        tableVIew.reloadData()
        
        db.collection(Collection.users.title).whereField(Users.email.field, isEqualTo: query).getDocuments {
            (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    
                    guard let name = document.get("name") as? String,
                          let email = document.get("email") as? String,
                          let id = document.get("id") as? String else {
                        print("find email or name failed")
                        return
                    }
                    
                    let user = User.init(id: id, name: name, email: email)
                    self.users.append(user)
                    
                    print(user)
                    
                    completion(true)
                    break
                }
                
            }
        }
    }
    
    
    func addFriendRequst() {
        
        let ref = db.collection("Request").document()
        ref.setData([
            "to" : users.first?.email,
            "from": ownerEmail,
            "accepted" : false
        ]) { err in
            if let err = err {
                print("Error updating request: \(err)")
            } else {
                print("Request successfully updated")
            }
        }
    }
    
    func getInvitations() {
        
        invitationList = []
        
        db.collection("Request").whereField("to", isEqualTo: ownerEmail).getDocuments {
            (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    
                    guard let from = document.get("from") as? String else {
                        print("can't get from person")
                        return
                    }
                    
                    self.invitationList.append(from)
                    
                }
                
                print(self.invitationList)
                self.tableVIew.reloadData()
                
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


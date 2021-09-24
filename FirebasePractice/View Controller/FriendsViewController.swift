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
    var myFriendList: [String] = []
    var myFriendNameList: [String] = []
    
    var isFriend = false
    var hasSentRequest = false
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.delegate = self
        tableVIew.dataSource = self
        
        setListener()
        getMyFriendList { isGet in
            print(isGet)
            print(self.myFriendList)
            print(self.myFriendNameList)
        }
        tableVIew.tableHeaderView?.isHidden = false
    
    }
    
    @IBAction func pressSearchButton(_ sender: Any) {
        
        findUserEmail { isGet in
                self.tableVIew.reloadData()
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
            getMyFriendList { gotList in
                if gotList {
                    self.tableVIew.reloadData()
                }
            }
        default:
            break
        }
        
    }
    
    func showAlert(title: String, message: String) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
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
            print(myFriendList.count)
            return myFriendList.count
            
        default:
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendResultCell", for: indexPath) as? FriendResultCell
        else { fatalError("Could not create FriendResultCell") }
        
        cell.confirmFriendBtn.isHidden = true
        
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
            
            cell.confirmFriendBtn.isHidden = false
            cell.confirmFriendBtn.addTarget(self, action: #selector(pressConfirm(_:)), for: .touchUpInside)
        case 2:
//            cell.nameLabel.text = myFriendNameList[indexPath.row]
            cell.emailLabel.text = myFriendList[indexPath.row]
            cell.nameLabel.isHidden = true
            cell.emailLabel.isHidden = false
            cell.addFriend.isHidden = true
            
        default:
            break
        }
        
        
        
        return cell
    }
    
    @objc func pressAddFriend(_ sender: UIButton) {
        
        
        if hasSentRequest {
            showAlert(title: "Fail", message: "你已經寄過邀請了")
        } else if isFriend {
//            print("Do nothing")
            showAlert(title: "Fail", message: "你們已經是朋友囉")
        } else {
            addFriendRequst()
        }
        
    }
    
    @objc func pressConfirm(_ sender: UIButton) {
        
        resetRequest()
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
//                    print(user)
                    
                    if self.myFriendList.contains(email) {
                        print("已經是朋友")
                        self.isFriend = true
                        completion(false)
                        break
                    } else {
                        
                        self.db.collection("Request").whereField("to", isEqualTo: email).whereField("from", isEqualTo: self.ownerEmail).getDocuments { (snapShot, error) in
                            
                            print(snapShot?.documents.count)
                            
                            if snapShot?.documents.count ?? 0 > 0 {
                                print("count > 0")
                                self.hasSentRequest = true
                                completion(true)
                                
                            }
                            self.isFriend = false
                            completion(true)
                            
                        }
                        
                        break
                    }
                    
                }
                
            }
        }
    }
    
    
    func addFriendRequst() {
        
        let ref = db.collection("Request").document()
        ref.setData([
            "to" : users.first?.email,
            "from": ownerEmail
        ]) { err in
            if let err = err {
                print("Error updating request: \(err)")
            } else {
                self.showAlert(title: "Success!", message: "成功送出好友邀請")
                print("Request successfully updated")
            }
        }
    }
    
    func getInvitations() {
        
        invitationList = []
        
        // 找所有給裝置主人的 request
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
//                print(self.invitationList)
                self.tableVIew.reloadData()
                
            }
        }
    }
    
    func setListener() {
        // Listen to document metadata.
        db.collection("Request")
            .addSnapshotListener(includeMetadataChanges: true) { documentSnapshot, error in
                
                if let error = error {
                    print(error)
                } else {
                    guard let ref = documentSnapshot?.documentChanges,
                          ref.count > 0,
                          let myInvitation = ref[0].document.get("to") as? String,
                          let from = ref[0].document.get("from") as? String else {
                        print("can't get 'to' ")
                        return
                    }

                    if myInvitation == self.ownerEmail {
                        print("\(self.ownerEmail) recieved a invitation from \(from)")
//                        self.invitationList.append(from)
                    }
                    
//                    self.tableVIew.reloadData()
                    
//                    self.getInvitations()
                    
                }
            }
    }
    
    func resetRequest() {
        
        friendList = []
        myFriendList = []
        
        // 在全部同意好友邀請後，去Request池裡面找有送給我好友邀請的request，把request刪掉
        invitationList.forEach { newFriend in
            
            myFriendList.append(newFriend)
            print(invitationList)
            
            db.collection("Request").whereField("to", isEqualTo: ownerEmail).getDocuments {
                (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        let ref = self.db.collection("Request").document(document.documentID)
                        ref.delete(){ err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Request successfully removed!")
                            }
                        }
                    }
                }
            }
            
            // 更新新朋友的朋友清單，把自己加進去
            db.collection("Users").whereField("email", isEqualTo: newFriend).getDocuments  {
                (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        guard let oldFirendList = document.get("friend_list") as? [String] else {
                            print("can't get friend list")
                            return
                        }
                        
                        self.friendList = oldFirendList
                        self.friendList.append(self.ownerEmail)
                        if self.friendList.first == "" {
                            self.friendList.removeFirst()
                        }
                        
                        
                        let ref = self.db.collection("Users").document(document.documentID)
                        
                        ref.updateData([
                            "friend_list" : self.friendList
                        ]) { err in
                            if let err = err {
                                print("Error updating accpeted request: \(err)")
                            } else {
//                                print("New friend's friend list successfully updated")
                            }
                        }
                    }
                }
            }
            
            
            // 更新自己的朋友清單，把新朋友加進去
            db.collection("Users").whereField("email", isEqualTo: ownerEmail).getDocuments  {
                (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        
                        let ref = self.db.collection("Users").document(document.documentID)
                        ref.updateData([
                            "friend_list" : self.myFriendList
                        ]) { err in
                            if let err = err {
                                print("Error updating accpeted request: \(err)")
                            } else {
//                                print("My new friend's friend list successfully updated")
                            }
                        }
                    }
                    
                    
                    
                }
            }
            
            
        }
        
        invitationList = []
        self.tableVIew.reloadData()
    }
    
    func getMyFriendList(completion: @escaping (Bool) -> Void) {
        
        myFriendList = []
//        myFriendNameList = []
        
        db.collection("Users").whereField("email", isEqualTo: ownerEmail).getDocuments  {
            (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    
                    guard let oldFirendList = document.get("friend_list") as? [String] else {
                        print("can't get my old friend list")
                        return
                    }
                    
                    self.myFriendList = oldFirendList
                    
                    if self.myFriendList.first == "" {
                        self.myFriendList.removeFirst()
                    }
                    
                    completion(true)
                    
//                    self.myFriendList.forEach {  myFriend in
//
//                        self.db.collection("Users").whereField("email", isEqualTo: myFriend).getDocuments  {
//                            (querySnapshot, error) in
//                            if let querySnapshot = querySnapshot {
//                                for document in querySnapshot.documents {
//
//                                    guard let name = document.get("name") as? String else {
//                                        print("can't get my old friend list")
//                                        return
//                                    }
//
//                                    self.myFriendNameList.append(name)
//                                    print(self.myFriendList)
//
//                                }
//                                completion(true)
//                            }
//                        }
//
//                    }
                    
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


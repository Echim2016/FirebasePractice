//
//  HomeViewController.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/22.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField! {
        didSet {
            titleTextField.delegate = self
            titleTextField.accessibilityLabel = "title"
        }
    }
    @IBOutlet weak var contentTextField: UITextField!{
        didSet {
            contentTextField.delegate = self
            contentTextField.accessibilityLabel = "content"
        }
    }
    @IBOutlet weak var tagTextField: UITextField!{
        didSet {
            tagTextField.delegate = self
            tagTextField.accessibilityLabel = "tag"
            tagTextField.text = currentText
        }
    }
    
    let pickerView = UIPickerView()
    
    let collectionName = "Documents"
    var documentID = 1
    var pickerSelectedIndex = 0
    let currentText = Tag.beauty.title
    
    var document = Document.init(id: "", title: "", content: "", tag: "", authorID: "ios-1", createdTime: nil)
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        document.tag = currentText
        setListener()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    @IBAction func pressPost(_ sender: Any) {
        
        setDocument(document: document)
        showAlert()
        resetTextField()
    }
    
}

extension HomeViewController {
    
    func setListener() {
        // Listen to document metadata.
        db.collection("Documents")
            .addSnapshotListener(includeMetadataChanges: true) { documentSnapshot, error in
                
                if let error = error {
                    print(error)
                } else {
                    self.readDocument()
                }
            }
    }
    
    
}

extension HomeViewController {
    
    func showAlert() {
        
        let controller = UIAlertController(title: "Success!", message: "成功發布新文章！", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    func resetTextField() {
        
        titleTextField.text = ""
        contentTextField.text = ""
        tagTextField.text = Tag.beauty.title
    }
    
}

extension HomeViewController {
    
    
    func setDocument(document: Document) {
        
        let ref = db.collection(collectionName).document()
        ref.setData([
            "id": ref.documentID,
            "title": document.title,
            "content": document.content,
            "tag": document.tag,
            "author_id": document.authorID,
            "created_time": NSDate()
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
//                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
    }
    
    func readDocument() {
        
        db.collection(collectionName).order(by: "created_time").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    print("\(document.documentID) => \(document.data())")
                }
                print("-----end-----")
            }
        }
    }

}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let text = textField.text,
              !text.isEmpty else {
            print("empty input")
            return
        }
        
        switch textField.accessibilityLabel {
        case "title":
            document.title = text
        case "content":
            document.content = text
        case "tag":
            document.tag = text
        default:
            break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.accessibilityLabel == "tag" {
            self.initPickerView(touchAt: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func initPickerView(touchAt sender: UITextField){
        
        // set default selected row of pickerViw
        let currentText = tagTextField.text
        pickerSelectedIndex = Tag.allCases.filter{$0.title == currentText}.first?.rawValue ?? 0
        pickerView.selectRow(pickerSelectedIndex, inComponent: 0, animated: true)
        
        tagTextField.keyboardToolbar.isHidden = true
        tagTextField.inputView = pickerView
        tagTextField.becomeFirstResponder()
    }
    
}

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Tag.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Tag.allCases[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      print(row)
        tagTextField.text = Tag.allCases[row].title
        self.view.endEditing(true)
    }
    
}

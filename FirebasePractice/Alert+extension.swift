//
//  Alert+extension.swift
//  FirebasePractice
//
//  Created by Yi-Chin Hsu on 2021/9/23.
//

import UIKit

extension UIAlertController {
    
    func showAlert(title: String, message: String) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
}

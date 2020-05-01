//
//  ResetPasswordViewController.swift
//  

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        // Validate the input
        guard let emailAddress = emailTextField.text, emailAddress != "" else {
            let alertController = UIAlertController(title: "Input Error", message: "Please provide your email address for password reset.", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Send password reset email
        Auth.auth().sendPasswordReset(withEmail: emailAddress, completion: { (error) in
            
            let title = (error == nil) ? "Password Reset Follow-up" : "Password Reset Error"
            
            let message = (error == nil) ? "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password." : error?.localizedDescription
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                
                if error == nil {
                    
                    // Dismiss keyboard
                    self.view.endEditing(true)
                    
                    // Return to the login screen
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            })
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Пароль"
        // Modifying the Navigation Bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Avenir", size: 25.0) {
            navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor(red: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0), NSAttributedString.Key.font: customFont]
        }
        
        emailTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

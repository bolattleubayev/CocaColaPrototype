//
//  LoginViewController.swift
//  
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func login(sender: UIButton) {
        
        // Validate the input
        guard let emailAddress = emailTextField.text, emailAddress != "", let password = passwordTextField.text, password != "" else {
            
            let alertController = UIAlertController(title: "Login Error", message: "Both fields are required.", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Perform login by Firebase APIs
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: { (result, error) in
            
            if let error = error {
                
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Email verification
            guard let result = result, result.user.isEmailVerified else {
                let alertController = UIAlertController(title: "Login Error", message: "You haven't confirmed your email address yet. We sent you a confirmation email when you sign up. Please click the verification link in that email. If you need us to send the confirmation email again, please tap Resend Email.", preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: "Resend email", style: .default, handler: { (action) in
                    Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // Dismiss keyboard
            self.view.endEditing(true)
            
            // Present the main view
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Вход"
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = ""
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

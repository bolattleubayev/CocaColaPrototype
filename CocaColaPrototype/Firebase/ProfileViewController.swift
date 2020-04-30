//
//  ProfileViewController.swift
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    
//
//    let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts")
//
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet weak var userPhotoView: UIImageView!
    
    @IBAction func logout(sender: UIButton) {
        do {
            
            // Total logout for Google acc
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                
                switch userInfo.providerID {
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                default:
                    break
                }
            }
            
            try Auth.auth().signOut()
        } catch {
            let alertController = UIAlertController(title: "Logout Error", message: error.localizedDescription, preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
            
        }
        
        // Present the welcome view
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let currentUser = Auth.auth().currentUser {
            nameLabel.text = currentUser.displayName
            
            let BASE_DB_REF: DatabaseReference = Database.database().reference()
            let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts")
            // Setting Data
            POST_DB_REF.setValue(10)
            
            // Retrieving data
            BASE_DB_REF.observeSingleEvent(of: .value, with: { (snapshot) in
                for item in snapshot.children.allObjects as! [DataSnapshot] {
                    print(item)
                    let postInfo = item.value as? Int ?? 0
                    print(postInfo)
                }
            })
        }
        
        if let user = GIDSignIn.sharedInstance()!.currentUser {
            if user.profile.hasImage {
                userPhotoView.image = UIImage()
                
                let url = user.profile.imageURL(withDimension: 200)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        self.userPhotoView.image = UIImage(data: data!)
                    }
                }
                
                
            } else {
                userPhotoView.image = UIImage(named: "person.fill")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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

//
//  ProfileViewController.swift
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FirebaseStorage
import MapKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate {
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet weak var userPhotoView: UIImageView!
    
    @IBOutlet weak var scoreBar: UIProgressView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
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
        
        //Location
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
        
        
//        if let currentUser = Auth.auth().currentUser {
//            nameLabel.text = currentUser.displayName
//
//
//
////            // Retrieving data
////            BASE_DB_REF.observeSingleEvent(of: .value, with: { (snapshot) in
////                for items in snapshot.children.allObjects as! [DataSnapshot] {
////                    let innerItems = items.value as? [String: Any] ?? [:]
////                    for item in innerItems {
////                        print(item.value)
////                        let postInfo = item.value as? [String: Any] ?? [:]
////                        print("\(postInfo["user"]) : \(postInfo["score"])")
////                    }
////
////
////                }
////            })
//        }
        
        if let user = GIDSignIn.sharedInstance()!.currentUser {
            nameLabel.text = "\(user.profile.givenName!) \(user.profile.familyName!)"
            
            // Setting Data
            guard let displayName = Auth.auth().currentUser?.displayName else {
                return
            }
            let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts").child(displayName)
            
            let post: [String : Any] = ["user" : displayName,
                                        "score": defaults.integer(forKey: "localScore"),
                                        "longitude":locationManager.location?.coordinate.longitude,
            "latitude":locationManager.location?.coordinate.latitude,]
            
            
            scoreBar.setProgress(Float(defaults.integer(forKey: "localScore")) / 1000.0, animated: true)
            scoreLabel.text = "Счёт: \(defaults.integer(forKey: "localScore"))/1000"
            POST_DB_REF.setValue(post)
            
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
    
    //Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
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

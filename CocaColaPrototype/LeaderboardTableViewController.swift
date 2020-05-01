//
//  LeaderboardTableViewController.swift
//  CocaColaPrototype
//
//  Created by macbook on 5/1/20.
//  Copyright © 2020 bolattleubayev. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FirebaseStorage

class LeaderboardTableViewController: UITableViewController {

    var leaderNames : [String] = []
    var leaderScores : [Int] = []
    let defaults = UserDefaults.standard
    
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
            navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: customFont]
        }
        
        if let currentUser = Auth.auth().currentUser {
            
            let BASE_DB_REF: DatabaseReference = Database.database().reference()
            
            // Setting Data
            
            guard let displayName = Auth.auth().currentUser?.displayName else {
                return
            }
            let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts").child(displayName)
            
            let post: [String : Any] = ["user" : displayName,
                                        "score": defaults.integer(forKey: "localScore")]
                
            POST_DB_REF.setValue(post)
            
            // Retrieving data
            BASE_DB_REF.observeSingleEvent(of: .value, with: { (snapshot) in
                for items in snapshot.children.allObjects as! [DataSnapshot] {
                    let innerItems = items.value as? [String: Any] ?? [:]
                    for item in innerItems {
                        print(item.value)
                        let postInfo = item.value as? [String: Any] ?? [:]
                        self.leaderNames.append(postInfo["user"]! as! String)
                        self.leaderScores.append((postInfo["score"]! as? Int)!)
                    }
                }
                
                self.tableView.reloadData()
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return leaderNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.imageView!.image = UIImage(named: "person.fill")
        
        
        cell.textLabel?.text = "\(leaderNames[indexPath.row]) \(leaderScores[indexPath.row])"

        return cell
    }
}

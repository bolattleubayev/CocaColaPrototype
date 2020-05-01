//
//  SettingsTableViewController.swift
//  CocaColaPrototype
//
//  Created by macbook on 4/30/20.
//  Copyright © 2020 bolattleubayev. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var gameModeSelector: UISegmentedControl!
    
    @IBAction func gameModeSelectorChanged(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "gameMode")
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
            navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: customFont]
        }
        
        gameModeSelector.selectedSegmentIndex = defaults.integer(forKey: "gameMode")
    }
}

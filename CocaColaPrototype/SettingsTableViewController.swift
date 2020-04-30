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
        gameModeSelector.selectedSegmentIndex = defaults.integer(forKey: "gameMode")
    }
}

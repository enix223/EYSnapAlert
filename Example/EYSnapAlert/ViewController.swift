//
//  ViewController.swift
//  EYSnapAlert
//
//  Created by enix223 on 06/24/2017.
//  Copyright (c) 2017 enix223. All rights reserved.
//

import UIKit
import EYSnapAlert

class ViewController: UITableViewController {

    let styles = ["Fade in fade out", "Popup"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EYSnapAlert.show(message: "世界，你好", onTap: nil, onDimiss: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = styles[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        EYSnapAlert.show(message: String(format: "你好，世界, [Style: %@]", cell.textLabel!.text!),
                         backgroundColor: UIColor.black,
                         textSize: 12,
                         textColor: UIColor.white,
                         duration: 3,
                         cornerRadius: 5,
                         style: .fade,
                         onTap: { (alert) in
                            print("Alert is tap...")
                         },
                         onDimiss: {() in
                            print("Alert was dismissed")
                         })
    }
}


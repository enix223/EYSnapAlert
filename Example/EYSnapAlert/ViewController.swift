//
//  ViewController.swift
//  EYSnapAlert
//
//  Created by enix223 on 06/24/2017.
//  Copyright (c) 2017 enix223. All rights reserved.
//

import UIKit
import EYSnapAlert

class Style {
    let name: String
    let style: EYSnapAlertStyle
    
    init(name: String, style: EYSnapAlertStyle) {
        self.name = name
        self.style = style
    }
}

class ViewController: UITableViewController {

    let styles: [Style] = [
        Style(name: "Fade in & out", style: .fade),
        Style(name: "Popup", style: .popUp),
        Style(name: "Slide in from right", style: .slideInFromRight),
        Style(name: "Slide in from bottom", style: .slideInFromBottom),
        Style(name: "Flip horizontal", style: .flipHorizontal),
        Style(name: "Sticky up", style: .stickyUp)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EYSnapAlert"
        
        // Show alert with default settings
        EYSnapAlert.show(message: "世界，你好")
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
        
        cell?.textLabel?.text = styles[indexPath.row].name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        // Show alert with fully customized setttings
        EYSnapAlert.show(message: String(format: "你好，世界, [Style: %@]", cell.textLabel!.text!),
                         backgroundColor: UIColor.black,
                         textSize: 12,
                         textColor: UIColor.white,
                         duration: 3,
                         animationTime: 0.2,
                         cornerRadius: 5,
                         style: styles[indexPath.row].style,
                         onTap: { (alert) in
                            alert.hide()
                            print("Alert is tap...")
                         },
                         onDimissed: {() in
                            print("Alert was dismissed")
                         })
    }
}


//
//  FirstViewController.swift
//  KDCalendar
//
//  Created by Aliya Tyshkanbayeva on 7/15/16.
//

import UIKit

final class FirstViewController: UIViewController {
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var owlButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mainButton.imageView?.contentMode = .ScaleAspectFit
        mainButton.setImage(UIImage(named: "mainButton"), forState: .Normal)
        settingsButton.setImage(UIImage(named: "settings"), forState: .Normal)
        calendarButton.setImage(UIImage(named: "Calendar"), forState: .Normal)
    
        owlButton.setImage(UIImage(named: "owl"), forState: .Normal)
    }
    
    @IBAction func mainButtonPressed(sender: UIButton) {
    }

    @IBAction func settingsButtonPressed(sender: UIButton) {
    }
    
    @IBAction func calendarButtonPressed(sender: UIButton) {
    }
    
    
    @IBAction func owlButtonPressed(sender: UIButton) {
    }
}

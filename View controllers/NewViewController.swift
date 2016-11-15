//
//  NewViewController.swift
//  GuessThePet
//
//  Created by Zhalgas Baibatyr on 8/1/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

private let revealSequeId = "revealSegue"

class NewViewController: UIViewController {

    var petCard: PetCard?
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet weak var myimage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = petCard?.description
        myimage.image = petCard?.image
        cardView.layer.cornerRadius = 25
        cardView.layer.masksToBounds = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        cardView.addGestureRecognizer(tapRecognizer)
    }

    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == revealSequeId, let destinationViewController = segue.destinationViewController as? RevealViewController {
            destinationViewController.petCard = petCard
        }
        
    }
    
    func handleTap() {
        performSegueWithIdentifier(revealSequeId, sender: nil)
    }

}

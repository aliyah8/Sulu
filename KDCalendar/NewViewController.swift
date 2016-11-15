//
//  NewViewController.swift
//  GuessThePet
//
//
import UIKit

private let revealSequeId = "revealSegue"

class NewViewController: UIViewController {
    
    var petCard: PetCard?
    
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = petCard?.description
        //   mainName.text = petCard?.name
        myImage.image = petCard?.image
        cardView.layer.cornerRadius = 25
        cardView.layer.masksToBounds = true
        let tapRecognizer = UITapGestureRecognizert(target: self, action: #selector(handleTap))
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
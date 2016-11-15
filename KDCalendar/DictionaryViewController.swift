//
//  DictionaryViewController.swift
//  KDCalendar
//
//  Created by Aliya Tyshkanbayeva on 7/15/16.
//

import UIKit

class DictionaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    var definitions : [Definition] = [
        Definition(name: "Что такое цикл?", description: "Менструальный цикл- это время от первого дня месячных до первого дня следующих месячных.", image: "woman2"),
        Definition(name: "Начало цикла.", description: "Первый день месячных и есть начало твоего уникального цикла.В первые дни ты можешь чувствовать себя растроенной по даже мелким причинам.Могут ощущаться боли внизу живота и тягость. Для того чтобы облегчить симптомы обратись в рубрику полезные советы", image: "woman1"),
        Definition(name: "Середина цикла", description: "Твое состояние:  Около двух недель после первого дня месячных у тебя наступает овуляция что значит, самый высокий шанс забеременеть", image: "middle-of-cycle"),
        Definition(name: "Конец цикла" , description: "Твое состояние: Если у тебя не было оплдотворения , то у тебя должны прийти месячные. Но могут опаздать", image: "fitness"),
        Definition(name: "Фертильные дни", description: "Это период максимальной готовности женского организма к оплодотворению", image: "pregnant")]
        
    var advices: [Advices] = [
        Advices(name: "Пей как минимум 8 стаканов теплой или горячей воды", emptyname: "", image: "water"),
        Advices(name: "Молочные продукты и зелень такие как шпина содержат кальции который поможет уменьшить боль", emptyname: "", image: "moloko"),
        Advices(name: "Положи грелку или горячее полотенце когда тянет низ живота", emptyname: "",  image: "грелка1"),
        Advices(name: "Старайся не есть вредную пищу такие как картошка фри гамбергеры сладкое это усиливает вздутие живота и отеки не пить кофе алкоголь", emptyname: "", image: "junkfood"),
        Advices(name: "Ромашковый или любой другой чай с мятой к вечеру успокаивает", emptyname: "", image: "romasha"),
        Advices(name: "Поделай легкую зарядку или растяжку", emptyname: "", image: "fitness")
    ]
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {                                                         
   var returnValue = 0
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 1:
            returnValue = definitions.count
            break
        case 0:
      //      returnValue = advises.count
            returnValue = advices.count

            break
        default:
            break
            
        }
            //return definitions.count
        return returnValue
    }
    
   
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as! DefinitionTableViewCell
        
       
        
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 1:
            myCell.nameLabel.text = definitions[indexPath.row].name
            myCell.nameLabel.font = UIFont(name: "Helvetica", size: 16.0)
            myCell.nameLabel.textColor = UIColor(red: 228.0 / 255.0, green: 84.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0)
            myCell.definitionLabel.text = definitions[indexPath.row].description
            myCell.imageView?.image = UIImage(named: definitions[indexPath.row].image!)
            
            break
        case 0:
            myCell.nameLabel.text = advices[indexPath.row].emptyname
            myCell.definitionLabel.text = advices[indexPath.row].name
            myCell.definitionLabel.font = UIFont(name: "Helvetica", size: 16.0)
            myCell.definitionLabel.textColor = UIColor(red: 228.0 / 255.0, green: 84.0 / 255.0, blue: 144.0 / 255.0, alpha: 1.0)
            myCell.imageView?.image = UIImage(named: advices[indexPath.row].image!)
            
            // local notification
            
            // return advices count
            break
        default:
            break
            
        }
        
        return myCell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func backButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func segmentedControlActionChanged(sender: AnyObject) {
        
        myTableView.reloadData()
    }
   
}

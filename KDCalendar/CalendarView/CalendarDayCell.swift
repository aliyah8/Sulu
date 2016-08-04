//
//  KDCalendarDayCell.swift
//  KDCalendar
//
//

import UIKit

let cellColorDefault = UIColor(red: 207.0 / 255.0, green: 238.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0)
let cellColorToday = UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.3)
let borderColor = UIColor(red: 242.0 / 255.0, green: 138.0 / 255.0, blue: 208.0 / 255.0, alpha: 0.76)
    //UIColor.blueColor()
    //UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.8)

class CalendarDayCell: UICollectionViewCell {
    /*
    var cellType = 0 {
        didSet {
            for ims in self.imgUser.subviews {
                ims.removeFromSuperview()
                if {
                } else {
                
                }
                ////
            }
        
        }
    }
 */

    
       // when raindrop, when flowers
    
    var eventsCount = 0 {
        didSet {
            for sview in self.dotsView.subviews {
                sview.removeFromSuperview()
            }
            
            let stride = self.dotsView.frame.size.width / CGFloat(eventsCount+1)
            let viewHeight = self.dotsView.frame.size.height
            let halfViewHeight = viewHeight / 2.0
            
            for _ in 0..<eventsCount {
                let frm = CGRect(x: (stride+1.0) - halfViewHeight, y: 0.0, width: viewHeight, height: viewHeight)
                
                let imageview:UIImageView=UIImageView(frame: frm);
                let image: UIImage = UIImage(named: "fertile")!
                imageview.image = image
               }
        }
    }
    
    var isToday : Bool = false {
        
        didSet {
           
            if isToday == true {
                self.pBackgroundView.backgroundColor = cellColorToday
            }
            else {
                self.pBackgroundView.backgroundColor = cellColorDefault
            }
        }
    }
    
    override var selected : Bool {
        
        didSet {
            
            if selected == true {
                self.pBackgroundView.layer.borderWidth = 10.0
                
            }
            else {
                self.pBackgroundView.layer.borderWidth = 0.0
            }
            
        }
    }
    
    var flower: Bool = false {
        didSet {
            flowerImageView.hidden = !flower
        }
    }
    
     lazy var pBackgroundView : UIView = {
        
        var vFrame = CGRectInset(self.frame, 6.0, 6.0)
        
        let view = UIView(frame: vFrame)
        
        view.layer.cornerRadius = 20.0

        
        view.layer.borderColor = borderColor.CGColor
        view.layer.borderWidth = 0.0
        
        view.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        
        view.backgroundColor = cellColorDefault
        
        
        return view
    }()
   var imgUser = UIImageView();
    /*
    lazy var imgUser = UIImageView() {
    let img = UIImage()
        img.translatesAutorecizingMaskIntoConstraints = false
        let imageview:UIImageView=UIImageView(frame: frm);
        let image: UIImage = UIImage(named: "fertile")!
        imageview.image = image
        
    
    }()
  */
    // self.view.addSubview(imageview)
    /*
    lazy var imgUser = UIImageView(){
    
        let img = UIImage()
        img.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(img)
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[img]", options: [], metrics: nil, views: viewsDict))


    }
 */
    
    
    //var image
    lazy var textLabel : UILabel = {
       
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.Center
        lbl.textColor = UIColor(red: 151.0 / 255.0, green: 148.0 / 255.0, blue: 148.0 / 255.0, alpha: 1.0)
        
        return lbl
        
    }()
    
    lazy var dotsView : UIView = {
        
        let frm = CGRect(x: 8.0, y: self.frame.size.width - 10.0 - 4.0, width: self.frame.size.width - 16.0, height: 12.0)
      //  self.layer.cornerRadius = frm.size.width/2

        let dv = UIView(frame: frm)
        
        
        return dv
        
    }()

    let flowerImageView = UIImageView()
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        flowerImageView.hidden = true
        flowerImageView.image = UIImage(named: "fertile")
        contentView.addSubview(flowerImageView)

        
        self.addSubview(self.pBackgroundView)
        
        self.textLabel.frame = self.bounds
        self.addSubview(self.textLabel)
        //self.addSubview(self.imgUser)
        self.addSubview(dotsView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        flowerImageView.hidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        flowerImageView.frame = contentView.frame
    }
}

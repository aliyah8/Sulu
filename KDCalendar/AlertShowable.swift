//
//  AlertShowable.swift
//  KDCalendar
//
//  Created by Aliya Tyshkanbayeva on 7/28/16.
//  Copyright © 2016 Karmadust. All rights reserved.
//

import UIKit

protocol AlertShowable {
    func confirmationButtonTapped()
}

extension AlertShowable where Self: UIViewController {
    func alertController(title: String, message: String, isBackButton: Bool) {
        let alertController = UIAlertController(title: "Обновить", message: "Вы уверены что хотите обновить данные?", preferredStyle: .Alert)
        
        if isBackButton {
            alertController.addAction(UIAlertAction(title: "Отмена", style: .Default, handler: nil))
        }
        
        alertController.addAction(UIAlertAction(title: "Да", style: .Cancel) { _ in
            self.confirmationButtonTapped()
            })
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}


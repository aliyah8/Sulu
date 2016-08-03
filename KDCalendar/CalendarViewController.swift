//
//  CalendarViewController.swift
//  KDCalendar
//
//

import UIKit
import EventKit

final class CalendarViewController: UIViewController {
    private let cycle = 28
    
    @IBOutlet private weak var calendarView: CalendarView! {
        didSet {
            calendarView.dataSource = self
            calendarView.delegate = self
            calendarView.direction = .Horizontal
        }
    }
 var userIsInTheMiddleOfTyping = false
//var startDatee =
    
    
    var counter = 0
    
    private var selectedDates: (startDate: NSDate?, endDate: NSDate?)? {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(selectedDates?.startDate, forKey: "startDate")
            defaults.setObject(selectedDates?.endDate, forKey: "endDate")
            defaults.synchronize()
            
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            
            if let oldStartDate = oldValue?.startDate,
                oldEndDate = oldValue?.endDate {
                    let oldDateRange = DateRange(calendar: calendar, startDate: oldStartDate.dayBefore, endDate: oldEndDate, stepUnits: .Day, stepValue: 1)
                    oldDateRange.forEach { self.calendarView.deselectDate($0) }
            }
            
            guard let startDate = selectedDates?.startDate,
                endDate = selectedDates?.endDate else { return }
            
            let dateRange = DateRange(calendar: calendar, startDate: startDate.dateByAddingDays(-1), endDate: endDate,
                                      stepUnits: .Day, stepValue: 1)
            
            dateRange.forEach { self.calendarView.selectDate($0) }
           
        guard let startFlowerDate = selectedDates?.endDate?.dateByAddingDays(0),
            endFlowerDate = selectedDates?.startDate?.dateByAddingDays(16) else { return }
            let flowerRange = DateRange(calendar: calendar, startDate: startFlowerDate, endDate: endFlowerDate, stepUnits: .Day, stepValue: 1)
           
print(flowerRange)
    /*      flowerRange.forEach { (self.calendarView.collect) in
            
            }
    */
            
         //   flowerRange.forEach { self.calendarView.collectionView(UICollectionView, cellForItemAtIndexPath: NSIndexPath)}
                //self.calendarView.selectDate($0) }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadEventsInCalendar()
        
        let dateComponents = NSDateComponents()
        dateComponents.day = -5
        
        let today = NSDate()
        
        if let date = calendarView.gregorian.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions()) {
            self.calendarView.selectDate(date)
            calendarView.userInteractionEnabled = true
            self.calendarView.deselectDate(date)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var startDatee: NSDate?
        var endDatee: NSDate?
        
        if defaults.objectForKey("startDate") != nil {
            startDatee = defaults.objectForKey("startDate") as? NSDate
        }
        if defaults.objectForKey("endDate") != nil {
            endDatee = defaults.objectForKey("endDate") as? NSDate
        }
        
        defaults.synchronize()
        
        selectedDates = (startDate: startDatee, endDate: endDatee)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = view.frame.size.width - 16.0 * 2
        let height = width + 20.0
        let navigationBarHeight: CGFloat = navigationController?.navigationBar.bounds.height ?? 0
        let statusBarHeight: CGFloat = 20
        
        calendarView.frame = CGRect(x: 16.0, y: navigationBarHeight + statusBarHeight,
                                    width: width, height: height)
    }
    
    func loadEventsInCalendar() {
        guard let startDate = startDate(), endDate = endDate() else { return }
        
        let store = EKEventStore()
        let fetchEvents = {
            let predicate = store.predicateForEventsWithStartDate(startDate, endDate:endDate, calendars: nil)
            if let eventsBetweenDates = store.eventsMatchingPredicate(predicate) as [EKEvent]? {
                self.calendarView.events = eventsBetweenDates
            }
        }
        
        if EKEventStore.authorizationStatusForEntityType(.Event) != .Authorized {
            store.requestAccessToEntityType(.Event) { granted, _ in
                if granted { fetchEvents() }
            }
        } else {
            fetchEvents()
        }
    }
   
    @IBAction func doneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        alertController("Обновить", message: "Вы уверены что хотите обновить данные?", isBackButton: true)
    }
}

extension CalendarViewController: CalendarViewDataSource, CalendarViewDelegate, UICollectionViewDelegate{
    func startDate() -> NSDate? {
        calendarView.userInteractionEnabled = true
        
        let dateComponents = NSDateComponents()
        dateComponents.month = -3
        return calendarView.gregorian.dateByAddingComponents(dateComponents, toDate: NSDate(), options: NSCalendarOptions())
    }
    
    func endDate() -> NSDate? {
        calendarView.userInteractionEnabled = true
        
        let dateComponents = NSDateComponents()
        dateComponents.year = 2;
        return self.calendarView.gregorian.dateByAddingComponents(dateComponents, toDate: NSDate(), options: NSCalendarOptions())
    }
    
    private func onDateSelect(date: NSDate) {
        guard let selectedDates = selectedDates else {
            self.selectedDates = (date, nil)
            return
        }
        //    if startDate.monthsFrom(startDate) == startDate.dateByAddingDays(numberOfDays).monthsFrom(startDate.dateByAddingDays(numberOfDays)) {

        
        if let startDate = selectedDates.startDate, endDate = selectedDates.startDate {
            if date.day < startDate.day {
                self.selectedDates?.startDate = date
            } else if date.day > startDate.day || date.day > endDate.day || date.day < endDate.day {
                self.selectedDates?.endDate = date
            }
        } else if let _ = selectedDates.startDate {
            self.selectedDates?.endDate = date
        } else {
            self.selectedDates = (date, nil)
        }
    }
    
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [EKEvent]) {
        onDateSelect(date)
       // flowering(date)
        guard let startDate = selectedDates?.startDate,
            endDate = selectedDates?.endDate else { return }
        let numberOfDays = startDate < date ? cycle : -cycle
        selectedDates = (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays))
        if startDate.monthsFrom(startDate.dateByAddingDays(numberOfDays)) == 0 || endDate.monthsFrom(startDate.dateByAddingDays(numberOfDays)) == 0 {
            //  let selectedDates = (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays)),
             let selectedDates = [
                (startDate, endDate),
                (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays)) ]
        }
    }
    
    func calendar(calendar: CalendarView, didDeselectDate date: NSDate) {
        onDateSelect(date)
    }
    
    func calendar(calendar: CalendarView, didScrollToMonth date : NSDate) {
        
        counter += 1
        if counter % 2 == 0 {
            guard let startDate = selectedDates?.startDate,
                endDate = selectedDates?.endDate else { return }
            let numberOfDays = startDate < date ? cycle : -cycle
            selectedDates = (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays))
            if startDate.monthsFrom(startDate.dateByAddingDays(numberOfDays)) == 0 || endDate.monthsFrom(startDate.dateByAddingDays(numberOfDays)) == 0 {
                //  let selectedDates = (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays)),
                let selectedDates = [
                    (startDate, endDate),
                    (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays)) ]
            }
        }
}
}

extension CalendarViewController: AlertShowable {
    func confirmationButtonTapped() {
        selectedDates = nil
    }
}

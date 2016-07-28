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
    
    private var selectedDates: (startDate: NSDate?, endDate: NSDate?)? {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(selectedDates?.startDate, forKey: "firstRedDay")
            defaults.setObject(selectedDates?.endDate, forKey: "lastRedDay")
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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let firstRedDay = defaults.objectForKey("firstRedDay") as? NSDate,
            lastDay = defaults.objectForKey("lastRedDay") as? NSDate?
            else { return }
        
        calendarView.firstRedDay =  firstRedDay
        calendarView.lastRedDay = lastDay
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

extension CalendarViewController: CalendarViewDataSource, CalendarViewDelegate {
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
    
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [EKEvent]) {
        selectedDates = (calendarView.firstRedDay, calendarView.lastRedDay)
    }
    
    func calendar(calendar: CalendarView, didScrollToMonth date : NSDate) {
        
    }
}

extension CalendarViewController: AlertShowable {
    func confirmationButtonTapped() {
        calendarView.firstRedDay = nil
        calendarView.lastRedDay = nil
        selectedDates = nil
        calendarView.removeSelectedDates()
    }
}

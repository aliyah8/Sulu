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
            
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            
            if let oldStartDate = oldValue?.startDate,
                oldEndDate = oldValue?.endDate {
                let oldDateRange = DateRange(calendar: calendar, startDate: oldStartDate.dayBefore, endDate: oldEndDate,
                                             stepUnits: .Day, stepValue: 1)
                oldDateRange.forEach { self.calendarView.deselectDate($0) }
            }
            
            guard let startDate = selectedDates?.startDate,
                endDate = selectedDates?.endDate else { return }
            
            let dateRange = DateRange(calendar: calendar, startDate: startDate, endDate: endDate,
                                      stepUnits: .Day, stepValue: 1)
            
            dateRange.forEach { self.calendarView.selectDate($0) }
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
    
    private func onDateSelect(date: NSDate) {
        guard let selectedDates = selectedDates else {
            self.selectedDates = (date, nil)
            return
        }
        
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
    }
    
    func calendar(calendar: CalendarView, didDeselectDate date: NSDate) {
        onDateSelect(date)
    }
    
    func calendar(calendar: CalendarView, didScrollToMonth date : NSDate) {
        guard let startDate = selectedDates?.startDate,
            endDate = selectedDates?.endDate else { return }
        let numberOfDays = startDate < date ? cycle : -cycle
        selectedDates = (startDate.dateByAddingDays(numberOfDays), endDate.dateByAddingDays(numberOfDays))
        
    }
}

extension CalendarViewController: AlertShowable {
    func confirmationButtonTapped() {
        selectedDates = nil
    }
}

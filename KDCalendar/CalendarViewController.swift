//
//  CalendarViewController.swift
//  KDCalendar
//
//

import UIKit
import EventKit

final class CalendarViewController: UIViewController {
    private let cycle = 28
    private var previousDate: NSDate?
    
    @IBOutlet private weak var calendarView: CalendarView! {
        didSet {
            calendarView.dataSource = self
            calendarView.delegate = self
            calendarView.direction = .Horizontal
        }
    }
    
    private var selectedDates: [(startDate: NSDate?, endDate: NSDate?)]? {
        didSet {
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            oldValue?.forEach {
                guard let oldStartDate = $0.startDate,
                    oldEndDate = $0.endDate else { return }
                
                let oldDateRange = DateRange(calendar: calendar, startDate:
                    oldStartDate.dayBefore, endDate: oldEndDate, stepUnits: .Day, stepValue: 1)
                oldDateRange.forEach { self.calendarView.deselectDate($0) }
                
                let startFlowerDate = oldEndDate.dateByAddingDays(0),
                endFlowerDate = oldStartDate.dateByAddingDays(16)
                let flowerRange = DateRange(calendar: calendar, startDate: startFlowerDate, endDate: endFlowerDate, stepUnits: .Day, stepValue: 1)
                
                flowerRange.forEach{ flower in
                    calendarView.unflowerDate(flower)
                }
            }
          
            selectedDates?.forEach {
                guard let startDate = $0.startDate,
                    endDate = $0.endDate else { return }
                let dateRange = DateRange(calendar: calendar, startDate: startDate.dayBefore,
                    endDate: endDate, stepUnits: .Day, stepValue: 1)
                
                let startFlowerDate = endDate.dateByAddingDays(0),
                    endFlowerDate = startDate.dateByAddingDays(16)
                let flowerRange = DateRange(calendar: calendar, startDate: startFlowerDate, endDate: endFlowerDate, stepUnits: .Day, stepValue: 1)
                //saving data
               // let defaults = NSUserDefaults.standardUserDefaults()
                //defaults.setObject(startFlowerDate, forKey: "startFlowerDate")
              //  defaults.setObject(endFlowerDate, forKey: "endFlowerDate")
                
                flowerRange.forEach{ flower in
                    dispatch_async(dispatch_get_main_queue()) {
                    self.calendarView.flowerDate(flower)
                    }
                }
            
                dateRange.forEach { date in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.calendarView.selectDate(date)
                    }
                }
            }
        }
    }
        override func viewDidLoad() {
        super.viewDidLoad()
        
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
            lastRedDay = defaults.objectForKey("lastRedDay") as? NSDate
            else { return }
        selectedDates = [(firstRedDay, lastRedDay), generateNextDates(firstRedDay, lastRedDay)]
            
           // guard let startFlowerDate = defaults.objectForKey("startFlowerDate") as? NSDate,
        //    endFlowerDate = defaults.objectForKey("endFlowerDate") as? NSDate
            //     else {return}

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
        guard var firstSelectedDates = selectedDates?.first else {
            // first 
            Drop.down("Первый день цикла добавился", state: .Success)
            
            self.selectedDates = [(date, nil)]
            return
        }
            Drop.down("Последний день цикла добавился", state: .Success)
            // second
        if let startDate = firstSelectedDates.startDate, endDate = firstSelectedDates.startDate {
            if date.day < startDate.day {
                firstSelectedDates.startDate = date
            } else if date.day > startDate.day || date.day > endDate.day {
                firstSelectedDates.endDate = date
            }
        
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(firstSelectedDates.startDate, forKey: "firstRedDay")
            defaults.setObject(firstSelectedDates.endDate, forKey: "lastRedDay")
            defaults.synchronize()
        
            
        } else if let _ = firstSelectedDates.startDate {
            firstSelectedDates.endDate = date
        } else {
            firstSelectedDates = (date, nil)
        }
        
        //selectedDates?.insert(firstSelectedDates, atIndex: 0)
            
        selectedDates = [firstSelectedDates]
        if let startDate = firstSelectedDates.startDate, endDate = firstSelectedDates.endDate {
            selectedDates?.append(generateNextDates(startDate, endDate))
        }
    }
    private func generateNextDates(intialStartDate: NSDate, _ intialEndDate: NSDate, negative: Bool = false) -> (NSDate?, NSDate?) {
        let endStartDateDaysDelta = intialEndDate.daysFrom(intialStartDate)
        let newStartDate = intialStartDate.dateByAddingDays(negative ? -cycle : cycle)
        let newEndDate = newStartDate.dateByAddingDays(endStartDateDaysDelta)
        return (newStartDate, newEndDate)
    }
    
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [EKEvent]) {
        onDateSelect(date)
    }
    
    func calendar(calendar: CalendarView, didDeselectDate date: NSDate) {
        onDateSelect(date)
    }
    
    func calendar(calendar: CalendarView, didScrollToMonth date : NSDate) {
        let date2 = date.dateByAddingDays(1).dateByAddingOneMonth().dateByAddingDays(1)
        var selectedDates = self.selectedDates
        while let firstEndDate = selectedDates?.first?.endDate,
            secondStartDate = selectedDates?.last?.startDate, secondEndDate = selectedDates?.last?.endDate
            where firstEndDate < date || firstEndDate == date {

            let newStartDate = secondStartDate.dateByAddingDays(cycle)
            let newEndDate = secondEndDate.dateByAddingDays(cycle)
            
            selectedDates = [(secondStartDate, secondEndDate), (newStartDate, newEndDate)]
            
        }
        
        while let firstStartDate = selectedDates?.first?.startDate, firstEndDate = selectedDates?.first?.endDate,
            secondStartDate = selectedDates?.last?.startDate
            where secondStartDate > date2 || secondStartDate == date2 {

                let newStartDate = firstStartDate.dateByAddingDays(-cycle)
                let newEndDate = firstEndDate.dateByAddingDays(-cycle)

                selectedDates = [(newStartDate, newEndDate), (firstStartDate, firstEndDate)]
                
        }
        
        self.calendarView.unflowerAll()
        self.calendarView.deselectAll()
        self.selectedDates?.removeAll()
        self.selectedDates = selectedDates
        
//        guard let previousDate = previousDate,
//            firstStartDate = selectedDates?.first?.startDate,
//            firstEndDate = selectedDates?.first?.endDate,
//            secondStartDate = selectedDates?.last?.startDate,
//            secondEndDate = selectedDates?.last?.endDate
//            where previousDate.month != date.month else {
//                self.previousDate = date
//                return
//        }
        
//        if previousDate < date {
//            
//            while let tmp = selectedDates?.last?.startDate where tmp.dateByAddingDays(cycle).month == date.month {
//                let newStartDate = secondStartDate.dateByAddingDays(cycle)
//                let newEndDate = secondEndDate.dateByAddingDays(cycle)
//                
//                selectedDates = [(secondStartDate, secondEndDate), (newStartDate, newEndDate)]
//                
//            }
//            
//            print ("generated next month\n\(selectedDates?.first)\n\(selectedDates?.last)\n")
//        } else {
//            let numberOfDays = -cycle
//            let newStartDate = secondStartDate.dateByAddingDays(numberOfDays)
//            let newEndDate = secondEndDate.dateByAddingDays(numberOfDays)
//            
//            selectedDates = [generateNextDates(newStartDate, newEndDate, negative: true), (firstStartDate, firstEndDate)]
//            print ("generated previous month\n\(selectedDates?.first)\n\(selectedDates?.last)\n")
//        }
//        
//        self.previousDate = date
        
        
        
//        let numberOfDays = startDate < date ? cycle : -cycle
//        let newStartDate = startDate.dateByAddingDays(numberOfDays)
//        let newEndDate = endDate.dateByAddingDays(numberOfDays)
//        
//        selectedDates = numberOfDays > 0
//            ? [(startDate, endDate), (newStartDate, newEndDate)]
//            : [generateNextDates(newStartDate, newEndDate, negative: true), (newStartDate, newEndDate)]
    }
}

extension CalendarViewController: AlertShowable {
    func confirmationButtonTapped() {
        calendarView.unflowerAll()
        calendarView.deselectAll()
        selectedDates?.removeAll()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("firstRedDay")
        defaults.removeObjectForKey("lastRedDay")
        defaults.synchronize()
    }
}

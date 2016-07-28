//
//  KDCalendarView.swift
//  KDCalendar
//
//

import UIKit
import EventKit

private let cellReuseIdentifier = "CalendarDayCell"

private let NUMBER_OF_DAYS_IN_WEEK = 7
private let MAXIMUM_NUMBER_OF_ROWS = 6

private let HEADER_DEFAULT_HEIGHT: CGFloat = 100.0
private let FIRST_DAY_INDEX = 0
private let NUMBER_OF_DAYS_INDEX = 1
private let DATE_SELECTED_INDEX = 2
private let fertileDaysCount = 17
private let cycle = 28

extension EKEvent {
    var isOneDay: Bool {    
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([.Era, .Year, .Month, .Day], fromDate: startDate, toDate: endDate, options: NSCalendarOptions())
        return components.era == 0 && components.year == 0 && components.month == 0 && components.day == 0
    }
}

@objc protocol CalendarViewDataSource {
    func startDate() -> NSDate?
    func endDate() -> NSDate?
}

@objc protocol CalendarViewDelegate {
    func calendar(calendar: CalendarView, didScrollToMonth date: NSDate) -> Void
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [EKEvent]) -> Void
    optional func calendar(calendar: CalendarView, didDeselectDate date: NSDate) -> Void
    optional func calendar(calendar: CalendarView, canSelectDate date: NSDate) -> Bool
}

final class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var dataSource: CalendarViewDataSource?
    var delegate: CalendarViewDelegate?

    var firstRedDay: NSDate?
    var lastRedDay: NSDate? {
        didSet {
            if let firstRedDay = firstRedDay, lastRedDay = lastRedDay {
                let dayComponent = NSDateComponents()
                dayComponent.hour = 1
                gregorian.enumerateDatesStartingAfterDate(firstRedDay, matchingComponents: dayComponent, options: [.MatchStrictly]) { date, exactMatch, stop in
                    if let date = date { self.selectDate(date) }
                    
                    if date!.compare(lastRedDay) == .OrderedDescending {
                        stop.memory = true
                        self.calendarView.reloadData()
                    }
                }
            }
        }
    }
    
    var flowerIndexPaths: [NSIndexPath] {
        guard let firstRedDay = firstRedDay else { return [] }
        let dayComponent = NSDateComponents()
        dayComponent.hour = 1
        var flowerIndexPaths = [NSIndexPath]()
        var counter = 0
        
        gregorian.enumerateDatesStartingAfterDate(firstRedDay, matchingComponents: dayComponent, options: [.MatchStrictly]) { date, exactMatch, stop in
            if let date = date, indexPath = self.indexPathForDate(date) {
                flowerIndexPaths.append(indexPath)
                counter += 1
            }
            if counter == fertileDaysCount {
                stop.memory = true
            }
        }
        return flowerIndexPaths
    }
    
    var direction = UICollectionViewScrollDirection.Horizontal {
        didSet {
            guard let layout = self.calendarView.collectionViewLayout
                as? CalendarFlowLayout else { return }
            layout.scrollDirection = direction
            dispatch_async(dispatch_get_main_queue()) {
                self.calendarView.reloadData()
            }
        }
    }
    
    lazy var gregorian : NSCalendar = {
        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!
        return cal
    }()
    private var startDateCache = NSDate()
    private var endDateCache = NSDate()
    private var startOfMonthCache = NSDate()
    private var todayIndexPath: NSIndexPath?
    var displayDate: NSDate?
    
    private(set) var selectedIndexPaths: [NSIndexPath] = [NSIndexPath]()
    private(set) var selectedDates: [NSDate] = [NSDate]()
    
    func removeSelectedDates() {
        selectedDates.removeAll()
        selectedIndexPaths.removeAll()
        calendarView.reloadData()
    }
    
    private var eventsByIndexPath : [NSIndexPath:[EKEvent]] = [NSIndexPath:[EKEvent]]()
    
    var events : [EKEvent]? {
        didSet {
            eventsByIndexPath = [NSIndexPath:[EKEvent]]()
            
            guard let events = events else { return }
            
            let secondsFromGMTDifference = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)

            events.forEach {
                if !$0.isOneDay { return }
                
                let startDate = $0.startDate.dateByAddingTimeInterval(secondsFromGMTDifference)
                
                // Get the distance of the event from the start
                let distanceFromStartComponent = self.gregorian.components([.Month, .Day],
                    fromDate:startOfMonthCache, toDate: startDate, options: NSCalendarOptions())
                
                let indexPath = NSIndexPath(forItem: distanceFromStartComponent.day, inSection: distanceFromStartComponent.month)
                
                if var eventsList = eventsByIndexPath[indexPath] { // If we have initialized a list for this IndexPath
                    eventsList.append($0)
                } else {
                    eventsByIndexPath[indexPath] = [$0]
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.calendarView.reloadData()
            }
        }
    }
    
    lazy var headerView : CalendarHeaderView = {
        return CalendarHeaderView(frame: .zero)
    }()
    
    lazy var calendarView : UICollectionView = {
        let layout = CalendarFlowLayout()
        layout.scrollDirection = self.direction
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.pagingEnabled = true
        cv.backgroundColor = .clearColor()
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.allowsMultipleSelection = true
        
        cv.registerClass(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        return cv
    }()
    
    override var frame: CGRect {
        didSet {
            let height = frame.size.height
            let width = frame.size.width
            
            headerView.frame   = CGRect(x:0.0, y:0.0, width: frame.size.width, height:HEADER_DEFAULT_HEIGHT)
            calendarView.frame = CGRect(x:0.0, y:HEADER_DEFAULT_HEIGHT, width: width, height: height)
            
            guard let layout = calendarView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            layout.itemSize = CGSize(width: width / CGFloat(NUMBER_OF_DAYS_IN_WEEK),
                                     height: height / CGFloat(MAXIMUM_NUMBER_OF_ROWS))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame : CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
        [headerView, calendarView].forEach { self.addSubview($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        [headerView, calendarView].forEach { self.addSubview($0) }
    }

    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let startDate = dataSource?.startDate(), endDate = dataSource?.endDate() else {
                return 0
        }
       
        startDateCache = startDate
        endDateCache = endDate
        
        // check if the dates are in correct order
        if gregorian.compareDate(startDate, toDate: endDate,
                                 toUnitGranularity: .Nanosecond) != .OrderedAscending {
            return 0
        }
        
        
        let firstDayOfStartMonth = gregorian.components( [.Era, .Year, .Month], fromDate: startDateCache)
        firstDayOfStartMonth.day = 1
        
        guard let dateFromDayOneComponents = gregorian.dateFromComponents(firstDayOfStartMonth) else {
            return 0
        }
        
        startOfMonthCache = dateFromDayOneComponents
        
        let today = NSDate()
        
        if  startOfMonthCache.compare(today) == .OrderedAscending &&
            endDateCache.compare(today) == .OrderedDescending {
            
            let differenceFromTodayComponents = gregorian.components([.Month, .Day], fromDate: startOfMonthCache,
                                                                     toDate: today, options: NSCalendarOptions())
            
            todayIndexPath = NSIndexPath(forItem: differenceFromTodayComponents.day, inSection: differenceFromTodayComponents.month)
        }
        
        let differenceComponents = gregorian.components(.Month, fromDate: startDateCache, toDate: endDateCache, options: NSCalendarOptions())
        
        return differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
        
    }
    
    var monthInfo : [Int:[Int]] = [Int:[Int]]()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthOffsetComponents = NSDateComponents()
        monthOffsetComponents.month = section;
        
        guard let correctMonthForSectionDate = gregorian.dateByAddingComponents(monthOffsetComponents,
                                                                                toDate: startOfMonthCache, options: NSCalendarOptions()) else {
            return 0
        }
        
        let numberOfDaysInMonth = gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: correctMonthForSectionDate).length
        
        var firstWeekdayOfMonthIndex = gregorian.component(.Weekday, fromDate: correctMonthForSectionDate)
        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex - 1 + 6) % 7
        
        monthInfo[section] = [firstWeekdayOfMonthIndex, numberOfDaysInMonth]
        
        return NUMBER_OF_DAYS_IN_WEEK * MAXIMUM_NUMBER_OF_ROWS
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dayCell = collectionView.dequeueReusableCellWithReuseIdentifier(
            cellReuseIdentifier, forIndexPath: indexPath) as! CalendarDayCell
        
        let currentMonthInfo = monthInfo[indexPath.section]! // we are guaranteed an array by the fact that we reached this line (so unwrap)
        
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        
        let fromStartOfMonthIndexPath = NSIndexPath(forItem: indexPath.item - fdIndex, inSection: indexPath.section) // if the first is wednesday, add 2
        
        if indexPath.item >= fdIndex && indexPath.item < fdIndex + nDays {
            dayCell.textLabel.text = String(fromStartOfMonthIndexPath.item + 1)
            dayCell.hidden = false
        } else {
            dayCell.textLabel.text = ""
            dayCell.hidden = true
        }
        
        //redDayIndexPaths
        dayCell.selected = selectedIndexPaths.contains(indexPath)
        
        if !dayCell.selected && flowerIndexPaths.contains(indexPath) {
            dayCell.flowerImageView.hidden = false
        }
        
        if indexPath.section == 0 && indexPath.item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        
        if let idx = todayIndexPath {
            dayCell.isToday = (idx.section == indexPath.section && idx.item + fdIndex == indexPath.item)
        }
        
        return dayCell
    }
    
        
    // MARK: UIScrollViewDelegate
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        calculateDateBasedOnScrollViewPosition(scrollView)
    }

    func calculateDateBasedOnScrollViewPosition(scrollView: UIScrollView) {
        let cvbounds = self.calendarView.bounds
        
        var page = Int(floor(self.calendarView.contentOffset.x / cvbounds.size.width))
        page = page > 0 ? page : 0
        
        let monthsOffsetComponents = NSDateComponents()
        monthsOffsetComponents.month = page
        
        guard let delegate = delegate,
            yearDate = gregorian.dateByAddingComponents(monthsOffsetComponents,
                                                        toDate: startOfMonthCache,
                                                        options: NSCalendarOptions()) else { return }
        
        let month = gregorian.component(.Month, fromDate: yearDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12]
        let year = self.gregorian.component(NSCalendarUnit.Year, fromDate: yearDate)

        headerView.monthLabel.text = "\(monthName) \(year)"
        displayDate = yearDate
        delegate.calendar(self, didScrollToMonth: yearDate)
    }

    // MARK: UICollectionViewDelegate
    
    private var dateBeingSelectedByUser: NSDate?
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
        let firstDayInMonth = currentMonthInfo[FIRST_DAY_INDEX]
        
        let offsetComponents = NSDateComponents()
        offsetComponents.month = indexPath.section
        offsetComponents.day = indexPath.item - firstDayInMonth
  
        if let dateUserSelected = gregorian.dateByAddingComponents(offsetComponents, toDate: startOfMonthCache, options: NSCalendarOptions()) {
            dateBeingSelectedByUser = dateUserSelected
            return delegate?.calendar?(self, canSelectDate: dateUserSelected) ?? true
        }
        
        return false // if date is out of scope
    }
    
    func selectDate(date: NSDate) {
        guard let indexPath = self.indexPathForDate(date)
            where !(calendarView.indexPathsForSelectedItems()?.contains(indexPath) ?? true) else {
                return
        }
        
        calendarView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        selectedIndexPaths.append(indexPath)
        selectedDates.append(date)
    }
    
    func deselectDate(date: NSDate) {
        guard let indexPath = self.indexPathForDate(date)
            where calendarView.indexPathsForSelectedItems()?.contains(indexPath) ?? false else {
                return
        }

        calendarView.deselectItemAtIndexPath(indexPath, animated: true)
        
        guard let index = selectedIndexPaths.indexOf(indexPath) else {
            return
        }

        selectedIndexPaths.removeAtIndex(index)
        selectedDates.removeAtIndex(index)
    }
    
    func indexPathForDate(date: NSDate) -> NSIndexPath? {
        let distanceFromStartComponent = gregorian.components([.Month, .Day], fromDate:startOfMonthCache,
                                                               toDate: date, options: NSCalendarOptions())
        
        guard let currentMonthInfo: [Int] = monthInfo[distanceFromStartComponent.month] else {
            return nil
        }
        
        let item = distanceFromStartComponent.day + currentMonthInfo[FIRST_DAY_INDEX]
        let indexPath = NSIndexPath(forItem: item, inSection: distanceFromStartComponent.month)
        
        return indexPath
    }
    
    var prevSelectedDate: NSDate?
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else { return }
        
        if let prevSelectedDate = prevSelectedDate
            where prevSelectedDate.earlierDate(dateBeingSelectedByUser) == prevSelectedDate {
            self.firstRedDay = prevSelectedDate

            let dayComponent = NSDateComponents()
            dayComponent.hour = 1
            gregorian.enumerateDatesStartingAfterDate(prevSelectedDate, matchingComponents: dayComponent, options: [.MatchStrictly]) { date, exactMatch, stop in
                if let date = date {
                    self.selectDate(date)
                }
                if date!.compare(dateBeingSelectedByUser) == .OrderedDescending {
                    stop.memory = true
                    collectionView.reloadData()
                }
            }
        }
        
        prevSelectedDate = dateBeingSelectedByUser
        
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
    
        let fromStartOfMonthIndexPath = NSIndexPath(forItem: indexPath.item - currentMonthInfo[FIRST_DAY_INDEX], inSection: indexPath.section)
        
        var eventsArray : [EKEvent] = [EKEvent]()
        
        if let eventsForDay = eventsByIndexPath[fromStartOfMonthIndexPath] {
            eventsArray = eventsForDay;
        }
        
        delegate?.calendar(self, didSelectDate: dateBeingSelectedByUser, withEvents: eventsArray)

        selectedIndexPaths.append(indexPath)
        selectedDates.append(dateBeingSelectedByUser)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        guard let index = selectedIndexPaths.indexOf(indexPath) else {
            return
        }
        
        delegate?.calendar?(self, didDeselectDate: dateBeingSelectedByUser)
        
        selectedIndexPaths.removeAtIndex(index)
        selectedDates.removeAtIndex(index)
    
    }
    

    
    func reloadData() {
        self.calendarView.reloadData()
    }
    
    
    func setDisplayDate(date : NSDate, animated: Bool) {
        
        if let dispDate = self.displayDate {
            
            // skip if we are trying to set the same date
            if  date.compare(dispDate) == NSComparisonResult.OrderedSame {
                return
            }
            
            
            // check if the date is within range
            if  date.compare(startDateCache) == NSComparisonResult.OrderedAscending ||
                date.compare(endDateCache) == NSComparisonResult.OrderedDescending   {
                return
            }
            
            let difference = self.gregorian.components([NSCalendarUnit.Month], fromDate: startOfMonthCache, toDate: date, options: NSCalendarOptions())
            
            let distance : CGFloat = CGFloat(difference.month) * self.calendarView.frame.size.width
            
            self.calendarView.setContentOffset(CGPoint(x: distance, y: 0.0), animated: animated)
            
            
        }
    }
}

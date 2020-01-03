//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

public protocol CalendarDateRangePickerViewControllerDelegate {
    func didCancelPickingDateRange()
    func didPickDateRange(startDate: Date!, endDate: Date!)
}

class CalendarDateRangePickerViewController: UIViewController {
    
    let cellReuseIdentifier = "CalendarDateRangePickerCell"
    let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var topBar: NSLayoutConstraint!

    public var delegate: CalendarDateRangePickerViewControllerDelegate!
    
    let itemsPerRow = 7
    let itemHeight: CGFloat = 40
    let collectionViewInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    public var minimumDate: Date!
    public var maximumDate: Date!
    
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    
    public var selectedColor = UIColor.init(red: 227/255.0, green: 165/255.0, blue: 96/255.0, alpha: 1)//UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)

    @IBOutlet var topLabel: UILabel!
    
    @IBOutlet var bottomLabel: UILabel!
    
    @IBOutlet var accept: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView?.backgroundColor = UIColor.white

        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView?.contentInset = collectionViewInsets
        
        if minimumDate == nil {
            minimumDate = Date()
        }
        if maximumDate == nil {
            maximumDate = Calendar.current.date(byAdding: .year, value: 3, to: minimumDate)
        }
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        isEnable()
        
        bottom()
        
        topDate()
    }

    @IBAction func didTapCancel() {
        delegate.didCancelPickingDateRange()
    }
    
    @IBAction func didTapDone() {
        if selectedStartDate == nil || selectedEndDate == nil {
            return
        }
        delegate.didPickDateRange(startDate: selectedStartDate!, endDate: selectedEndDate!)
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        let time = calendar.dateComponents([.month, .weekday, .day], from: date)
        let time1 = calendar.dateComponents([.month, .weekday, .day], from: Date())
        return time.day == time1.day && time.month == time1.month && time.year ==  time1.year
    }
    
    func isEnable() {
        accept.isEnabled = (selectedStartDate != nil && selectedEndDate != nil)
        
        accept.alpha = (selectedStartDate != nil && selectedEndDate != nil) ? 1 : 0.5
    }
    
    func bottom() {
        bottomLabel.text = (selectedStartDate == nil && selectedEndDate == nil) ? "Chọn ngày khởi hành" : (selectedStartDate != nil && selectedEndDate == nil) ? "Chọn ngày trả phòng" : "Chọn ngày để đổi lịch trình"
    }
    
    func topDate() {
        if selectedStartDate == nil && selectedEndDate == nil  {
            topLabel.text = "Crystal Holidays"
        }
        
        if selectedStartDate != nil && selectedEndDate == nil  {
            let time = Calendar.current.dateComponents([.month, .weekday, .day], from: selectedStartDate!)
            topLabel.text = "%i Tháng %i".format(parameters: time.day!, time.month!)
        }
        
        if selectedStartDate != nil && selectedEndDate != nil {
            let time = Calendar.current.dateComponents([.month, .weekday, .day], from: selectedStartDate!)
            let time1 = Calendar.current.dateComponents([.month, .weekday, .day], from: selectedEndDate!)

            let diffInDays = Calendar.current.dateComponents([.day], from: time, to: time1).day

            topLabel.text = "%i Tháng %i - %i Tháng %i (%i ngày)".format(parameters: time.day!, time.month!, time1.day!, time1.month!, diffInDays!)
        }
    }
}

extension CalendarDateRangePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
   func numberOfSections(in collectionView: UICollectionView) -> Int {
        let difference = Calendar.current.dateComponents([.month], from: minimumDate, to: maximumDate)
        return difference.month! + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
        cell.selectedColor = self.selectedColor
        cell.reset()
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item < 7 {
            cell.label.text = getWeekdayLabel(weekday: indexPath.item + 1)
        } else if indexPath.item < 7 + blankItems {
            cell.label.text = ""
        } else {
            let dayOfMonth = indexPath.item - (7 + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.label.text = "\(dayOfMonth)"
            
            cell.label.textColor = isToday(date: date) ? UIColor.red : UIColor.lightGray
            
            if isBefore(dateA: date, dateB: minimumDate) {
                cell.disable()
            }
            
            if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                // Cell falls within selected range
                if dayOfMonth == 1 {
                    cell.highlightRight()
                } else if dayOfMonth == getNumberOfDaysInMonth(date: date) {
                    cell.highlightLeft()
                } else {
                    cell.highlight()
                }
            } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                // Cell is selected start date
                cell.select()
                if selectedEndDate != nil {
                    cell.highlightRight()
                }
            } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                cell.select()
                cell.highlightLeft()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
}

extension CalendarDateRangePickerViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        if cell.date == nil
        {
            return
        }
        if isBefore(dateA: cell.date!, dateB: minimumDate)
        {
            return
        }
        if selectedStartDate == nil
        {
            if !isBefore(dateA: cell.date!, dateB: selectedEndDate!) {
                self.showToast("Hãy chọn ngày nhận phòng trước ngày trả phòng", andPos: 0)

                return
            }
            
            selectedStartDate = cell.date
        }
        else if selectedEndDate == nil
        {
            if isBefore(dateA: cell.date!, dateB: selectedStartDate!) {
                self.showToast("Hãy chọn ngày trả phòng sau ngày nhận phòng", andPos: 0)
                
                return
            }
            
            if isBefore(dateA: selectedStartDate!, dateB: cell.date!)
            {
                selectedEndDate = cell.date
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            else
            {
                // If a cell before the currently selected start date is selected then just set it as the new start date
                selectedStartDate = cell.date
            }
        }
        else
        {
            selectedStartDate = cell.date
            selectedEndDate = nil
        }
        
        collectionView.reloadData()
        
        isEnable()
        
        bottom()
        
        topDate()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension CalendarDateRangePickerViewController {
    
    func getFirstDate() -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: minimumDate)
        components.day = 1
        return Calendar.current.date(from: components)!
    }
    
    func getFirstDateForSection(section: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: section, to: getFirstDate())!
    }
    
    func getMonthLabel(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM yyyy"
        
        let calendar = Calendar.current
        
        let time = calendar.dateComponents([.month, .weekday, .day, .year], from: date)
        
        return "Tháng %i %i".format(parameters: time.month!, time.year!)
        
        //return dateFormatter.string(from: date)
    }
    
    func getWeekdayLabel(weekday: Int) -> String {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.weekday = weekday
        let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
        if date == nil {
            return "E"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        
        return dayName(dayNumber: weekday)
        
        //return dateFormatter.string(from: date!)
    }
    
    func dayName(dayNumber: Int) -> String {
        
        var name = ""
        
        switch dayNumber {
        case 1:
            name = "CN"
        case 2:
            name = "HAI"
        case 3:
            name = "BA"
        case 4:
            name = "TƯ"
        case 5:
            name = "NĂM"
        case 6:
            name = "SÁU"
        case 7:
            name = "BẨY"
        default:
            name = ""
        }
        
        return name
    }
    
    func getWeekday(date: Date) -> Int {
        return Calendar.current.dateComponents([.weekday], from: date).weekday!
    }
    
    func getNumberOfDaysInMonth(date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    func getDate(dayOfMonth: Int, section: Int) -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
        components.day = dayOfMonth
        return Calendar.current.date(from: components)!
    }
    
    func areSameDay(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
    }
    
    func isBefore(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedAscending
    }
    
}

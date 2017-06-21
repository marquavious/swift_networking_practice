//
//  DateHelper.swift
//  Contractor
//
//  Created by Marquavious on 1/25/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import Foundation

// TODO: Document

class DateHelper {

    static func dateToday() -> Date{return Date()}
    
    static func daysBetweenDates(startDate: Date, endDate: Date) -> Int{
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return components.day!
    }

    static func currentDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateToday = Date()
        let returnString = dateFormatter.string(from: dateToday)
        return returnString
    }
    
    static func fullCurrentDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        let dateToday = Date()
        let returnString = dateFormatter.string(from: dateToday)
        return returnString
    }

    static func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateToFormat = date
        let returnString = dateFormatter.string(from: dateToFormat)
        return returnString
    }
    
    static func fullDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateToFormat = date
        let returnString = dateFormatter.string(from: dateToFormat)
        return returnString
    }
    
    private static func intToString(numberArray:[Int]) -> [String] {
        var returnArray = [String]()
        for number in numberArray {
            let numberString = String(number)
            returnArray.append(numberString)
        }
        return returnArray
    }
    
    static func stringToDate(month:Int, day: Int, year: Int) -> Date {
        let dateStringArray = intToString(numberArray: [month,day,year])
        let dateString = "\(dateStringArray[0])-\(dateStringArray[1])-\(dateStringArray[2])"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let date = dateFormatter.date(from: dateString)
        if let date = date {
            return date
        } else {
            return Date()
        }
    }
    
    static func daysBetween(date1: Date, date2: Date) -> Float {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: date1)
        let date2 = calendar.startOfDay(for: date2)
        let components = calendar.dateComponents([Calendar.Component.day], from: date1, to: date2)
        let componentsForDay = abs(Float(components.day!))
        return componentsForDay
    }
}


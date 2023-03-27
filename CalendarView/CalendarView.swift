//
//  CalendarView.swift
//  CalendarView
//
//  Created by Philipp on 25.03.23.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    var initiallyVisibleDate: Date? = nil
    var availableDateRange: ClosedRange<Date>? = nil
    var fontDesign: UIFontDescriptor.SystemDesign = .default

    var visibleDateChanged: ((Date) -> Void)?
    var canSelectDate: ((Date) -> Bool)?
    var selectDate: ((Date?) -> Void)?
    var decorationView: ((Date) -> UICalendarView.Decoration?)?

    private let relevantComponentsForVisibleDate = Set<Calendar.Component>([.calendar, .era, .year, .month])

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView(frame: .zero)
        calendarView.calendar = calendar
        calendarView.locale = locale
        calendarView.fontDesign = fontDesign

        // Make sure our calendar view adapts nicely to size constraints.
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if let initiallyVisibleDate {
            let dateComponents = calendar.dateComponents(relevantComponentsForVisibleDate, from: initiallyVisibleDate)
            calendarView.visibleDateComponents = dateComponents
        }
        if let availableDateRange {
            let dateInterval = DateInterval(start: availableDateRange.lowerBound, end: availableDateRange.upperBound)
            calendarView.availableDateRange = dateInterval
        }

        if selectDate != nil {
            calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        }

        if visibleDateChanged != nil || decorationView != nil{
            calendarView.delegate = context.coordinator
        }

        return calendarView
    }

    func updateUIView(_ calendarView: UICalendarView, context: Context) {

        if let availableDateRange {
            // Ensure visibleDate is within the date range
            if let currentVisibleDate = calendarView.visibleDateComponents.date {
                if !availableDateRange.contains(currentVisibleDate) {
                    let nearestBoundary = max(availableDateRange.lowerBound, min(availableDateRange.upperBound, currentVisibleDate))

                    let nearestBoundaryDateComponents = calendarView.calendar.dateComponents(relevantComponentsForVisibleDate, from: nearestBoundary)
                    if nearestBoundaryDateComponents != calendarView.visibleDateComponents {
                        print("🟡 Adjusting visible date to", nearestBoundary)
                        calendarView.visibleDateComponents = nearestBoundaryDateComponents
                    }
                }
            }
            let dateInterval = DateInterval(start: availableDateRange.lowerBound, end: availableDateRange.upperBound)
            if dateInterval != calendarView.availableDateRange {
                calendarView.availableDateRange = dateInterval
            }
        }

        if calendarView.locale != locale {
            calendarView.locale = locale
        }
        if calendarView.fontDesign != fontDesign {
            calendarView.fontDesign = fontDesign
        }
    }

    func makeCoordinator() -> Coordinator {
        if decorationView != nil {
            return DecoratedCoordinator(self)
        }
        return Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
        let parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }

        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            guard let visibleDateChanged = parent.visibleDateChanged,
                  let visibleDate = parent.calendar.date(from: calendarView.visibleDateComponents)
            else {
                return
            }
            return visibleDateChanged(visibleDate)
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
            guard let canSelectDate = parent.canSelectDate else { return true }
            if let dateComponents, let selectedDate = parent.calendar.date(from: dateComponents) {
                return canSelectDate(selectedDate)
            }
            return true
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let selectDate = parent.selectDate else { return }
            if let dateComponents, let selectedDate = parent.calendar.date(from: dateComponents) {
                selectDate(selectedDate)
            } else {
                selectDate(nil)
            }
        }
    }

    class DecoratedCoordinator: Coordinator {
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let decorationView = parent.decorationView,
                  let date = parent.calendar.date(from: dateComponents)
            else {
                return nil
            }

            return decorationView(date)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(fontDesign: .rounded)
    }
}

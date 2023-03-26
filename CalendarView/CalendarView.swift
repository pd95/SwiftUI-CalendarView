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

    var visibleDate: Date? = nil
    var availableDateRange: ClosedRange<Date>? = nil
    var fontDesign: UIFontDescriptor.SystemDesign = .default

    var canSelectDate: ((Date) -> Bool)?
    var selectDate: ((Date?) -> Void)?

    func makeUIView(context: Context) -> UIView {
        let calendarView = UICalendarView(frame: .zero)
        calendarView.calendar = calendar
        calendarView.locale = locale
        calendarView.fontDesign = fontDesign

        if let visibleDate {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: visibleDate)
            calendarView.visibleDateComponents = dateComponents
        }
        if let availableDateRange {
            let dateInterval = DateInterval(start: availableDateRange.lowerBound, end: availableDateRange.upperBound)
            calendarView.availableDateRange = dateInterval
        }

        if selectDate != nil {
            calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        }

        let rootView = UIView()
        rootView.addSubview(calendarView)

        // adding constraints to profileImageView
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          calendarView.leadingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
          calendarView.trailingAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
          calendarView.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor, constant: 0),
          calendarView.bottomAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.bottomAnchor, constant: 0),
        ])

        return rootView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let calendarView = uiView.subviews.first as? UICalendarView else { return }

        if let availableDateRange {
            // Ensure visibleDate is within the date range
            if let currentVisibleDate = calendarView.visibleDateComponents.date {
                if !availableDateRange.contains(currentVisibleDate) {
                    let nearestBoundary = max(availableDateRange.lowerBound, min(availableDateRange.upperBound, currentVisibleDate))
                    print("🟡 Adjusting visible date to", nearestBoundary)
                    calendarView.visibleDateComponents = calendarView.calendar.dateComponents([.year, .month, .day], from: nearestBoundary)
                }
            }
            let dateInterval = DateInterval(start: availableDateRange.lowerBound, end: availableDateRange.upperBound)
            if dateInterval != calendarView.availableDateRange {
                calendarView.availableDateRange = dateInterval
            }
        }

        if let visibleDate, calendarView.availableDateRange.contains(visibleDate) {
            let dateComponents = calendar.dateComponents([.calendar, .era, .year, .month], from: visibleDate)
            if dateComponents != calendarView.visibleDateComponents {
                calendarView.visibleDateComponents = dateComponents
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
        return Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
        let parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
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
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(fontDesign: .rounded)
    }
}

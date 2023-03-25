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

    var visibleDateComponents: DateComponents? = nil
    var availableDateRange: DateInterval? = nil

    func makeUIView(context: Context) -> UIView {
        let calendarView = UICalendarView(frame: .zero)
        calendarView.calendar = calendar
        calendarView.locale = locale
        if let visibleDateComponents {
            calendarView.visibleDateComponents = visibleDateComponents
        }
        if let availableDateRange {
            calendarView.availableDateRange = availableDateRange
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

        if let visibleDateComponents {
            calendarView.visibleDateComponents = visibleDateComponents
        }
        if let availableDateRange {
            calendarView.availableDateRange = availableDateRange
        }

        print("uiView", uiView.frame)
        print("calendarView", calendarView.frame)
        print("intrinsicContentSize", calendarView.intrinsicContentSize)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

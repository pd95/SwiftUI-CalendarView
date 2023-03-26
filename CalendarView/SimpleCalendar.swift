//
//  SimpleCalendar.swift
//  CalendarView
//
//  Created by Philipp on 26.03.23.
//

import SwiftUI

struct SimpleCalendar: UIViewRepresentable {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView(frame: .zero)
        calendarView.calendar = calendar
        calendarView.locale = locale

        // Make sure our calendar view adapts nicely to size constraints.
        //calendarView.contentMode = .scaleAspectFit
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
    }
}

struct SimpleCalendar_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            SimpleCalendar()
        }
        .frame(maxWidth: 300)
    }
}

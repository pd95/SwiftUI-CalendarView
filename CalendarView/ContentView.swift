//
//  ContentView.swift
//  CalendarView
//
//  Created by Philipp on 24.03.23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.calendar) private var calendar
    @State private var minDate = Date.distantPast
    @State private var maxDate = Date.distantFuture
    @State private var date: Date?
    @SceneStorage("maxWidth") private var maxWidth: Int = 350
    @SceneStorage("maxHeight") private var maxHeight: Int = 320

    var dateComponents: DateComponents? {
        guard let date else { return nil }
        return calendar.dateComponents([.year, .month, .day], from: date)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ScrollView(.vertical) {
                CalendarView(
                    visibleDateComponents: dateComponents,
                    availableDateRange: DateInterval(start: minDate, end: maxDate)
                )
                .border(.yellow)
                //.frame(minWidth: 100, minHeight: 100)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: CGFloat(maxWidth), maxHeight: CGFloat(maxHeight))
                //.fixedSize(horizontal: false, vertical: true)
                //.frame(maxWidth: 300, maxHeight: 400)
                //.frame(minWidth: 220, maxWidth: 300, minHeight: 267, maxHeight: 300)
                .border(.red)
            }
            .border(.purple)

            Section {
                HStack(spacing: 30) {
                    Text("Month")
                    Button("<<") {
                        date = calendar.date(byAdding: .month, value: -1, to: date ?? .now)
                    }
                    Button("Current") {
                        date = .now
                    }
                    Button(">>") {
                        date = calendar.date(byAdding: .month, value: 1, to: date ?? .now)
                    }
                }
                .buttonStyle(.bordered)
            } header: {
                Text("Content")
                    .font(.headline)
            }

            Spacer()
            Section {
                HStack(spacing: 30) {
                    Stepper("Width") {
                        maxWidth += 5
                    } onDecrement: {
                        maxWidth -= 5
                    }
                    TextField("Max. Width", value: $maxWidth, format: .number)
                }
                HStack(spacing: 30) {
                    Stepper("Height") {
                        maxHeight += 5
                    } onDecrement: {
                        maxHeight -= 5
                    }
                    TextField("Max Height", value: $maxHeight, format: .number)
                }
            } header: {
                Text("Sizing")
                    .font(.headline)
            }
            .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  CalendarView
//
//  Created by Philipp on 24.03.23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.calendar) private var calendar

    @State private var showConfigurationSheet = false

    // State variables used to test the `CalendarView` configuration
    @State private var minDate = Date.distantPast
    @State private var maxDate = Date.distantFuture
    @State private var currentVisibleMonth: Date?
    @State private var selectedDate: Date?
    @State private var locale: Locale = .current
    @State private var allowedWeekDays: [DateComponents] = (2...6).map({ DateComponents(weekday: $0) })

    // State variables used to test the `CalendarView` layout behaviour
    @SceneStorage("maxWidth") private var maxWidth: Int = 350
    @SceneStorage("maxHeight") private var maxHeight: Int = 320
    @SceneStorage("fontDesign") private var fontDesign: UIFontDescriptor.SystemDesign = .default

    var initialVisibleMonth: Date {
        let monthComponents = calendar.dateComponents([.year, .month], from: .now)
        return calendar.date(from: monthComponents)!
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {

            // The ScrollView and its content represent the "test environment" where the CalendarView
            // going to layout its content.
            ScrollView(.vertical) {
                CalendarView(
                    initiallyVisibleDate: initialVisibleMonth,
                    availableDateRange: minDate...maxDate,
                    fontDesign: fontDesign,
                    visibleDateChanged: { newDate in
                        currentVisibleMonth = newDate
                    },
                    canSelectDate: { date in
                        // Get weekday from date and check against allowed weekdays
                        let dateComponents = calendar.dateComponents([.weekday], from: date)
                        return allowedWeekDays.contains(dateComponents)
                    },
                    selectDate: {
                        selectedDate = $0
                    },
                    decorationView: { date in
                        let components = calendar.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: date)

                        // Holiday weeks
                        if [1, 7, 8, 17, 18, 29, 30, 31, 32, 33, 41, 42, 52].contains(components.weekOfYear) {
                            return .default(color: .orange, size: .small)
                        }

                        // planned Wednesdays
                        if components.weekday == 4 {
                            return .default(color: .red, size: .large)
                        }
                        return nil
                    }
                )
                .environment(\.locale, locale)
                .border(.yellow)
                .frame(maxWidth: CGFloat(maxWidth), maxHeight: CGFloat(maxHeight))
                .border(.red)

                Text(selectedDate == nil ? "Please select a date." : "\(selectedDate!, style: .date) selected")
                    .font(.title3.bold())
                    .padding()

                Text("Current month: \(currentVisibleMonth ?? initialVisibleMonth, style: .date)")
                    .font(.headline)

                Button(action: { showConfigurationSheet.toggle() }) {
                    Label("Configuration", systemImage: "gear")
                }

                VStack(alignment: .leading) {
                    Text("Border colors")
                        .font(.headline)
                    Text("ScrollView").foregroundColor(.purple)
                    Text("CalendarView").foregroundColor(.yellow)
                    Text("maxed frame").foregroundColor(.red)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .border(.purple)
            .sheet(isPresented: $showConfigurationSheet) {
                ScrollView {
                    VStack(alignment: .leading) {

                        // ---------------------------------------------------------------
                        // The following section allows adjusting the "Content" related behaviour of the `CalendarView`
                        Section {
                            DatePicker("Min. date", selection: $minDate, in: Date.distantPast...maxDate, displayedComponents: .date)
                                .disabled(minDate == .distantPast)
                                .overlay(content: {
                                    if minDate == .distantPast {
                                        Color.clear
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                if minDate == .distantPast {
                                                    minDate = calendar.date(byAdding: .month, value: -2, to: .now) ?? initialVisibleMonth
                                                }
                                            }
                                    }
                                })
                            DatePicker("Max. date", selection: $maxDate, in: minDate...Date.distantFuture, displayedComponents: .date)
                                .disabled(maxDate == .distantFuture)
                                .overlay(content: {
                                    if maxDate == .distantFuture {
                                        Color.clear
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                if maxDate == .distantFuture {
                                                    maxDate = calendar.date(byAdding: .month, value: 2, to: .now) ?? initialVisibleMonth
                                                }
                                            }
                                    }
                                })

                            LabeledContent("Language") {
                                Button("System") {
                                    locale = .current
                                }

                                LanguageChooser(
                                    supportedLanguages: ["de", "fr", "it", "en", "es", "pt"],
                                    selectedLanguage:
                                        Binding(get: { locale.language.languageCode ?? Locale.LanguageCode("en")},
                                                set: { languageCode in locale = Locale(identifier: languageCode.identifier) }
                                               ),
                                    label: {
                                        Label("Other", systemImage: "ellipsis")
                                            .labelStyle(.iconOnly)
                                            .frame(minHeight: 20)
                                    }
                                )
                            }
                        } header: {
                            Text("Content")
                                .font(.headline)
                        }

                        Divider()

                        // ---------------------------------------------------------------
                        // The following section allows adjusting the "Appearance" related behaviour of the `CalendarView`
                        Section {
                            HStack {
                                Text("Appearance")
                                    .font(.headline)
                                Spacer()
                                Menu {
                                    let designs: [UIFontDescriptor.SystemDesign] = [.default, .rounded, .monospaced, .serif]
                                    ForEach(designs, id: \.rawValue) { design in
                                        let title = design.rawValue.replacing(/^NSCTFontUIFontDesign/, with: "")
                                        Button(title) {
                                            fontDesign = design
                                        }
                                    }
                                } label: {
                                    Text("Font Design")
                                }
                                .buttonStyle(.borderless)
                            }

                            HStack(spacing: 10) {
                                Stepper("Width") {
                                    maxWidth += 5
                                } onDecrement: {
                                    maxWidth -= 5
                                }
                                TextField("Max. Width", value: $maxWidth, format: .number)
                                    .frame(maxWidth: 65)
                            }
                            HStack(spacing: 10) {
                                Stepper("Height") {
                                    maxHeight += 5
                                } onDecrement: {
                                    maxHeight -= 5
                                }
                                TextField("Max Height", value: $maxHeight, format: .number)
                                    .frame(maxWidth: 65)
                            }
                        }
                    }
                    .padding()
                    .buttonStyle(.bordered)
                    .textFieldStyle(.roundedBorder)
                }
                .presentationDetents([.medium, .large, .fraction(0.45)])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

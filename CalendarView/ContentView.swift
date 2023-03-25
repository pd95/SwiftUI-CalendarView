//
//  ContentView.swift
//  CalendarView
//
//  Created by Philipp on 24.03.23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.calendar) private var calendar

    // State variables used to test the `CalendarView` configuration
    @State private var minDate = Date.distantPast
    @State private var maxDate = Date.distantFuture
    @State private var date: Date = .now
    @State private var locale: Locale = .current

    // State variables used to test the `CalendarView` layout behaviour
    @SceneStorage("maxWidth") private var maxWidth: Int = 350
    @SceneStorage("maxHeight") private var maxHeight: Int = 320

    var body: some View {
        VStack(alignment: .center, spacing: 20) {

            // The ScrollView and its content represent the "test environment" where the CalendarView
            // going to layout its content.
            ScrollView(.vertical) {
                CalendarView(
                    visibleDateComponents: calendar.dateComponents([.year, .month, .day], from: date),
                    availableDateRange: DateInterval(start: minDate, end: maxDate)
                )
                .environment(\.locale, locale)
                .border(.yellow)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: CGFloat(maxWidth), maxHeight: CGFloat(maxHeight))
                .border(.red)
            }
            .border(.purple)

            // ---------------------------------------------------------------
            // The following section allows adjusting the "Content" related behaviour of the `CalendarView`
            Section {
                LabeledContent("Month") {
                    Button(action: {
                        date = calendar.date(byAdding: .month, value: -1, to: date) ?? date
                    }, label: {
                        Label("Previous", systemImage: "chevron.backward.2")
                    })
                    Button("Current") {
                        date = .now
                    }
                    Button(action: {
                        date = calendar.date(byAdding: .month, value: 1, to: date) ?? date
                    }, label: {
                        Label("Next", systemImage: "chevron.forward.2")
                    })
                }
                .labelStyle(.iconOnly)

                DatePicker("Min. date", selection: $minDate, in: Date.distantPast...maxDate, displayedComponents: .date)
                    .disabled(minDate == .distantPast)
                    .overlay(content: {
                        if minDate == .distantPast {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if minDate == .distantPast {
                                        minDate = calendar.date(byAdding: .month, value: -2, to: .now) ?? date
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
                                        maxDate = calendar.date(byAdding: .month, value: 2, to: .now) ?? date
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
            // The following section allows adjusting the "Layout" related behaviour of the `CalendarView`
            Section {
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
            } header: {
                Text("Sizing")
                    .font(.headline)
            }
        }
        .buttonStyle(.bordered)
        .textFieldStyle(.roundedBorder)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

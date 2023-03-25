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
    @State private var date: Date = .now
    @State private var selectedDate: Date?
    @State private var locale: Locale = .current
    @State private var allowedWeekDays: [DateComponents] = (2...6).map({ DateComponents(weekday: $0) })

    // State variables used to test the `CalendarView` layout behaviour
    @SceneStorage("maxWidth") private var maxWidth: Int = 350
    @SceneStorage("maxHeight") private var maxHeight: Int = 320
    @SceneStorage("fontDesign") private var fontDesign: UIFontDescriptor.SystemDesign = .default

    var body: some View {
        VStack(alignment: .center, spacing: 20) {

            // The ScrollView and its content represent the "test environment" where the CalendarView
            // going to layout its content.
            ScrollView(.vertical) {
                CalendarView(
                    visibleDate: date,
                    availableDateRange: minDate...maxDate,
                    fontDesign: fontDesign,
                    canSelectDate: { date in
                        // Get weekday from date and check against allowed weekdays
                        let dateComponents = calendar.dateComponents([.weekday], from: date)
                        return allowedWeekDays.contains(dateComponents)
                    },
                    selectedDate: {
                        print("\($0) selected")
                        selectedDate = $0
                    }
                )
                .environment(\.locale, locale)
                .border(.yellow)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: CGFloat(maxWidth), maxHeight: CGFloat(maxHeight))
                .border(.red)

                Text(selectedDate == nil ? "Please select a date." : "\(selectedDate!, style: .date) selected")
                    .font(.title3.bold())
                    .padding()

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
                            LabeledContent("Visible month") {
                                Button(action: {
                                    date = calendar.date(byAdding: .month, value: -1, to: date) ?? date
                                }, label: {
                                    Label("Previous", systemImage: "chevron.backward.2")
                                })
                                Button("Today") {
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

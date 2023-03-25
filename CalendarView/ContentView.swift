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
    @State private var locale: Locale = .current

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
                .environment(\.locale, locale)
                .border(.yellow)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: CGFloat(maxWidth), maxHeight: CGFloat(maxHeight))
                .border(.red)
            }
            .border(.purple)

            Section {
                LabeledContent("Month") {
                    Button(action: {
                        date = calendar.date(byAdding: .month, value: -1, to: date ?? .now)
                    }, label: {
                        Label("Previous", systemImage: "chevron.backward.2")
                    })
                    Button("Current") {
                        date = .now
                    }
                    Button(action: {
                        date = calendar.date(byAdding: .month, value: 1, to: date ?? .now)
                    }, label: {
                        Label("Next", systemImage: "chevron.forward.2")
                    })
                }
                .labelStyle(.iconOnly)

                LabeledContent("Language") {
                    Button("System") {
                        locale = .current
                    }
                    Menu {
                        ForEach(["de", "fr", "it", "en", "es", "pt"], id: \.self) { languageCode in
                            Button(action: {
                                locale = Locale(identifier: languageCode)
                            }) {
                                if let currentLanguage = locale.language.languageCode?.identifier,
                                    currentLanguage == languageCode {
                                    Image(systemName: "checkmark")
                                }
                                Text(Locale.Language(identifier: languageCode).minimalIdentifier)
                            }
                        }
                    } label: {
                        Label("Other", systemImage: "ellipsis")
                            .labelStyle(.iconOnly)
                            .frame(minHeight: 20)
                    }
                }
            } header: {
                Text("Content")
                    .font(.headline)
            }

            Divider()

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

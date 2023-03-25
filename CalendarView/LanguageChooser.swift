//
//  LanguageChooser.swift
//  CalendarView
//
//  Created by Philipp on 25.03.23.
//

import SwiftUI

struct LanguageChooser<Label: View>: View {

    var supportedLanguages: [Locale.LanguageCode]
    @Binding var selectedLanguage: Locale.LanguageCode
    @ViewBuilder var label: () -> Label

    var body: some View {
        Menu {
            let currentLanguage = selectedLanguage
            ForEach(supportedLanguages, id: \.self) { languageCode in
                Button(action: {
                    selectedLanguage = languageCode
                }) {
                    if let currentLanguage,
                       currentLanguage == languageCode {
                        Image(systemName: "checkmark")
                    }
                    Text(languageCode.identifier)
                }
            }
        } label: {
            label()
        }
    }
}

struct LanguageChooser_Previews: PreviewProvider {
    static var previews: some View {
        LanguageChooser(supportedLanguages: ["de", "fr", "it", "en", "es", "pt"], selectedLanguage: .constant("en")) {
            Label("Choose Language", systemImage: "ellipsis.circle")
                .frame(minHeight: 20)
        }
    }
}

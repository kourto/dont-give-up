//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//

import SwiftUI

struct AddEntrySheet: View {
    var isDarkMode: Bool
    @Binding var newDate: Date
    @Binding var weightText: String
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDarkMode ? .white : .black)
                DatePicker("Date", selection: $newDate, displayedComponents: .date)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Weight (lb)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDarkMode ? .white : .black)
                TextField("Weight (lb)", text: $weightText)
                    .keyboardType(.decimalPad)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isDarkMode ? Color.white : Color.black, lineWidth: 1.5)
                    )
                    .foregroundStyle(isDarkMode ? .white : .black)
            }

            Button(action: onSave) {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .foregroundColor(isDarkMode ? .black : .white)
            .background(isDarkMode ? Color.white : Color.black)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isDarkMode ? Color.black : Color.white, lineWidth: 2))
            .disabled(Double(weightText.replacingOccurrences(of: ",", with: ".")) == nil)
            .opacity(Double(weightText.replacingOccurrences(of: ",", with: ".")) == nil ? 0.5 : 1.0)
        }
        .padding(20)
        .background(isDarkMode ? Color.black : Color.white)
        .tint(isDarkMode ? .white : .black)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct EditTrackableSheet: View {
    @Binding var name: String
    @Binding var color: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }
                
                Section("Color") {
                    ColorPaletteGrid(selectedColor: $color)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Goal")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

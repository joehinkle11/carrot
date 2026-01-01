// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct GoalsView: View {
    @State var trackables: [Trackable] = []
    @State var showingAddAlert = false
    @State var showingEditSheet = false
    @State var newTrackableName = ""
    @State var trackableToEdit: Trackable? = nil
    @State var editName = ""
    @State var editColor = defaultTrackableColor
    
    var body: some View {
        Group {
            if trackables.isEmpty {
                emptyStateView
            } else {
                trackablesList
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    newTrackableName = ""
                    showingAddAlert = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New Goal", isPresented: $showingAddAlert) {
            TextField("Name", text: $newTrackableName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addTrackable()
            }
        } message: {
            Text("Enter a name for your new habit or goal")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTrackableSheet(
                name: $editName,
                color: $editColor,
                onSave: {
                    saveEditedTrackable()
                    showingEditSheet = false
                },
                onCancel: {
                    trackableToEdit = nil
                    showingEditSheet = false
                }
            )
        }
        .onAppear {
            trackables = BackendService.shared.getAllTrackables()
        }
    }
    
    private var trackablesList: some View {
        List {
            ForEach(trackables) { trackable in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: trackable.color) ?? .orange)
                        .frame(width: 12, height: 12)
                    
                    Text(trackable.name)
                    
                    Spacer()
                    
                    Button {
                        trackableToEdit = trackable
                        editName = trackable.name
                        editColor = trackable.color
                        showingEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete(perform: deleteTrackables)
            .onMove(perform: moveTrackables)
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #endif
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("carrot", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("Goals & Habits")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create habits and goals you want to track daily")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    private func addTrackable() {
        let name = newTrackableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        if let _ = BackendService.shared.createTrackable(name: name) {
            trackables = BackendService.shared.getAllTrackables()
        }
    }
    
    private func saveEditedTrackable() {
        guard let trackable = trackableToEdit else { return }
        let name = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let updated = Trackable(id: trackable.id, name: name, color: editColor, order: trackable.order)
        if BackendService.shared.updateTrackable(updated) {
            trackables = BackendService.shared.getAllTrackables()
        }
        trackableToEdit = nil
    }
    
    private func deleteTrackables(at offsets: IndexSet) {
        for index in offsets {
            let trackable = trackables[index]
            let _ = BackendService.shared.deleteTrackable(id: trackable.id)
        }
        trackables = BackendService.shared.getAllTrackables()
    }
    
    private func moveTrackables(from source: IndexSet, to destination: Int) {
        trackables.move(fromOffsets: source, toOffset: destination)
        
        // Update the order in the database
        var updates: [(id: Int64, order: Int)] = []
        for (index, trackable) in trackables.enumerated() {
            updates.append((id: trackable.id, order: index))
        }
        
        if BackendService.shared.updateTrackableOrders(updates) {
            // Refresh from database to ensure consistency
            trackables = BackendService.shared.getAllTrackables()
        }
    }
}

// MARK: - Edit Trackable Sheet

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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(trackableColorPalette, id: \.self) { hexColor in
                            Button {
                                color = hexColor
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: hexColor) ?? .orange)
                                        .frame(width: 40, height: 40)
                                    
                                    if color == hexColor {
                                        Image(systemName: "checkmark")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
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

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        guard hexString.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgbValue) else { return nil }
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct GoalsView: View {
    @State var trackables: [Trackable] = []
    @State var showingAddAlert = false
    @State var showingEditSheet = false
    @State var showingDeleteAlert = false
    @State var showingFirstGoalTutorial = false
    @State var newTrackableName = ""
    @State var trackableToEdit: Trackable? = nil
    @State var trackableToDelete: Trackable? = nil
    @State var editName = ""
    @State var editColor = defaultTrackableColor
    @State var isEditMode = false
    @State var hadNoTrackablesBefore = false
    
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
                HStack(spacing: 16) {
                    if !trackables.isEmpty {
                        Button {
                            isEditMode.toggle()
                        } label: {
                            Text(isEditMode ? "Done" : "Edit")
                        }
                    }
                    
                    Button {
                        newTrackableName = ""
                        showingAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
        .alert("Delete Goal?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                trackableToDelete = nil
            }
            Button("Delete", role: .destructive) {
                confirmDeleteTrackable()
            }
        } message: {
            if let trackable = trackableToDelete {
                Text("Are you sure you want to delete '\(trackable.name)'? This will also delete all associated tracking data.")
            } else {
                Text("Are you sure you want to delete this goal?")
            }
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
        .alert("Welcome to Habit Tracking!", isPresented: $showingFirstGoalTutorial) {
            Button("Got it!") {
                TutorialManager.shared.markFirstGoalTutorialSeen()
            }
        } message: {
            Text("Great job creating your first goal!\n\nTrack simple actions like \"Went for a run\" or \"Drank water\" — not detailed metrics. Each tap adds one count for the day.\n\nThis counting system helps you see patterns over time without overthinking the details.")
        }
    }
    
    private var trackablesList: some View {
        Group {
            if isEditMode {
                editableList
            } else {
                readOnlyList
            }
        }
    }
    
    private var editableList: some View {
        List {
            ForEach(trackables) { trackable in
                trackableRow(trackable: trackable, showEditButton: true)
            }
            .onDelete(perform: requestDeleteTrackables)
            .onMove(perform: moveTrackables)
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #endif
    }
    
    private var readOnlyList: some View {
        List {
            ForEach(trackables) { trackable in
                trackableRow(trackable: trackable, showEditButton: false)
            }
        }
    }
    
    private func trackableRow(trackable: Trackable, showEditButton: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: trackable.color) ?? .orange)
                .frame(width: 12, height: 12)
            
            Text(trackable.name)
            
            Spacer()
            
            if showEditButton {
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
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text("Tap the")
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    Text("button to add your first goal")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    private func addTrackable() {
        let name = newTrackableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let wasEmpty = trackables.isEmpty
        
        if let _ = BackendService.shared.createTrackable(name: name) {
            trackables = BackendService.shared.getAllTrackables()
            
            // Show first goal tutorial if this was the first goal created
            if wasEmpty && !trackables.isEmpty && !TutorialManager.shared.hasSeenFirstGoalTutorial {
                showingFirstGoalTutorial = true
            }
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
    
    private func requestDeleteTrackables(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        trackableToDelete = trackables[index]
        showingDeleteAlert = true
    }
    
    private func confirmDeleteTrackable() {
        guard let trackable = trackableToDelete else { return }
        let _ = BackendService.shared.deleteTrackable(id: trackable.id)
        trackables = BackendService.shared.getAllTrackables()
        trackableToDelete = nil
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

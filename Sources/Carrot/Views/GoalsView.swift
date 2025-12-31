// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct GoalsView: View {
    @State var trackables: [Trackable] = []
    @State var showingAddAlert = false
    @State var showingRenameAlert = false
    @State var newTrackableName = ""
    @State var trackableToEdit: Trackable? = nil
    
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
        .alert("Rename", isPresented: $showingRenameAlert) {
            TextField("Name", text: $newTrackableName)
            Button("Cancel", role: .cancel) {
                trackableToEdit = nil
            }
            Button("Save") {
                renameTrackable()
            }
        } message: {
            Text("Enter a new name")
        }
        .onAppear {
            trackables = BackendService.shared.getAllTrackables()
        }
    }
    
    private var trackablesList: some View {
        List {
            ForEach(trackables) { trackable in
                HStack {
                    Text(trackable.name)
                    Spacer()
                    Button {
                        trackableToEdit = trackable
                        newTrackableName = trackable.name
                        showingRenameAlert = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete(perform: deleteTrackables)
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
    
    private func renameTrackable() {
        guard let trackable = trackableToEdit else { return }
        let name = newTrackableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let updated = Trackable(id: trackable.id, name: name)
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
}

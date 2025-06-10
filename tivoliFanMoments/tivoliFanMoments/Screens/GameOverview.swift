import SwiftUI

struct GamesOverviewView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var saisonVM = SaisonViewModel()
    @State private var selectedSaisonId: Int? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Hauptbereich als eigene Computed Property
                mainContent
            }
            .navigationTitle("Spiele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Toolbar-Logik als eigene Computed Property
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarContent
                }
            }
            // Alert-Bindung als eigene Property
            .alert(item: errorAlertBinding) { error in
                Alert(
                    title: Text("Datenbank‐Fehler"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: saisonVM.saisons) {
                if selectedSaisonId == nil, let first = saisonVM.saisons.first {
                    selectedSaisonId = first.id
                }
            }
        }
    }
}

// MARK: - Erweiterungen für GamesOverviewView

private extension GamesOverviewView {
    
    /// Hauptinhalte als eigene Property
    var mainContent: some View {
        VStack(spacing: 12) {
            Text("Hallo \(session.currentUser?.displayname ?? "Gast")!")
                .foregroundColor(.yellow)
                .font(.headline)

            Text("Hier ist deine Spielübersicht.")
                .foregroundColor(.yellow)

            if saisonVM.saisons.isEmpty && saisonVM.errorMessage == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            }

            Spacer()
        }
        .padding()
    }
    
    /// Toolbar als eigene Property
    @ViewBuilder
    var toolbarContent: some View {
        if saisonVM.saisons.isEmpty {
            Text("…")
                .foregroundColor(.yellow)
        } else {
            // Picker in einer Subview gekapselt
            SaisonsPickerView(
                saisons: saisonVM.saisons,
                selectedSaisonId: $selectedSaisonId
            )
        }
    }
    
    /// Alert-Bindung als eigene Property
    var errorAlertBinding: Binding<MyError?> {
        Binding<MyError?>(
            get: {
                saisonVM.errorMessage.map { MyError(message: $0) }
            },
            set: { _ in
                saisonVM.errorMessage = nil
            }
        )
    }
}

// MARK: - Picker-Subview

private struct SaisonsPickerView: View {
    let saisons: [Saison]
    @Binding var selectedSaisonId: Int?

    var body: some View {
        let currentId = selectedSaisonId ?? saisons.first?.id ?? 0
        let currentLabel = saisons.first(where: { $0.id == currentId })?.bezeichnung
            ?? saisons.first?.bezeichnung
            ?? "Unbekannt"
        
        let selectionBinding = Binding<Int>(
            get: { currentId },
            set: { newId in
                selectedSaisonId = newId
            }
        )

        Picker(currentLabel, selection: selectionBinding) {
            ForEach(saisons) { saison in
                Text(saison.bezeichnung)
                    .tag(saison.id)
            }
        }
        .pickerStyle(.menu)
        .foregroundColor(.yellow)
    }
}

// MARK: - Fehler-Typ zum Alert

private struct MyError: Identifiable {
    let id = UUID()
    let message: String
}

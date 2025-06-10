import SwiftUI

struct GamesOverviewView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var saisonVM = SaisonViewModel()
    @StateObject private var begegnungVM = BegegnungViewModel()
    @State private var selectedSaisonId: Int? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("Spiele")
            .navigationBarTitleDisplayMode(.inline)
            
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
            .onChange(of: selectedSaisonId) { newId in
                if let saisonId = newId {
                    Task {
                        await begegnungVM.load(saisonId: saisonId)
                    }
                }
            }
        }
    }
}

// MARK: - Erweiterungen

private extension GamesOverviewView {
    
    var mainContent: some View {
        VStack(spacing: 16) {

            Text("Hier ist deine Spielübersicht.")
                .foregroundColor(.yellow)

            if !saisonVM.saisons.isEmpty {
                SaisonsPickerView(
                    saisons: saisonVM.saisons,
                    selectedSaisonId: $selectedSaisonId
                )
            }

            if saisonVM.saisons.isEmpty && saisonVM.errorMessage == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            } else if !begegnungVM.begegnungen.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(begegnungVM.begegnungen) { begegnung in
                            NavigationLink(destination: SpielDetailView(begegnung: begegnung)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(begegnung.heim.name)
                                        Spacer()
                                        Text("\(begegnung.heimTore ?? 0) : \(begegnung.gastTore ?? 0)")
                                            .bold()
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(begegnung.gast.name)
                                    }
                                    .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top)
                }
            

            } else if let error = begegnungVM.errorMessage {
                Text("Fehler: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("Keine Begegnungen vorhanden.")
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
    }




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

// MARK: - Fehler-Typ

private struct MyError: Identifiable {
    let id = UUID()
    let message: String
}

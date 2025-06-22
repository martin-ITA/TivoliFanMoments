import SwiftUI

struct GamesOverviewView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var saisonVM = SaisonViewModel()
    @StateObject private var begegnungVM = BegegnungViewModel()
    @State private var selectedSaisonId: Int? = nil

    var body: some View {
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
                selectedSaisonId = 1
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
                                        // Heimteam: Logo + Name
                                        HStack(spacing: 8) {
                                            Image("\(begegnung.heim.id)")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(6)
                                            Text(begegnung.heim.name)
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                        }

                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        
                                        // Tore zentriert
                                        Text("\(begegnung.heimTore ?? 0) : \(begegnung.gastTore ?? 0)")
                                            .bold()
                                            .foregroundColor(.white)
                                            .frame(width: 40, alignment: .center) // Fixe Breite für konstante Zentrierung
                                        
                                        // Gastteam: Name + Logo
                                        HStack(spacing: 8) {
                                            Image("\(begegnung.gast.id)")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(6)
                                            Text(begegnung.gast.name)
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
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
            }
 else if let error = begegnungVM.errorMessage {
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

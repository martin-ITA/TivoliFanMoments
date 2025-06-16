// UploadOverviewView.swift
import SwiftUI

struct UploadOverviewView: View {
    @State private var besuchteBegegnungen: [Begegnung] = []
    @State private var selectedBegegnung: Begegnung? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if isLoading {
                    ProgressView("Lade deine besuchten Spiele...")
                        .foregroundColor(.yellow)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if besuchteBegegnungen.isEmpty {
                    Text("Du hast noch keine Spiele besucht.")
                        .foregroundColor(.yellow)
                        .padding()
                } else {
                    VStack(alignment: .leading) {
                        Text("Deine besuchten Spiele")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)

                        List(besuchteBegegnungen, id: \.id) { begegnung in
                            NavigationLink(destination: UploadView(begegnung: begegnung)) {
                                VStack(alignment: .leading) {
                                    Text("Spieltag \(begegnung.spieltag)")
                                        .foregroundColor(.white)
                                    Text("\(begegnung.heim.name) vs. \(begegnung.gast.name)")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowBackground(Color.black)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.black)

                }
}
            }
            .onAppear {
                Task {
                    do {
                        guard let user = DatabaseConnector.userProfile else {
                            errorMessage = "Du bist nicht eingeloggt."
                            isLoading = false
                            return
                        }

                        besuchteBegegnungen = try await DatabaseConnector().fetchBesuchteBegegnungen(userId: user.id)
                        isLoading = false
                    } catch {
                        errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        }.background(Color.black)
    }
}

import SwiftUI


struct SpielDetailView: View {
    let begegnung: Begegnung
    @State private var momente: [Moment] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Spielüberschrift
                VStack(spacing: 4) {
                    Text("\(begegnung.heim.name) vs \(begegnung.gast.name)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.yellow)

                    Text("\(begegnung.heimTore ?? 0) : \(begegnung.gastTore ?? 0)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                }

                Divider().background(Color.yellow)

                // Zeitleiste
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spielverlauf")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    ForEach(momente) { moment in
                        HStack {
                            Text("\(moment.minute)'")
                                .font(.caption)
                                .frame(width: 40, alignment: .leading)
                                .foregroundColor(.white)

                            icon(for: moment.art)
                                .foregroundColor(.white)

                            Text(moment.art.capitalized)
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Spiel-Details")
        .onAppear {
            Task {
                do {
                    momente = try await DatabaseConnector().fetchMomente(begegnungId: begegnung.id)
                } catch {
                    print("Fehler beim Laden der Momente: \(error)")
                }
            }
        }
    }

    @ViewBuilder
    private func icon(for art: String) -> some View {
        switch art.lowercased() {
        case "tor":
            Image(systemName: "soccerball")
        case "karte":
            Image(systemName: "rectangle.fill")
        case "wechsel":
            Image(systemName: "arrow.left.arrow.right")
        default:
            Image(systemName: "circle")
        }
    }
}

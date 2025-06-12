import SwiftUI


struct SpielDetailView: View {
    let begegnung: Begegnung
    @State private var momente: [Moment] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Spielüberschrift
                HStack(alignment: .center, spacing: 32) {
                    Image("big\(begegnung.heim.id)")
                        .resizable()
                        .frame(width: 54, height: 70)
                        .cornerRadius(8)

                    Text("\(begegnung.heimTore ?? 0) : \(begegnung.gastTore ?? 0)")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.yellow)
                        .frame(width: 70, alignment: .center)

                    Image("big\(begegnung.gast.id)")
                        .resizable()
                        .frame(width: 54, height: 70)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                // Horizontaler Strich
                Divider().background(Color.yellow)

                // Zeitleiste
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spielverlauf")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    // Table-style header
                    HStack {
                        Text("Spielminute")
                            .frame(width: 70, alignment: .leading)
                            .font(.caption2)
                            .foregroundColor(.white)

                        Text("Ereignis")
                            .frame(width: 160, alignment: .leading)
                            .font(.caption2)
                            .foregroundColor(.white)

                        Spacer()
                        
                        Text("Anzahl Uploads")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: 54, alignment: .center)
                    }

                    ForEach(momente) { moment in
                        Button(action: {
                            // Handle navigation or sheet here
                            print("Moment tapped: \(moment)")
                        }) {
                            HStack {
                                Text("\(moment.minute)'")
                                    .font(.caption)
                                    .frame(width: 70, alignment: .leading)
                                    .foregroundColor(.white)

                                HStack(spacing: 8) {
                                    icon(for: moment.art)
                                        .foregroundColor(.white)
                                    Text(moment.art.capitalized)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .frame(width: 160, alignment: .leading)

                                Spacer()
                                
                                Text("\(moment.uploadCount ?? 0)")
                                    .foregroundColor(.white)
                                    .frame(width: 54, alignment: .center)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .background(
                                (moment.uploadCount ?? 0) > 0 ?
                                    Color.white.opacity(0.07) :
                                    Color.clear
                            )
                            .cornerRadius(8)
                            .contentShape(Rectangle()) // Makes the whole row tappable
                        }
                        .disabled((moment.uploadCount ?? 0) == 0)
                        .opacity((moment.uploadCount ?? 0) == 0 ? 0.4 : 1.0)
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

        case "elfmeter":
            Image(systemName: "circle.hexagongrid.fill")

        case "gelbe karte":
            Image(systemName: "rectangle.fill")
                .foregroundColor(.yellow)
                .scaleEffect(x: 0.5, y: 1.0) // change the width, else its a square and does not look like a card :D

        case "rote karte":
            Image(systemName: "rectangle.fill")
                .foregroundColor(.red)
                .scaleEffect(x: 0.5, y: 1.0)

        case "torchance":
            Image(systemName: "target")

        case "freistoss":
            Image(systemName: "arrow.up.right")

        case "ecke":
            Image(systemName: "arrow.turn.up.left")

        default:
            Image(systemName: "circle")
        }
    }

}

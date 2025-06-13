import SwiftUI

struct SpielDetailView: View {
    let begegnung: Begegnung
    @State private var momente: [Moment] = []
    
    /// Single connector instance used for every DB call
    private let db = DatabaseConnector()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // ───────── Header (teams + score) ─────────
                SpielHeader(begegnung: begegnung)
                    .padding(.bottom, 8)
                
                Divider().background(Color.yellow)
                
                // ───────── Timeline ─────────
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spielverlauf")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    TimelineHeader()
                    
                    ForEach(momente) { moment in
                        NavigationLink {
                            UploadFeedView(moment: moment)          // destination
                                .onAppear {
                                    print("▶️ Push UploadFeedView for momentId \(moment.id)")
                                }
                        } label: {
                            MomentRow(moment: moment)               // row look
                        }
                        .disabled(moment.uploadCount == 0)
                        .opacity(moment.uploadCount == 0 ? 0.4 : 1)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                print("🟡 Row tapped → momentId \(moment.id), uploads \(moment.uploadCount)")
                            }
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Spiel-Details")
        .task { await loadMomente() }      // single async load
    }
    
    // MARK: - Async data loading
    @MainActor
    private func loadMomente() async {
        do {
            var fetched = try await db.fetchMomente(begegnungId: begegnung.id)
            for idx in fetched.indices {
                let cnt = try await db.countUploadsPerMoment(momentId: fetched[idx].id)
                fetched[idx].uploadCount = cnt
            }
            momente = fetched
        } catch {
            print("Fehler beim Laden der Momente: \(error)")
        }
    }
}

// MARK: - Sub-views
private struct SpielHeader: View {
    let begegnung: Begegnung
    
    var body: some View {
        HStack(alignment: .center, spacing: 32) {
            Image("big\(begegnung.heim.id)")
                .resizable()
                .frame(width: 54, height: 70)
                .cornerRadius(8)
            
            Text("\(begegnung.heimTore ?? 0) : \(begegnung.gastTore ?? 0)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.yellow)
                .frame(width: 70, alignment: .center)
            
            Image("big\(begegnung.gast.id)")
                .resizable()
                .frame(width: 54, height: 70)
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TimelineHeader: View {
    var body: some View {
        HStack {
            Text("Spielminute")
                .frame(width: 70, alignment: .leading)
            Text("Ereignis")
                .frame(width: 160, alignment: .leading)
            Spacer()
            Text("Anzahl Uploads")
                .frame(width: 54, alignment: .center)
        }
        .font(.caption2)
        .foregroundColor(.white)
    }
}

private struct MomentRow: View {
    let moment: Moment
    
    var body: some View {
        HStack {
            // minute
            Text("\(moment.minute)'")
                .font(.caption)
                .frame(width: 70, alignment: .leading)
            
            // icon + text
            HStack(spacing: 8) {
                icon(for: moment.art)
                Text(moment.art.capitalized)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(width: 160, alignment: .leading)
            
            Spacer()
            
            // upload count
            Text("\(moment.uploadCount)")
                .frame(width: 54, alignment: .center)
        }
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            moment.uploadCount > 0
            ? Color.white.opacity(0.07)
            : Color.clear
        )
        .cornerRadius(8)
        .contentShape(Rectangle())   // full-row tap target
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
                .scaleEffect(x: 0.5, y: 1.0)
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

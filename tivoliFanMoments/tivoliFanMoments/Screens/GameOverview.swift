import SwiftUI

struct GamesOverviewView: View {
    @State private var selectedSeason = "2025"
    let seasons = ["2023", "2024", "2025"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Text("Hier ist deine Spielübersicht.")
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Spiele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Saison", selection: $selectedSeason) {
                        ForEach(seasons, id: \.self) { season in
                            Text(season).tag(season)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

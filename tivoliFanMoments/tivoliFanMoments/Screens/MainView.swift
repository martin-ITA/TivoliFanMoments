
import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GamesOverviewView()
                .tabItem {
                    Image(systemName: "sportscourt") // Alternativ ein eigenes Icon
                    Text("Spiele")
                }
                .tag(0)
            
            CameraView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Kamera")
                }
                .tag(1)
            
            UploadView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Upload")
                }
                .tag(2)
        }
        .accentColor(.yellow)
        .background(Color.black.ignoresSafeArea()) // HINZUGEFÜGT!
    }
}

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                GamesOverviewView()
                    .tabItem {
                        Image(systemName: "sportscourt")
                        Text("Spiele")
                    }
                    .tag(0)

                ScanWrapperView()
                    .tabItem {
                        Image(systemName: "camera")
                        Text("Kamera")
                    }
                    .tag(1)

                UploadOverviewView()
                    .tabItem {
                        Image(systemName: "square.and.arrow.up")
                        Text("Upload")
                    }
                    .tag(2)
            }
            .accentColor(.yellow)
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.yellow)
                            .frame(width: 48, height: 48)
                    }
                }
            }
        }
    }
}

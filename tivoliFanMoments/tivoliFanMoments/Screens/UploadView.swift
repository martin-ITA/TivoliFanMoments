import SwiftUI

struct UploadView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("Hier kannst du deine Dateien hochladen.")
                    .foregroundColor(.yellow)
                    .padding()
                
                Spacer()
            }
        }
    }
}

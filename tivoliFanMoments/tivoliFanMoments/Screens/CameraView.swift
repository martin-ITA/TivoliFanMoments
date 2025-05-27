
import SwiftUI
struct CameraView: View {
    var body: some View {
        VStack {
            Text("Kamera wird geöffnet...")
                .foregroundColor(.yellow)
                .padding()
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}


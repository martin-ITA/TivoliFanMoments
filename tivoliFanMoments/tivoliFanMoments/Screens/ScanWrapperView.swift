import SwiftUI

struct ScanWrapperView: View {
    @StateObject var viewModel = QRScanViewModel()
    @State private var manualCode: String = ""
    @State private var path = NavigationPath()

    private func submitCode() {
        let trimmed = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📨 Submitting code: \(trimmed)")
        viewModel.lookup(trimmed) { result in
            if let game = result {
                path.append(game)
            }
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 📷 Scanner oben
                    QRCodeScannerView { code in
                        print("🔍 Detected QR code: \(code)")
                        manualCode = code
                        submitCode()
                    }
                    .frame(height: 400)
                    .overlay(
                        Text("QR-Code scannen")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                            .padding(.top, 20),
                        alignment: .top
                    )

                    Spacer()

                    VStack(spacing: 16) {
                        Text("Oder QR-Code manuell eingeben")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        HStack {
                            TextField("z. B. 123", text: $manualCode)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .foregroundColor(.yellow)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow, lineWidth: 1)
                                )

                            Button(action: {
                                submitCode()
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.yellow)
                            }
                            .padding(.leading, 5)
                        }
                        .padding(.horizontal)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(for: Begegnung.self) { game in
                UploadView(begegnung: game)
            }
        }
    }
}

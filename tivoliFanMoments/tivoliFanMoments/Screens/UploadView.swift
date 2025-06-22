import SwiftUI
import PhotosUI
import UniformTypeIdentifiers


struct UploadView: View {
    let begegnung: Begegnung
    
    @State private var selectedEvent = "Tor"
    let events = ["Tor", "Torchance", "Foul", "Gelbe Karte", "Rote Karte", "Ecke", "Freistoss", "Elfmeter", "Choreo", "Sonstiges"]
    
    @State private var minute: String = ""
    @State private var selectedMediaType: String = "Foto"
    let mediaTypes = ["Foto", "Video"]
    
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var mediaData: Data? = nil
    @State private var fileExtension: String? = nil
    @State private var isUploading = false

    private let db = DatabaseConnector()
    private let storage = StorageConnector()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Upload")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                Picker("Medientyp", selection: $selectedMediaType) {
                    ForEach(mediaTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                Picker("Ereignis", selection: $selectedEvent) {
                    ForEach(events, id: \.self) { event in
                        Text(event)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 20)
                .foregroundColor(.yellow)
                
                TextField("Minute", text: $minute, prompt: Text("Minute").foregroundColor(.yellow))
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                
                PhotosPicker(selection: $pickerItem, matching: .any(of: [.images, .videos])) {
                    Text("Datei auswählen")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .onChange(of: pickerItem) {
                    Task {
                        guard let item = pickerItem else {
                            mediaData = nil
                            fileExtension = nil
                            return
                        }

                        if let data = try? await item.loadTransferable(type: Data.self) {
                            mediaData = data
                        }

                        if let utType = item.supportedContentTypes.first {
                            fileExtension = utType.preferredFilenameExtension
                        } else {
                            // fallback
                            fileExtension = selectedMediaType == "Foto" ? "jpg" : "mp4"
                        }
                    }
                }

                .padding(.horizontal, 20)
                
                Button("Datei hochladen") {
                    Task { await handleUpload() }
                }
                .disabled(isUploading)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Spiel-Infos mit deinen Models
                VStack(alignment: .leading, spacing: 10) {
                    Text("Spiel-Informationen:")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    Text("⚽ Heimteam: \(begegnung.heim.name)")
                        .foregroundColor(.yellow.opacity(0.8))
                    
                    Text("⚽ Auswärtsteam: \(begegnung.gast.name)")
                        .foregroundColor(.yellow.opacity(0.8))
                    
                    Text("📅 Spieltag: \(begegnung.spieltag)")
                        .foregroundColor(.yellow.opacity(0.8))
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .padding(.top, 30)

            if isUploading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            }
        }
    }
    
    
    @MainActor
    private func handleUpload() async {
        guard let data = mediaData,
              let minuteInt = Int(minute) else { return }

        isUploading = true
        defer { isUploading = false }

        do {
            let momentId = try await db.createMoment(begegnungId: begegnung.id, minute: minuteInt, art: selectedEvent)
            let ext = (fileExtension ?? (selectedMediaType == "Foto" ? "jpg" : "mp4")).lowercased()
            let folder = ["mp4", "mov", "m4v"].contains(ext) ? "Videos" : "Photos"
            let id = try await db.createUpload(momentId: momentId, ext: ext, description: nil)
            let path = "\(folder)/\(id).\(ext)"
            try await storage.upload(data: data, path: path)
            
        } catch {
            print("⚠️ upload failed", error)
        }
    }
}

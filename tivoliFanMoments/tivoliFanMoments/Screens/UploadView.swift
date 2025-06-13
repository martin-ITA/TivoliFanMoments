import SwiftUI
import PhotosUI

struct UploadView: View {
    let begegnung: Begegnung

    @State private var selectedEvent = "Tor"
    let events = ["Tor", "Foul", "Ecke", "Freistoß", "Elfmeter"]

    @State private var minute: String = ""
    @State private var selectedMediaType: String = "Foto"
    let mediaTypes = ["Foto", "Video"]

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedMedia: MediaType?

    @StateObject private var uploadManager = UploadManager()

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

                TextField("", text: $minute)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: minute.isEmpty) {
                        Text("Minute").foregroundColor(.yellow.opacity(0.7))
                    }
                    .padding(.horizontal, 20)

                PhotosPicker(
                    selection: $selectedItem,
                    matching: selectedMediaType == "Foto" ? .images : .videos,
                    photoLibrary: .shared()
                ) {
                    Text("Datei auswählen")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        guard let item = newItem else { return }

                        do {
                            if selectedMediaType == "Foto" {
                                if let data = try await item.loadTransferable(type: Data.self) {
                                    selectedMedia = .photo(data)
                                }
                            } else {
                                if let url = try await item.loadTransferable(type: URL.self) {
                                    selectedMedia = .video(url)
                                }
                            }
                        } catch {
                            uploadManager.errorMessage = "Fehler beim Laden der Datei: \(error.localizedDescription)"
                        }
                    }
                }

                Button(uploadManager.isUploading ? "Lade hoch..." : "Upload starten") {
                    Task {
                        guard let media = selectedMedia,
                              let minuteInt = Int(minute) else {
                            uploadManager.errorMessage = "Bitte alle Felder korrekt ausfüllen."
                            return
                        }

                        await uploadManager.uploadMedia(
                            media: media,
                            begegnungId: begegnung.id,
                            minute: minuteInt,
                            art: selectedEvent,
                            beschreibung: nil
                        )
                    }
                }
                .disabled(selectedMedia == nil || minute.isEmpty || uploadManager.isUploading)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedMedia == nil || uploadManager.isUploading ? Color.gray : Color.yellow)
                .cornerRadius(10)
                .padding(.horizontal, 20)

                if let error = uploadManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                Spacer()

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
        }
    }
}

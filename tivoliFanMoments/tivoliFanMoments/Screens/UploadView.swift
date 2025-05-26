import SwiftUI

struct UploadView: View {
    @State private var selectedEvent = "Tor"
    let events = ["Tor", "Foul", "Ecke", "Freistoß", "Elfmeter"]
    
    @State private var minute: String = ""
    @State private var selectedMediaType: String = "Foto"
    let mediaTypes = ["Foto", "Video"]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Upload")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                // Medientyp-Auswahl
                Picker("Medientyp", selection: $selectedMediaType) {
                    ForEach(mediaTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                // Ereignis-Auswahl
                Picker("Ereignis", selection: $selectedEvent) {
                    ForEach(events, id: \.self) { event in
                        Text(event)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.yellow)
                .padding(.horizontal, 20)
                
                // Minute
                TextField("", text: $minute)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.yellow)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                    .placeholder(when: minute.isEmpty) {
                        Text("Minute")
                            .foregroundColor(.yellow.opacity(0.7))
                            .padding(.leading, 8)
                    }
                    .padding(.horizontal, 20)
                
                // Upload-Button
                Button(action: {
                    // Upload-Logik später
                }) {
                    Text("Datei hochladen")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 📌 Platzhalter für Spiel-Infos
                VStack(alignment: .leading, spacing: 10) {
                    Text("Spiel-Informationen:")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    Text("⚽ Heimteam: Alemeannia Aachen")
                        .foregroundColor(.yellow.opacity(0.8))
                    
                    Text("⚽ Auswärtsteam: Musterstadt 09")
                        .foregroundColor(.yellow.opacity(0.8))
                    
                    Text("📅 Datum: 01.01.2025")
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

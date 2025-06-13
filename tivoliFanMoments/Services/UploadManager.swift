import SwiftUI
import PhotosUI
import Supabase
import UniformTypeIdentifiers
import AVFoundation

// MARK: - MediaType Enum
enum MediaType {
    case photo(Data)
    case video(URL)
}

// MARK: - AnyEncodable für Supabase .insert()
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - UploadManager
final class UploadManager: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String?
    
    private let storage: StorageFileApi
    private let client: SupabaseClient
    
    init() {
        let url = URL(string: "https://sctqrvrrimuzsugimzbu.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjdHFydnJyaW11enN1Z2ltemJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5ODU2NTQsImV4cCI6MjA2MzU2MTY1NH0.2fG-Ba4zCs7T4CH071vo4-iKwTtxEgzeOlWlueEzXFM" // ersetze durch deinen tatsächlichen Key
        
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        self.storage = client.storage.from("fanuploads")
    }
    
    func uploadMedia(
        media: MediaType,
        begegnungId: Int,
        minute: Int,
        art: String,
        beschreibung: String? = nil
    ) async {
        isUploading = true
        defer { isUploading = false }

        guard let userId = DatabaseConnector.userProfile?.id else {
            errorMessage = "Kein Benutzer angemeldet."
            return
        }

        // 1. Insert tbl_moment
        let momentResponse = try? await client
            .from("tbl_moment")
            .insert([
                "fk_begegnung": AnyEncodable(begegnungId),
                "minute": AnyEncodable(minute),
                "art": AnyEncodable(art)
            ])
            .select()
            .single()
            .execute()
        
        guard
            let dataMoment = momentResponse?.data,
            let momentJson = try? JSONSerialization.jsonObject(with: dataMoment) as? [String: Any],
            let momentId = momentJson["pk_moment"] as? Int
        else {
            errorMessage = "Moment konnte nicht erstellt werden."
            return
        }

        // 2. Vorbereitung Datei
        let ext: String
        let fileData: Data
        let folder: String
        let contentType: String
        
        switch media {
        case .photo(let imageData):
            ext = "png"
            fileData = imageData
            folder = "Photos"
            contentType = "image/png"
            
        case .video(let videoURL):
            ext = "mp4"
            folder = "Videos"
            contentType = "video/mp4"
            
            guard let videoData = try? Data(contentsOf: videoURL) else {
                errorMessage = "Video konnte nicht geladen werden."
                return
            }
            fileData = videoData
        }

        // 3. Insert tbl_upload
        let uploadResponse = try? await client
            .from("tbl_upload")
            .insert([
                "fk_nutzer": AnyEncodable(userId),
                "fk_moment": AnyEncodable(momentId),
                "typ": AnyEncodable(ext),
                "beschreibung": AnyEncodable(beschreibung ?? ""),
                "dateipfad": AnyEncodable("\(folder)/TEMP")
            ])
            .select()
            .single()
            .execute()
        
        guard
            let dataUpload = uploadResponse?.data,
            let uploadJson = try? JSONSerialization.jsonObject(with: dataUpload) as? [String: Any],
            let uploadId = uploadJson["pk_upload"] as? Int
        else {
            errorMessage = "Upload-Eintrag fehlgeschlagen."
            return
        }

        let filename = "\(uploadId).\(ext)"
        let fullPath = "\(folder)/\(filename)"
        
        // 4. Datei hochladen
        do {
            _ = try await storage.upload(
                path: fullPath,
                file: fileData,
                options: FileOptions(contentType: contentType)
            )
        } catch {
            errorMessage = "Fehler beim Hochladen: \(error.localizedDescription)"
            return
        }

        // 5. Optional: Pfad aktualisieren
        try? await client
            .from("tbl_upload")
            .update(["dateipfad": AnyEncodable(fullPath)])
            .eq("pk_upload", value: uploadId)
            .execute()
    }
}

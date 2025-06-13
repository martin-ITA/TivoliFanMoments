//
//  StorageConnector.swift
//  tivoliFanMoments
//

import Foundation
import Supabase

fileprivate let logger = PredefinedLogger.databaseLogger

final class StorageConnector {

    // MARK: Properties
    private let client: SupabaseClient
    private let bucket: StorageFileApi

    // MARK: Init
    init() {
        let supabaseURL = URL(string: "https://sctqrvrrimuzsugimzbu.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjdHFydnJyaW11enN1Z2ltemJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5ODU2NTQsImV4cCI6MjA2MzU2MTY1NH0.2fG-Ba4zCs7T4CH071vo4-iKwTtxEgzeOlWlueEzXFM"

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        bucket = client.storage.from("fanuploads")
    }

    // MARK: Public helper
    func url(for upload: Upload) -> URL? {
        let folder = upload.kind == .video ? "Videos" : "Photos"
        let path   = "\(folder)/\(upload.id).\(upload.ext.lowercased())"

        // try?  ➜ converts any thrown error into nil
        let url = try? bucket.getPublicURL(path: path)

        logger.notice("[StorageConnector] URL for \(path): \(url?.absoluteString ?? "nil")")
        return url                    // URL? now, so the feed knows when it failed
    }

}

//
//  UploadFeedView.swift
//  tivoliFanMoments
//
//  Created by Bofur on 13.06.25.
//

import SwiftUI
import AVKit

struct UploadFeedView: View {
    let moment: Moment
    @State private var uploads: [Upload] = []
    
    private let db      = DatabaseConnector()
    private let storage = StorageConnector()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(uploads) { upload in
                    UploadTile(upload: upload, storage: storage)
                }
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Uploads (\(moment.minute)')")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadUploads() }
    }
    
    @MainActor
    private func loadUploads() async {
        do   { uploads = try await db.fetchUploads(momentId: moment.id) }
        catch { print("⚠️ fetchUploads error:", error) }
    }
}

// MARK: - Small reusable view

private struct UploadTile: View {
    let upload: Upload
    let storage: StorageConnector
    
    var body: some View {
        switch upload.kind {
        case .image:
            if let url = storage.url(for: upload) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:   ProgressView()
                    case .success(let img): img.resizable().scaledToFit()
                    default:       Color.gray
                    }
                }
                .cornerRadius(12)
                .padding(.horizontal)
            }

        case .video:
            if let url = storage.url(for: upload) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }

    }
}

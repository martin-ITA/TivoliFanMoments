//
//  UploadFeedView.swift
//  tivoliFanMoments
//
//  Created by Bofur on 13.06.25.
//

import SwiftUI
import AVKit
import AVFoundation

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

    @State private var reactionCounts: [ReactionType: Int] = [:]
    @State private var userReaction: ReactionType? = nil
    @State private var player: AVPlayer = AVPlayer()
    @State private var uploaderName: String = ""
    @State private var contentLoaded = false

    private let db = DatabaseConnector()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if contentLoaded && !uploaderName.isEmpty {
                Text("Hochgeladen von: \(uploaderName)")
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
            }

            switch upload.kind {
            case .image:
                if let url = storage.url(for: upload) {
                    ZoomableView {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let img):
                                img.resizable().scaledToFit()
                                    .onAppear { contentLoaded = true }
                            default:
                                Color.gray
                            }
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

            case .video:
                if let url = storage.url(for: upload) {
                    ZoomableView {
                        VideoPlayer(player: player)
                            .onAppear {
                                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                                do {
                                    let session = AVAudioSession.sharedInstance()
                                    try session.setCategory(.playback)
                                    try session.setActive(true)
                                } catch {
                                    print("⚠️ AudioSession error", error)
                                }
                                contentLoaded = true
                            }
                    }
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }

            if contentLoaded {
                HStack(spacing: 24) {
                    reactionButton(.like, systemName: "hand.thumbsup")
                    reactionButton(.lachen, systemName: "face.smiling")
                    reactionButton(.herz, systemName: "heart")
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        }
        .onAppear {
            Task { await loadReactions() }
            Task { await loadUploaderName() }
        }
    }

        @ViewBuilder
        private func reactionButton(_ type: ReactionType, systemName: String) -> some View {
            let count = reactionCounts[type] ?? 0
            Button(action: { Task { await react(type) } }) {
                HStack(spacing: 4) {
                    Image(systemName: systemName)
                        .foregroundColor(userReaction == type ? .yellow : .white)
                    Text("\(count)")
                        .foregroundColor(.yellow)
                }
            }
        }

        @MainActor
        private func loadReactions() async {
            do {
                reactionCounts = try await db.fetchReactionCounts(uploadId: upload.id)
                userReaction = try await db.fetchUserReaction(uploadId: upload.id)
            } catch {
                print("⚠️ reaction load failed", error)
            }
        }

        @MainActor
        private func react(_ type: ReactionType) async {
            do {
                try await db.setReaction(uploadId: upload.id, reaction: type)
                await loadReactions()
            } catch {
                print("⚠️ reaction set failed", error)
            }
        }

        @MainActor
        private func loadUploaderName() async {
            if upload.userId == DatabaseConnector.userProfile?.id {
                uploaderName = "Dir selbst"
                return
            }

            do {
                uploaderName = try await db.fetchUsername(userId: upload.userId)
            } catch {
                print("⚠️ username load failed", error)
            }
        }

    }


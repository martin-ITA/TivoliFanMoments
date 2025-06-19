//
//  DatabaseConnector.swift
//  tivoliFanMoments
//
//  Created by Bofur on 27.05.25.
//

// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Combine
import Supabase

fileprivate let logger = PredefinedLogger.databaseLogger

enum DatabaseError: Error, CustomStringConvertible {
    case invalidUserProfile
    case unexpected(message: String)

    var description: String {
        switch self {
        case .invalidUserProfile:
            return "Invalid user profile."
        case .unexpected(let message):
            return "Unexpected error: \(message)"
        }
    }
}

enum DatabaseConnectorEvent {
    case signedIn(userProfile: UserProfile, session: Session? = nil) // session stays nil now
    case signInFailed(String)
    case signedOut
    case broadcast(payload: [String: String])
}

final class DatabaseConnector {
    private let client: SupabaseClient
    
    private let eventSubject = CurrentValueSubject<DatabaseConnectorEvent, Never>(.signedOut)

    // make them readable
    var current: SupabaseClient { client }
    
    var eventPublisher: AnyPublisher<DatabaseConnectorEvent, Never> {eventSubject.eraseToAnyPublisher()}
    
    private let broadcastChannel = "mobileApp-channel"
    private let broadcastEvent = "mobileApp-event"          // "*" does not work...
    var channel : RealtimeChannelV2
    
    var isAuthenticated = false
    static var userProfile: UserProfile? = nil

    init() {
        // from supabase project
        let supabaseUrl = URL(string: "https://sctqrvrrimuzsugimzbu.supabase.co")!
        let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjdHFydnJyaW11enN1Z2ltemJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5ODU2NTQsImV4cCI6MjA2MzU2MTY1NH0.2fG-Ba4zCs7T4CH071vo4-iKwTtxEgzeOlWlueEzXFM"
        
        // supabase access
        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseAnonKey)
        
        // broadcast access
        channel = client.realtimeV2.channel(broadcastChannel) {
            $0.broadcast.acknowledgeBroadcasts = true
            $0.broadcast.receiveOwnBroadcasts = true
        }
        
        // auth change observer
        Task {
            logger.notice("[DatabaseConnector] start observer")

            for await (event, session) in client.auth.authStateChanges {
                logger.notice("[DatabaseConnector] auth change event:\(event.rawValue)")
                switch event {
                case .signedIn, .initialSession: // maybe there is still a valid session
                    do {
                        guard let session = session,
                              let email = session.user.email else { throw DatabaseError.invalidUserProfile }
                        let userProfile = UserProfile(id: 0, email: email, displayname: "Moin")
                        self.isAuthenticated = true
                        DatabaseConnector.userProfile = userProfile
                        eventSubject.send(.signedIn(userProfile: userProfile, session: session))
                    } catch {
                        if event == .signedIn {
                            logger.notice("[DatabaseConnector] profile error:\(error)")
                            signOut()
                        }
                    }
                case .signedOut:
                    self.isAuthenticated = false
                    DatabaseConnector.userProfile = nil
                    eventSubject.send(.signedOut)
                // case .tokenRefreshed:   // handle token refresh if necessary
                // case .userUpdated:      // handle user updates if necessary
                default:
                    break
                }
            }
        }
        
        // broadcast listener
        /**
        Task {
            await channel.subscribe()
            
            let status = "\(channel.status)"
            logger.notice("[DatabaseConnector] channel status:\(status)")

            for await event in channel.broadcastStream(event:broadcastEvent) {
                logger.notice("[DatabaseConnector] channel event:\(event)")

                if let payloadMember = event["payload"] {
                    switch payloadMember {
                    case .object(let dict):
                        let stringDict = dict.compactMapValues { $0.stringValue }
                        eventSubject.send(.broadcast(payload: stringDict))
                    default:
                        break
                    }
                } else {
                    logger.notice("[DatabaseConnector] channel event in unknown format")
                }
            }
        }
         */
    }
    
    // deinit { maybe something to clean up }
    
    // ───────── DatabaseConnector.swift ────────────────────────────
    func signIn(email: String, password: String) {
        Task { @MainActor in
            do {
                logger.notice("[SupabaseConnector] sign in, email:\(email)")

                // ① ask for ONE row that matches e-mail & password
                let user: UserProfile = try await client
                    .from("tbl_nutzer")
                    .select()                       // * = all columns
                    .eq("email",     value: email)
                    .eq("passwort",  value: password)
                    .single()                       // expect exactly 1 row
                    .execute()
                    .value                          // ← decoded to UserProfile

                // ② update state and broadcast success
                self.isAuthenticated = true
                DatabaseConnector.userProfile     = user
                eventSubject.send(.signedIn(userProfile: user))

            } catch {
                logger.error("[SupabaseConnector] sign in error: \(error)")
                self.isAuthenticated = false
                DatabaseConnector.userProfile     = nil
                eventSubject.send(.signInFailed("Login fehlgeschlagen"))
            }
        }
    }
    
    func countUploadsPerMoment(momentId: Int) async throws -> Int {
        logger.notice("[SupabaseConnector] Counting uploads for momentId:\(momentId)")

        let response = try await client
            .from("tbl_upload")
            .select("pk_upload", count: .exact) // use .exact to get the precise count
            .eq("fk_moment", value: momentId)
            .execute()

        if let count = response.count {
            logger.notice("[SupabaseConnector] Upload count: \(count)")
            return count
        } else {
            logger.warning("[SupabaseConnector] No count available, returning 0")
            return 0
        }
    }

    func signOut() {
        Task {
            do {
                logger.notice("[SupabaseConnector] sign out")
                try await client.auth.signOut()
                logger.notice("[SupabaseConnector] sign out worked")
            } catch {
                logger.error("[SupabaseConnector] sign out error:\(error)")
            }
        }
    }
    
    /**
    func broadcast(payload: [String: String]) {
        Task {
            do {
                try await channel.broadcast(event: broadcastEvent, message: payload)
            } catch {
                logger.error("[SupabaseConnector] broadcast error:\(error)")
            }
        }
    }
     */

    func fetchAllSaisons() async throws -> [Saison] {
        logger.notice("[DatabaseConnector] fetchAllSaisons() started")

        do {
            let saisons: [Saison] = try await client
                .from("tbl_saison")
                .select("pk_saison, bezeichnung")
                .order("bezeichnung", ascending: true)
                .execute()
                .value

            logger.notice("[DatabaseConnector] fetchAllSaisons() success, count: \(saisons.count)")
            return saisons
        } catch {
            logger.error("[DatabaseConnector] fetchAllSaisons() error: \(error)")
            throw error
        }
    }

    func fetchAllGames(saisonId: Int) async throws -> [Begegnung] {
        logger.notice("[DatabaseConnector] fetchAllGames() started")

        do {
            let response = try await client
                .from("tbl_begegnung")
                .select("""
                    pk_begegnung,
                    spieltag,
                    heim_tore,
                    gast_tore,
                    fk_mannschaft_heim (
                        pk_mannschaft,
                        name
                    ),
                    fk_mannschaft_gast (
                        pk_mannschaft,
                        name
                    )
                """)
                .eq("fk_saison", value: saisonId)
                .execute()

            let data = response.data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[DEBUG] Raw JSON:\n\(jsonString)")
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let result = try decoder.decode([Begegnung].self, from: data)
            return result

        } catch {
            logger.error("[DatabaseConnector] fetchAllGames() error: \(error)")
            throw error
        }
    }
    
    func fetchMomente(begegnungId: Int) async throws -> [Moment] {
        logger.notice("[DatabaseConnector] fetchMomente() started")

        do {
            let response = try await client
                .from("tbl_moment")
                .select("pk_moment, minute, art")
                .eq("fk_begegnung", value: begegnungId)
                .order("minute", ascending: true)
                .execute()

            let data = response.data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[DEBUG] Raw JSON:\n\(jsonString)")
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let result = try decoder.decode([Moment].self, from: data)
            return result
        } catch {
            logger.error("[DatabaseConnector] fetchMomente() error: \(error)")
            throw error
        }
    }
    
    func findGameByQRCode(_ code: String) async throws -> Begegnung? {
        logger.notice("[DatabaseConnector] findGameByQRCode() started")
        
        do {
            let response = try await client
                .from("tbl_begegnung")
                .select("""
                    pk_begegnung,
                    spieltag,
                    heim_tore,
                    gast_tore,
                    qr_code,
                    fk_mannschaft_heim (
                        pk_mannschaft,
                        name
                    ),
                    fk_mannschaft_gast (
                        pk_mannschaft,
                        name
                    )
                """)
                .eq("qr_code", value: code)
                .single()
                .execute()
            
            let result = try JSONDecoder().decode(Begegnung.self, from: response.data)
            print(result)
            return result
        } catch {
            logger.error("[DatabaseConnector] findGameByQRCode() error: \(error)")
            return nil
        }
    }

    /// Reads all uploads that belong to one moment.
    func fetchUploads(momentId: Int) async throws -> [Upload] {
        logger.notice("[DatabaseConnector] fetchUploads() started for momentId \(momentId)")
        
        do {
            let response = try await client
                .from("tbl_upload")
                .select("pk_upload, fk_moment, typ, dateipfad, beschreibung, fk_nutzer")
                .eq("fk_moment", value: momentId)
                .order("pk_upload", ascending: true)
                .execute()
            
            // Helpful when debugging JSON ↔︎ model mapping
            if let json = String(data: response.data, encoding: .utf8) {
                print("[DEBUG] Raw JSON uploads:\n\(json)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let uploads = try decoder.decode([Upload].self, from: response.data)
            return uploads
        } catch {
            logger.error("[DatabaseConnector] fetchUploads() error: \(error)")
            throw error
        }
    }
    
    func recordVisit(begegnungId: Int) async throws {
        _ = try await client
            .from("tbl_besuche")
            .insert([
                "fk_nutzer": DatabaseConnector.userProfile?.id,
                "fk_begegnung": begegnungId
                ]
            )
            .execute()
    }

    func fetchBesuchteBegegnungen(userId: Int) async throws -> [Begegnung] {
        let response = try await client
            .from("tbl_besuche")
            .select("""
                fk_begegnung (
                    pk_begegnung,
                    spieltag,
                    heim_tore,
                    gast_tore,
                    qr_code,
                    fk_mannschaft_heim (
                        pk_mannschaft,
                        name
                    ),
                    fk_mannschaft_gast (
                        pk_mannschaft,
                        name
                    )
                )
            """)
            .eq("fk_nutzer", value: DatabaseConnector.userProfile?.id)
            .execute()

        struct BesuchWrapper: Decodable {
            let fk_begegnung: Begegnung
        }

        let decoded = try JSONDecoder().decode([BesuchWrapper].self, from: response.data)
        return decoded.map { $0.fk_begegnung }
    }

    private struct NewMoment: Encodable {
        let fk_begegnung: Int
        let minute: Int
        let art: String        // or MomentArt
    }

    func createMoment(begegnungId: Int,
                      minute: Int,
                      art: String) async throws -> Int {
        struct MomentId: Decodable { let pk_moment: Int }

        // first we need to check if a moment like this is already present in our database
        do {
            let existingResponse = try await client
                .from("tbl_moment")
                .select("pk_moment")
                .eq("fk_begegnung", value: begegnungId)
                .eq("minute", value: minute)
                .eq("art", value: art)
                .single()
                .execute()

            let existing = try JSONDecoder()
                .decode(MomentId.self, from: existingResponse.data)
            return existing.pk_moment
        } catch let error as PostgrestError where error.code == "PGRST116" {
            // in this case we know we have to create a new row
        } catch {
            throw error
        }

        // create new row :-)
        let newMoment = NewMoment(
            fk_begegnung: begegnungId,
            minute: minute,
            art: art
        )

        let insertResponse = try await client
            .from("tbl_moment")
            .insert(newMoment)
            .select("pk_moment")
            .single()
            .execute()

        let created = try JSONDecoder()
            .decode(MomentId.self, from: insertResponse.data)
        return created.pk_moment
    }


    private struct NewUpload: Encodable {
        let fk_moment: Int
        let typ: String
        let beschreibung: String
        let dateipfad: String
        let fk_nutzer: Int
    }

    func createUpload(momentId: Int,
                      ext: String,
                      description: String?) async throws -> Int {
        let newUpload = NewUpload(
            fk_moment: momentId,
            typ: ext,
            beschreibung: description ?? "",
            dateipfad: "", // initially empty
            fk_nutzer: SessionManager.shared.currentUser!.id
        )

        // Insert upload, request pk_upload back
        let insertResponse = try await client
            .from("tbl_upload")
            .insert(newUpload)
            .select("pk_upload, typ, beschreibung, dateipfad, fk_nutzer, fk_moment")
            .single()
            .execute()

        struct InsertedUpload: Decodable {
            let pk_upload: Int
            let typ: String
            let beschreibung: String
            let dateipfad: String
            let fk_nutzer: Int
            let fk_moment: Int
        }

        let inserted = try JSONDecoder().decode(InsertedUpload.self, from: insertResponse.data)

        let newDateipfad = "\(inserted.pk_upload).\(ext)"

        // Update just this row
        try await client
            .from("tbl_upload")
            .update(["dateipfad": newDateipfad])
            .eq("pk_upload", value: inserted.pk_upload)
            .execute()

        return inserted.pk_upload
    }
    
    /// Returns the number of reactions of each type for the given upload.
        func fetchReactionCounts(uploadId: Int) async throws -> [ReactionType: Int] {
            var result: [ReactionType: Int] = [:]

            for type in ReactionType.allCases {
                let response = try await client
                    .from("tbl_interaktion")
                    .select("fk_upload", count: .exact)
                    .eq("fk_upload", value: uploadId)
                    .eq("reaktion", value: type.rawValue)
                    .execute()

                result[type] = response.count ?? 0
            }

            return result
        }

        /// Returns the current user's reaction for the given upload if it exists.
        func fetchUserReaction(uploadId: Int) async throws -> ReactionType? {
            guard let userId = SessionManager.shared.currentUser?.id else { return nil }

            do {
                let response = try await client
                    .from("tbl_interaktion")
                    .select("reaktion")
                    .eq("fk_upload", value: uploadId)
                    .eq("fk_nutzer", value: userId)
                    .single()
                    .execute()

                struct ReactionWrapper: Decodable { let reaktion: ReactionType }
                return try JSONDecoder().decode(ReactionWrapper.self, from: response.data).reaktion
            } catch {
                return nil
            }
        }

        /// Stores a reaction for the given upload from the current user.
        /// If a reaction already exists it will be updated.
    func setReaction(uploadId: Int, reaction: ReactionType) async throws {
        guard let userId = SessionManager.shared.currentUser?.id else { return }

        struct Interaction: Codable {
            let fk_upload: Int
            let fk_nutzer: Int
            let reaktion: String
        }

        // Wrapper that matches the SELECT "reaktion" you perform
        struct ReactionWrapper: Decodable { let reaktion: String }

        let values = Interaction(
            fk_upload: uploadId,
            fk_nutzer: userId,
            reaktion : reaction.rawValue
        )

        do {
            // ── does a row already exist? ────────────────────────────────
            let existing = try await client
                .from("tbl_interaktion")
                .select("reaktion")
                .eq("fk_upload", value: uploadId)
                .eq("fk_nutzer", value: userId)
                .single()
                .execute()

            let decoded = try JSONDecoder().decode(ReactionWrapper.self,
                                                   from: existing.data)

            if decoded.reaktion == reaction.rawValue {
                // same button tapped again → delete the row
                try await client
                    .from("tbl_interaktion")
                    .delete()
                    .eq("fk_upload", value: uploadId)
                    .eq("fk_nutzer", value: userId)
                    .execute()
            } else {
                // different reaction → update the existing row
                try await client
                    .from("tbl_interaktion")
                    .update(["reaktion": reaction.rawValue])
                    .eq("fk_upload", value: uploadId)
                    .eq("fk_nutzer", value: userId)
                    .execute()
            }

        } catch let error as PostgrestError where error.code == "PGRST116" {
            // no row found → insert a new one
            try await client
                .from("tbl_interaktion")
                .insert(values)
                .execute()
        } catch {
            throw error        // bubble up everything else
        }
    }

    /// Returns the username for the given user id.
    func fetchUsername(userId: Int) async throws -> String {
        let response = try await client
            .from("tbl_nutzer")
            .select("nutzername")
            .eq("pk_nutzer", value: userId)
            .single()
            .execute()

        struct Wrapper: Decodable { let nutzername: String }
        return try JSONDecoder().decode(Wrapper.self, from: response.data).nutzername
    }

    // MARK: - User profile helpers

    /// Changes the password for the current user if the old password matches.
    func changePassword(old: String, new: String) async throws {
        guard let user = SessionManager.shared.currentUser else { return }
        _ = try await client
            .from("tbl_nutzer")
            .update(["passwort": new])
            .eq("pk_nutzer", value: user.id)
            .eq("passwort", value: old)
            .single()
            .execute()
    }

    /// Returns how many matches the given user has visited.
    func countVisitedMatches(userId: Int) async throws -> Int {
        let response = try await client
            .from("tbl_besuche")
            .select("pk_besuch", count: .exact)
            .eq("fk_nutzer", value: userId)
            .execute()
        return response.count ?? 0
    }

    /// Returns how many uploads the given user has created.
    func countUploads(userId: Int) async throws -> Int {
        let response = try await client
            .from("tbl_upload")
            .select("pk_upload", count: .exact)
            .eq("fk_nutzer", value: userId)
            .execute()
        return response.count ?? 0
    }






}

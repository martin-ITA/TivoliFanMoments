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
    case signedIn(userProfile: UserProfile, session:Session?)
    case signedOut
    case broadcast(payload:[String:String])
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
    var userProfile: UserProfile? = nil

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
                        let userProfile = UserProfile(id: session.user.id, email: email, displayname: "Moin")
                        self.isAuthenticated = true
                        self.userProfile = userProfile
                        eventSubject.send(.signedIn(userProfile: userProfile, session: session))
                    } catch {
                        if event == .signedIn {
                            logger.notice("[DatabaseConnector] profile error:\(error)")
                            signOut()
                        }
                    }
                case .signedOut:
                    self.isAuthenticated = false
                    self.userProfile = nil
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
    
    func signIn(email: String, password: String) {
        Task {
            do {
                logger.notice("[SupabaseConnector] sign in, email:\(email)")
                try await client.auth.signIn(email: email, password: password)
                logger.notice("[SupabaseConnector] sign in worked")
            } catch {
                logger.error("[SupabaseConnector] sign in error:\(error)")
            }
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

}

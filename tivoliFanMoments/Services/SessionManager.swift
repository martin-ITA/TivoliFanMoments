import Foundation
import Combine

/// Keeps the signed-in user for the whole app and forwards
/// login / logout calls to `DatabaseConnector`.
final class SessionManager: ObservableObject {

    // MARK: – Public, observable state
    static let shared = SessionManager()

    @Published private(set) var currentUser: UserProfile? = nil
    @Published private(set) var isAuthenticated: Bool     = false
    @Published private(set) var lastError: String?        = nil   // optional UI feedback

    // MARK: – Private
    private let connector   = ServiceLocator.shared.databaseConnector
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Listen once for all auth-related events coming from the DB connector.
        connector.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .signedIn(let profile, _):
                    self.currentUser     = profile
                    self.isAuthenticated = true
                    self.lastError       = nil

                case .signedOut:
                    self.currentUser     = nil
                    self.isAuthenticated = false

                case .signInFailed(let message):
                    self.currentUser     = nil
                    self.isAuthenticated = false
                    self.lastError       = message
                case .broadcast(payload: let payload):
                    let moin = "Moin"
                }
            }
            .store(in: &cancellables)
    }

    // MARK: – Convenience wrappers (UI calls these)

    /// Attempts to sign in by querying **tbl_nutzer** for the given credentials.
    func signIn(email: String, password: String) {
        connector.signIn(email: email, password: password)
    }

    /// Logs the user out and resets all session state.
    func signOut() {
        connector.signOut()
    }
}

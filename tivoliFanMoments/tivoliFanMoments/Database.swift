import Foundation
import Supabase

class Database {
    static let shared: Database = {
        let environment = ProcessInfo.processInfo.environment
        
        guard let supabaseURLString = environment["supabaseURL"],
              let supabaseKey = environment["supabaseKey"],
              let supabaseURL = URL(string: supabaseURLString) else {
            fatalError("Missing or invalid Supabase environment variables")
        }
        
        let client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        return Database(client: client)
    }()
    
    let client: SupabaseClient
    
    private init(client: SupabaseClient) {
        self.client = client
    }
}

import SwiftUI

@MainActor
class MannschaftViewModel: ObservableObject {
    @Published var mannschaften: [Mannschaft] = []

    func fetchMannschaften() async {
        do {
            let result: [Mannschaft] = try await Database.shared.client
                .from("tbl_mannschaft")
                .select()
                .execute()
                .value
            self.mannschaften = result
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}

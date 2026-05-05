import Foundation

struct APIClient {
    var baseURL: URL?

    func send<T: Encodable>(_ value: T, path: String) async throws {
        // Backend MVP dışında. Repository protokolleri bu katmana bağlanmaya hazır.
        _ = value
        _ = path
    }
}

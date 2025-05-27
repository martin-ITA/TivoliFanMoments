import Foundation
import Network
import Combine

fileprivate let logger = PredefinedLogger.dataLogger

final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private let eventSubject = CurrentValueSubject<Bool, Never>(false)

    var eventPublisher: AnyPublisher<Bool, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            logger.notice("[NetworkMonitor] Network status changed: \(isConnected ? "Connected" : "Disconnected")")
            self?.eventSubject.send(isConnected)
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

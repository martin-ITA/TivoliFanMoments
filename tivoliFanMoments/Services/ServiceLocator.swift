//
//  ServiceLocator.swift
//  tivoliFanMoments
//
//  Created by Bofur on 27.05.25.
//

import Foundation

class ServiceLocator {
    static let shared = ServiceLocator()
    
    private lazy var networkMonitorInstance = NetworkMonitor()
    private lazy var databaseConnectorInstance = DatabaseConnector()

    var networkMonitor: NetworkMonitor { networkMonitorInstance }
    var databaseConnector: DatabaseConnector { databaseConnectorInstance }
}

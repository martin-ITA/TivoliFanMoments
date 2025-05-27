//
//  Logger.swift
//  tivoliFanMoments
//
//  Created by Bofur on 27.05.25.
//

import Foundation
import os

struct PredefinedLogger {
    static let dataLogger = Logger(subsystem: "com.fh-aachen.ios.x04-supa-app", category: "data")
    static let databaseLogger = Logger(subsystem: "com.fh-aachen.ios.x04-supa-app", category: "database")
}
